#include <string>
#include <ctime>
#include <iostream>
#include <stdio.h>

#include <cuda.h>
#include <cuda_runtime.h>

#include "cuda_renderer.h"
#include "cdpQuadtree.h"

/**
 * Copyright 1993-2015 NVIDIA Corporation.  All rights reserved.
 *
 * Please refer to the NVIDIA end user license agreement (EULA) associated
 * with this source code for terms and conditions that govern your use of
 * this software. Any use, reproduction, disclosure, or distribution of
 * this software and related documentation outside the terms of the EULA
 * is strictly prohibited.
 *
 */

 #include <thrust/random.h>
 #include <thrust/device_vector.h>
 #include <helper_cuda.h>
 
 #include "cdpQuadtree.h"
 
 class Points
 {
         float *m_x;
         float *m_y;
 
     public:
         // Constructor.
         __host__ __device__ Points() : m_x(NULL), m_y(NULL) {}
 
         // Constructor.
         __host__ __device__ Points(float *x, float *y) : m_x(x), m_y(y) {}
 
         // Get a point.
         __host__ __device__ __forceinline__ float2 get_point(int idx) const
         {
             return make_float2(m_x[idx], m_y[idx]);
         }
 
         // Set a point.
         __host__ __device__ __forceinline__ void set_point(int idx, const float2 &p)
         {
             m_x[idx] = p.x;
             m_y[idx] = p.y;
         }
 
         // Set the pointers.
         __host__ __device__ __forceinline__ void set(float *x, float *y)
         {
             m_x = x;
             m_y = y;
         }
 };
 
 ////////////////////////////////////////////////////////////////////////////////
 // A 2D bounding box
 ////////////////////////////////////////////////////////////////////////////////
 class Bounding_box
 {
         // Extreme points of the bounding box.
         float2 m_p_min;
         float2 m_p_max;
 
     public:
         // Constructor. Create a unit box.
         __host__ __device__ Bounding_box()
         {
             m_p_min = make_float2(0.0f, 0.0f);
             m_p_max = make_float2(1.0f, 1.0f);
         }
 
         // Compute the center of the bounding-box.
         __host__ __device__ void compute_center(float2 &center) const
         {
             center.x = 0.5f * (m_p_min.x + m_p_max.x);
             center.y = 0.5f * (m_p_min.y + m_p_max.y);
         }
 
         // The points of the box.
         __host__ __device__ __forceinline__ const float2 &get_max() const
         {
             return m_p_max;
         }
 
         __host__ __device__ __forceinline__ const float2 &get_min() const
         {
             return m_p_min;
         }

         __host__ __device__ bool overlaps(Bounding_box another_box)
         {
             float2 p3 = make_float2(another_box.m_p_min.x, another_box.m_p_max.y);
             float2 p4 = make_float2(another_box.m_p_max.x, another_box.m_p_min.y);
             return (contains(another_box.m_p_min) ||
                contains(another_box.m_p_max) ||
                contains(p3) || contains(p4));
         }

         // Does a box contain a point.
         __host__ __device__ bool contains(const float2 &p) const
         {
             return p.x >= m_p_min.x && p.x < m_p_max.x && p.y >= m_p_min.y && p.y < m_p_max.y;
         }
 
         // Define the bounding box.
         __host__ __device__ void set(float min_x, float min_y, float max_x, float max_y)
         {
             m_p_min.x = min_x;
             m_p_min.y = min_y;
             m_p_max.x = max_x;
             m_p_max.y = max_y;
         }
 };
 
 ////////////////////////////////////////////////////////////////////////////////
 // A node of a quadree.
 ////////////////////////////////////////////////////////////////////////////////
 class Quadtree_node
 {
         // The identifier of the node.
         int m_id;
         // The bounding box of the tree.
         Bounding_box m_bounding_box;
         // The range of points.
         int m_begin, m_end;
 
 
     public:
         // Constructor.
         __host__ __device__ Quadtree_node() : m_id(0), m_begin(0), m_end(0)
         {}
 
         // The ID of a node at its level.
         __host__ __device__ int id() const
         {
             return m_id;
         }
 
         // The ID of a node at its level.
         __host__ __device__ void set_id(int new_id)
         {
             m_id = new_id;
         }
 
         // The bounding box.
         __host__ __device__ __forceinline__ const Bounding_box &bounding_box() const
         {
             return m_bounding_box;
         }
 
         // Set the bounding box.
         __host__ __device__ __forceinline__ void set_bounding_box(float min_x, float min_y, float max_x, float max_y)
         {
             m_bounding_box.set(min_x, min_y, max_x, max_y);
         }
 
         // The number of points in the tree.
         __host__ __device__ __forceinline__ int num_points() const
         {
             return m_end - m_begin;
         }
 
         // The range of points in the tree.
         __host__ __device__ __forceinline__ int points_begin() const
         {
             return m_begin;
         }
 
         __host__ __device__ __forceinline__ int points_end() const
         {
             return m_end;
         }
 
         // Define the range for that node.
         __host__ __device__ __forceinline__ void set_range(int begin, int end)
         {
             m_begin = begin;
             m_end = end;
         }
 };
 
 ////////////////////////////////////////////////////////////////////////////////
 // Algorithm parameters.
 ////////////////////////////////////////////////////////////////////////////////
 struct Parameters
 {
     // Choose the right set of points to use as in/out.
     int point_selector;
     // The number of nodes at a given level (2^k for level k).
     int num_nodes_at_this_level;
     // The recursion depth.
     int depth;
     // The max value for depth.
     const int max_depth;
     // The minimum number of points in a node to stop recursion.
     const int min_points_per_node;
 
     // Constructor set to default values.
     __host__ __device__ Parameters(int max_depth, int min_points_per_node) :
         point_selector(0),
         num_nodes_at_this_level(1),
         depth(0),
         max_depth(max_depth),
         min_points_per_node(min_points_per_node)
     {}
 
     // Copy constructor. Changes the values for next iteration.
     __host__ __device__ Parameters(const Parameters &params, bool) :
         point_selector((params.point_selector+1) % 2),
         num_nodes_at_this_level(4*params.num_nodes_at_this_level),
         depth(params.depth+1),
         max_depth(params.max_depth),
         min_points_per_node(params.min_points_per_node)
     {}
 };
 
 ////////////////////////////////////////////////////////////////////////////////
 // Build a quadtree on the GPU. Use CUDA Dynamic Parallelism.
 //
 // The algorithm works as follows. The host (CPU) launches one block of
 // NUM_THREADS_PER_BLOCK threads. That block will do the following steps:
 //
 // 1- Check the number of points and its depth.
 //
 // We impose a maximum depth to the tree and a minimum number of points per
 // node. If the maximum depth is exceeded or the minimum number of points is
 // reached. The threads in the block exit.
 //
 // Before exiting, they perform a buffer swap if it is needed. Indeed, the
 // algorithm uses two buffers to permute the points and make sure they are
 // properly distributed in the quadtree. By design we want all points to be
 // in the first buffer of points at the end of the algorithm. It is the reason
 // why we may have to swap the buffer before leavin (if the points are in the
 // 2nd buffer).
 //
 // 2- Count the number of points in each child.
 //
 // If the depth is not too high and the number of points is sufficient, the
 // block has to dispatch the points into four geometrical buckets: Its
 // children. For that purpose, we compute the center of the bounding box and
 // count the number of points in each quadrant.
 //
 // The set of points is divided into sections. Each section is given to a
 // warp of threads (32 threads). Warps use __ballot and __popc intrinsics
 // to count the points. See the Programming Guide for more information about
 // those functions.
 //
 // 3- Scan the warps' results to know the "global" numbers.
 //
 // Warps work independently from each other. At the end, each warp knows the
 // number of points in its section. To know the numbers for the block, the
 // block has to run a scan/reduce at the block level. It's a traditional
 // approach. The implementation in that sample is not as optimized as what
 // could be found in fast radix sorts, for example, but it relies on the same
 // idea.
 //
 // 4- Move points.
 //
 // Now that the block knows how many points go in each of its 4 children, it
 // remains to dispatch the points. It is straightforward.
 //
 // 5- Launch new blocks.
 //
 // The block launches four new blocks: One per children. Each of the four blocks
 // will apply the same algorithm.
 ////////////////////////////////////////////////////////////////////////////////
 template< int NUM_THREADS_PER_BLOCK >
 __global__
 void build_quadtree_kernel(Quadtree_node *nodes, Points *points, Parameters params)
 {
     // The number of warps in a block.
     const int NUM_WARPS_PER_BLOCK = NUM_THREADS_PER_BLOCK / warpSize;
 
     // Shared memory to store the number of points.
     extern __shared__ int smem[];
 
     // s_num_pts[4][NUM_WARPS_PER_BLOCK];
     // Addresses of shared memory.
     volatile int *s_num_pts[4];
 
     for (int i = 0 ; i < 4 ; ++i)
         s_num_pts[i] = (volatile int *) &smem[i*NUM_WARPS_PER_BLOCK];
 
     // Compute the coordinates of the threads in the block.
     const int warp_id = threadIdx.x / warpSize;
     const int lane_id = threadIdx.x % warpSize;
 
     // Mask for compaction.
     int lane_mask_lt = (1 << lane_id) - 1; // Same as: asm( "mov.u32 %0, %%lanemask_lt;" : "=r"(lane_mask_lt) );
 
     // The current node.
     Quadtree_node &node = nodes[blockIdx.x];
 
     // The number of points in the node.
     int num_points = node.num_points();
 
     //
     // 1- Check the number of points and its depth.
     //
 
     // Stop the recursion here. Make sure points[0] contains all the points.
     if (params.depth >= params.max_depth || num_points <= params.min_points_per_node)
     {
         if (params.point_selector == 1)
         {
             int it = node.points_begin(), end = node.points_end();
 
             for (it += threadIdx.x ; it < end ; it += NUM_THREADS_PER_BLOCK)
                 if (it < end)
                     points[0].set_point(it, points[1].get_point(it));
         }
 
         return;
     }
 
     // Compute the center of the bounding box of the points.
     const Bounding_box &bbox = node.bounding_box();
     float2 center;
     bbox.compute_center(center);
 
     // Find how many points to give to each warp.
     int num_points_per_warp = max(warpSize, (num_points + NUM_WARPS_PER_BLOCK-1) / NUM_WARPS_PER_BLOCK);
 
     // Each warp of threads will compute the number of points to move to each quadrant.
     int range_begin = node.points_begin() + warp_id * num_points_per_warp;
     int range_end   = min(range_begin + num_points_per_warp, node.points_end());
 
     //
     // 2- Count the number of points in each child.
     //
 
     // Reset the counts of points per child.
     if (lane_id == 0)
     {
         s_num_pts[0][warp_id] = 0;
         s_num_pts[1][warp_id] = 0;
         s_num_pts[2][warp_id] = 0;
         s_num_pts[3][warp_id] = 0;
     }
 
     // Input points.
     const Points &in_points = points[params.point_selector];
 
     // Compute the number of points.
     for (int range_it = range_begin + lane_id ; __any(range_it < range_end) ; range_it += warpSize)
     {
         // Is it still an active thread?
         bool is_active = range_it < range_end;
 
         // Load the coordinates of the point.
         float2 p = is_active ? in_points.get_point(range_it) : make_float2(0.0f, 0.0f);
 
         // Count top-left points.
         int num_pts = __popc(__ballot(is_active && p.x < center.x && p.y >= center.y));
 
         if (num_pts > 0 && lane_id == 0)
             s_num_pts[0][warp_id] += num_pts;
 
         // Count top-right points.
         num_pts = __popc(__ballot(is_active && p.x >= center.x && p.y >= center.y));
 
         if (num_pts > 0 && lane_id == 0)
             s_num_pts[1][warp_id] += num_pts;
 
         // Count bottom-left points.
         num_pts = __popc(__ballot(is_active && p.x < center.x && p.y < center.y));
 
         if (num_pts > 0 && lane_id == 0)
             s_num_pts[2][warp_id] += num_pts;
 
         // Count bottom-right points.
         num_pts = __popc(__ballot(is_active && p.x >= center.x && p.y < center.y));
 
         if (num_pts > 0 && lane_id == 0)
             s_num_pts[3][warp_id] += num_pts;
     }
 
     // Make sure warps have finished counting.
     __syncthreads();
 
     //
     // 3- Scan the warps' results to know the "global" numbers.
     //
 
     // First 4 warps scan the numbers of points per child (inclusive scan).
     if (warp_id < 4)
     {
         int num_pts = lane_id < NUM_WARPS_PER_BLOCK ? s_num_pts[warp_id][lane_id] : 0;
 #pragma unroll
 
         for (int offset = 1 ; offset < NUM_WARPS_PER_BLOCK ; offset *= 2)
         {
             int n = __shfl_up(num_pts, offset, NUM_WARPS_PER_BLOCK);
 
             if (lane_id >= offset)
                 num_pts += n;
         }
 
         if (lane_id < NUM_WARPS_PER_BLOCK)
             s_num_pts[warp_id][lane_id] = num_pts;
     }
 
     __syncthreads();
 
     // Compute global offsets.
     if (warp_id == 0)
     {
         int sum = s_num_pts[0][NUM_WARPS_PER_BLOCK-1];
 
         for (int row = 1 ; row < 4 ; ++row)
         {
             int tmp = s_num_pts[row][NUM_WARPS_PER_BLOCK-1];
 
             if (lane_id < NUM_WARPS_PER_BLOCK)
                 s_num_pts[row][lane_id] += sum;
 
             sum += tmp;
         }
     }
 
     __syncthreads();
 
     // Make the scan exclusive.
     if (threadIdx.x < 4*NUM_WARPS_PER_BLOCK)
     {
         int val = threadIdx.x == 0 ? 0 : smem[threadIdx.x-1];
         val += node.points_begin();
         smem[threadIdx.x] = val;
     }
 
     __syncthreads();
 
     //
     // 4- Move points.
     //
 
     // Output points.
     Points &out_points = points[(params.point_selector+1) % 2];
 
     // Reorder points.
     for (int range_it = range_begin + lane_id ; __any(range_it < range_end) ; range_it += warpSize)
     {
         // Is it still an active thread?
         bool is_active = range_it < range_end;
 
         // Load the coordinates of the point.
         float2 p = is_active ? in_points.get_point(range_it) : make_float2(0.0f, 0.0f);
 
         // Count top-left points.
         bool pred = is_active && p.x < center.x && p.y >= center.y;
         int vote = __ballot(pred);
         int dest = s_num_pts[0][warp_id] + __popc(vote & lane_mask_lt);
 
         if (pred)
             out_points.set_point(dest, p);
 
         if (lane_id == 0)
             s_num_pts[0][warp_id] += __popc(vote);
 
         // Count top-right points.
         pred = is_active && p.x >= center.x && p.y >= center.y;
         vote = __ballot(pred);
         dest = s_num_pts[1][warp_id] + __popc(vote & lane_mask_lt);
 
         if (pred)
             out_points.set_point(dest, p);
 
         if (lane_id == 0)
             s_num_pts[1][warp_id] += __popc(vote);
 
         // Count bottom-left points.
         pred = is_active && p.x < center.x && p.y < center.y;
         vote = __ballot(pred);
         dest = s_num_pts[2][warp_id] + __popc(vote & lane_mask_lt);
 
         if (pred)
             out_points.set_point(dest, p);
 
         if (lane_id == 0)
             s_num_pts[2][warp_id] += __popc(vote);
 
         // Count bottom-right points.
         pred = is_active && p.x >= center.x && p.y < center.y;
         vote = __ballot(pred);
         dest = s_num_pts[3][warp_id] + __popc(vote & lane_mask_lt);
 
         if (pred)
             out_points.set_point(dest, p);
 
         if (lane_id == 0)
             s_num_pts[3][warp_id] += __popc(vote);
     }
 
     __syncthreads();
 
     //
     // 5- Launch new blocks.
     //
 
     // The last thread launches new blocks.
     if (threadIdx.x == NUM_THREADS_PER_BLOCK-1)
     {
         // The children.
         Quadtree_node *children = &nodes[params.num_nodes_at_this_level - (node.id() & ~3)];
 
         // The offsets of the children at their level.
         int child_offset = 4*node.id();
 
         // Set IDs.
         children[child_offset+0].set_id(4*node.id() + 0);
         children[child_offset+1].set_id(4*node.id() + 1);
         children[child_offset+2].set_id(4*node.id() + 2);
         children[child_offset+3].set_id(4*node.id() + 3);
 
         // Points of the bounding-box.
         const float2 &p_min = bbox.get_min();
         const float2 &p_max = bbox.get_max();
 
         // Set the bounding boxes of the children.
         children[child_offset+0].set_bounding_box(p_min.x , center.y, center.x, p_max.y);    // Top-left.
         children[child_offset+1].set_bounding_box(center.x, center.y, p_max.x , p_max.y);    // Top-right.
         children[child_offset+2].set_bounding_box(p_min.x , p_min.y , center.x, center.y);   // Bottom-left.
         children[child_offset+3].set_bounding_box(center.x, p_min.y , p_max.x , center.y);   // Bottom-right.
 
         // Set the ranges of the children.
         children[child_offset+0].set_range(node.points_begin(),   s_num_pts[0][warp_id]);
         children[child_offset+1].set_range(s_num_pts[0][warp_id], s_num_pts[1][warp_id]);
         children[child_offset+2].set_range(s_num_pts[1][warp_id], s_num_pts[2][warp_id]);
         children[child_offset+3].set_range(s_num_pts[2][warp_id], s_num_pts[3][warp_id]);
 
         // Launch 4 children.
         build_quadtree_kernel<NUM_THREADS_PER_BLOCK><<<4, NUM_THREADS_PER_BLOCK, 4 *NUM_WARPS_PER_BLOCK *sizeof(int)>>>(&children[child_offset], points, Parameters(params, true));
     }
 }
 
 ////////////////////////////////////////////////////////////////////////////////
 // Make sure a Quadtree is properly defined.
 ////////////////////////////////////////////////////////////////////////////////
 bool check_quadtree(const Quadtree_node *nodes, int idx, int num_pts, Points *pts, Parameters params)
 {
     const Quadtree_node &node = nodes[idx];
     int num_points = node.num_points();
     const Bounding_box &bbox = node.bounding_box();
 
     for (int it = node.points_begin() ; it < node.points_end() ; ++it)
     {
         if (it >= num_pts)
             return false;
 
         float2 p = pts->get_point(it);
 
         if (!bbox.contains(p))
             return false;
     }
 
     if (!(params.depth == params.max_depth || num_points <= params.min_points_per_node))
     {
         int sum = 0;
         for (int i = 0; i < 4; i++) {
             sum += nodes[4 * idx + params.num_nodes_at_this_level + i].num_points();
         }
 
         if (sum != num_points) {
             printf("[%d] node supposed to have %d points but children have %d\n", params.depth, num_points, sum);
         }
         return check_quadtree(&nodes[params.num_nodes_at_this_level], 4*idx+0, num_pts, pts, Parameters(params, true)) &&
                check_quadtree(&nodes[params.num_nodes_at_this_level], 4*idx+1, num_pts, pts, Parameters(params, true)) &&
                check_quadtree(&nodes[params.num_nodes_at_this_level], 4*idx+2, num_pts, pts, Parameters(params, true)) &&
                check_quadtree(&nodes[params.num_nodes_at_this_level], 4*idx+3, num_pts, pts, Parameters(params, true));
     }
 
     return true;
 }
 
 ////////////////////////////////////////////////////////////////////////////////
 // Allocate GPU structs, launch kernel and clean up
 ////////////////////////////////////////////////////////////////////////////////
 bool cdpQuadtree(float width, float height, float *xs, float *ys, float *ws, int num_points,
     Quadtree_node* nodes, Points* points)
 {
 
     // Find/set the device.
     // The test requires an architecture SM35 or greater (CDP capable).
     int cuda_device = findCudaDevice(1, NULL);
     cudaDeviceProp deviceProps;
     checkCudaErrors(cudaGetDeviceProperties(&deviceProps, cuda_device));
     int cdpCapable = (deviceProps.major == 3 && deviceProps.minor >= 5) || deviceProps.major >=4;
 
     printf("GPU device %s has compute capabilities (SM %d.%d)\n", deviceProps.name, deviceProps.major, deviceProps.minor);
 
     if (!cdpCapable)
     {
         std::cerr << "cdpQuadTree requires SM 3.5 or higher to use CUDA Dynamic Parallelism.  Exiting...\n" << std::endl;
         exit(EXIT_WAIVED);
     }
 
     int warp_size = deviceProps.warpSize;
 
     // Constants to control the algorithm.
     const int max_depth  = 12;
     const int min_points_per_node = 64;
 
     // Allocate memory for points.
     thrust::device_vector<float> x_d0(&xs[0], &xs[num_points]);
     thrust::device_vector<float> x_d1(num_points);
     thrust::device_vector<float> y_d0(&ys[0], &ys[num_points]);
     thrust::device_vector<float> y_d1(num_points);
 
     // Host structures to analyze the device ones.
     Points points_init[2];
     points_init[0].set(thrust::raw_pointer_cast(&x_d0[0]), thrust::raw_pointer_cast(&y_d0[0]));
     points_init[1].set(thrust::raw_pointer_cast(&x_d1[0]), thrust::raw_pointer_cast(&y_d1[0]));
 
     // Allocate memory to store points.
     //Points *points;
     checkCudaErrors(cudaMalloc((void **) &points, 2*sizeof(Points)));
     checkCudaErrors(cudaMemcpy(points, points_init, 2*sizeof(Points), cudaMemcpyHostToDevice));
 
     // We could use a close form...
     int max_nodes = 0;
 
     for (int i = 0, num_nodes_at_level = 1 ; i < max_depth ; ++i, num_nodes_at_level *= 4)
         max_nodes += num_nodes_at_level;
 
     // Allocate memory to store the tree.
     Quadtree_node root;
     root.set_range(0, num_points);
     root.set_bounding_box(0, 0, width, height);
     //Quadtree_node *nodes;
     checkCudaErrors(cudaMalloc((void **) &nodes, max_nodes*sizeof(Quadtree_node)));
     checkCudaErrors(cudaMemcpy(nodes, &root, sizeof(Quadtree_node), cudaMemcpyHostToDevice));
 
     // We set the recursion limit for CDP to max_depth.
     cudaDeviceSetLimit(cudaLimitDevRuntimeSyncDepth, max_depth);
 
     // Build the quadtree.
     Parameters params(max_depth, min_points_per_node);
     std::cout << "Launching CDP kernel to build the quadtree" << std::endl;
     const int NUM_THREADS_PER_BLOCK = 128; // Do not use less than 128 threads.
     const int NUM_WARPS_PER_BLOCK = NUM_THREADS_PER_BLOCK / warp_size;
     const size_t smem_size = 4*NUM_WARPS_PER_BLOCK*sizeof(int);
     build_quadtree_kernel<NUM_THREADS_PER_BLOCK><<<1, NUM_THREADS_PER_BLOCK, smem_size>>>(nodes, points, params);
     checkCudaErrors(cudaGetLastError());
 
     /*
     // Copy points to CPU.
     thrust::host_vector<float> x_h(x_d0);
     thrust::host_vector<float> y_h(y_d0);
     Points host_points;
     host_points.set(thrust::raw_pointer_cast(&x_h[0]), thrust::raw_pointer_cast(&y_h[0]));
 
     // Copy nodes to CPU.
     Quadtree_node *host_nodes = new Quadtree_node[max_nodes];
     checkCudaErrors(cudaMemcpy(host_nodes, nodes, max_nodes *sizeof(Quadtree_node), cudaMemcpyDeviceToHost));
 
     // Validate the results.
     bool ok = check_quadtree(host_nodes, 0, num_points, &host_points, params);
     std::cout << "Results: " << (ok ? "OK" : "FAILED") << std::endl;
     
     // Free CPU memory.
     delete[] host_nodes;
 
     // Free memory.
     checkCudaErrors(cudaFree(nodes));
     checkCudaErrors(cudaFree(points));
     */
     return true;
 }
 
 ////////////////////////////////////////////////////////////////////////////////
 // Main entry point.
 ////////////////////////////////////////////////////////////////////////////////
 /*int main(int argc, char **argv)*/
 /*{*/
     /*// Find/set the device.*/
     /*// The test requires an architecture SM35 or greater (CDP capable).*/
     /*int cuda_device = findCudaDevice(argc, (const char **)argv);*/
     /*cudaDeviceProp deviceProps;*/
     /*checkCudaErrors(cudaGetDeviceProperties(&deviceProps, cuda_device));*/
     /*int cdpCapable = (deviceProps.major == 3 && deviceProps.minor >= 5) || deviceProps.major >=4;*/
 
     /*printf("GPU device %s has compute capabilities (SM %d.%d)\n", deviceProps.name, deviceProps.major, deviceProps.minor);*/
 
     /*if (!cdpCapable)*/
     /*{*/
         /*std::cerr << "cdpQuadTree requires SM 3.5 or higher to use CUDA Dynamic Parallelism.  Exiting...\n" << std::endl;*/
         /*exit(EXIT_WAIVED);*/
     /*}*/
 
     /*bool ok = cdpQuadtree(deviceProps.warpSize);*/
 
     /*return (ok ? EXIT_SUCCESS : EXIT_FAILURE);*/
 /*}*/


clock_t start_cuda;

__device__ void traverse(Quadtree_node *nodes, int idx, float *buf, Bounding_box box, 
    Points *pts, Parameters params, float pt_x, float pt_y, float x_reso, float y_reso,
    float* stamp)
{
    Quadtree_node* current = &nodes[idx];
    const Bounding_box &curr_box = current->bounding_box();
    if (!box.overlaps(curr_box)) {
        return;
    }

    printf("entered\n");
    int x_dist, y_dist;
    float2 p_min = curr_box.get_min();
    float2 p_max = curr_box.get_max();
    if (box.contains(p_max) && box.contains(p_min)) 
    {
        if (floor((p_min.x - pt_x + x_reso/2) / x_reso) ==
            floor((p_max.x - pt_x + x_reso/2) / x_reso) &&
            floor((p_min.y - pt_y + y_reso/2) / y_reso) ==
            floor((p_max.y - pt_y + y_reso/2) / y_reso)) {
            x_dist = (int)floor((p_min.x - pt_x + x_reso/2) / x_reso);
            y_dist = (int)floor((p_min.y - pt_y + y_reso/2) / y_reso);
            x_dist = x_dist > 4 ? 4 : x_dist;
            x_dist = x_dist < -4 ? -4 : x_dist;
            y_dist = y_dist > 4 ? 4 : y_dist;
            y_dist = y_dist < -4 ? -4 : y_dist;
            *buf = *buf + current->num_points() * stamp[9*(4 + y_dist) + (4 + x_dist)];
            printf("added\n");
        }
        return;
    }

    printf("entered2\n");
    if (params.depth == params.max_depth || current->num_points() <= params.min_points_per_node)
    {
        for (int it = current->points_begin() ; it < current->points_end() ; ++it)
        {
            float2 p = pts->get_point(it);
            if (box.contains(p)) {
                x_dist = (int)floor((p.x - pt_x + x_reso/2) / x_reso);
                y_dist = (int)floor((p.y - pt_y + y_reso/2) / y_reso); 
                *buf = *buf + stamp[9*(4 + y_dist) + (4 + x_dist)];
                printf("added\n");
            }
        }
        return;
    }
    traverse(&nodes[params.num_nodes_at_this_level], 4*idx+0, buf, box, pts, Parameters(params, true),
        pt_x, pt_y, x_reso, y_reso, stamp);
    traverse(&nodes[params.num_nodes_at_this_level], 4*idx+1, buf, box, pts, Parameters(params, true),
        pt_x, pt_y, x_reso, y_reso, stamp);
    traverse(&nodes[params.num_nodes_at_this_level], 4*idx+2, buf, box, pts, Parameters(params, true),
        pt_x, pt_y, x_reso, y_reso, stamp);
    traverse(&nodes[params.num_nodes_at_this_level], 4*idx+3, buf, box, pts, Parameters(params, true),
        pt_x, pt_y, x_reso, y_reso, stamp);
}

__global__ void renderNewPointsKernel(float x0, float y0, float w, float h, 
    int W, int H, float* buf, Quadtree_node* nodes, Points* points,
    float pt_width, float pt_height, float* stamp)
{
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    float x_reso = w / W;
    float y_reso = h / H;
    for (int i = idx; i < W * H; i += blockDim.x * gridDim.x) {
        buf[i] = 0;
        float pt_x = x0 + (i%W + 0.5) * x_reso;
        float pt_y = y0 + (i/W + 0.5) * y_reso;
        Bounding_box region;
        region.set(pt_x - pt_width/2, pt_y - pt_height/2,
            pt_x + pt_width/2, pt_y + pt_height/2);
        Parameters params(12, 64);
        traverse(nodes, 0, buf+i, region, points, params, pt_x, pt_y, x_reso, y_reso, stamp);
    }
}

__global__ void reduceMaxKernel(float* src, float* dst, int n)
{
    extern __shared__ float sdata[];

    int blockSize = blockDim.x;
    int tid = threadIdx.x;
    int i = blockIdx.x * (blockSize * 2) + tid;
    int gridSize = blockSize * 2 * gridDim.x;
    sdata[tid] = 0;
    float temp = 0;

    while (i < n - blockSize) {
        temp = src[i] > src[i + blockSize] ? src[i] : src[i + blockSize];
        sdata[tid] = sdata[tid] > temp ? sdata[tid] : temp;
        i += gridSize;
    }
    while (i < n) {
        sdata[tid] = sdata[tid] > src[i] ? sdata[tid] : src[i]; 
    }
    __syncthreads();

    int startSize = 512;
    while (startSize > warpSize) {
        if (blockSize > startSize) {
            if (tid < startSize/2) { sdata[tid] = sdata[tid] > sdata[tid + startSize/2] ? sdata[tid] : sdata[tid + startSize/2]; }
            __syncthreads();
        }
        startSize /= 2;
    }

    // assuming a warpSize of 32
    if (tid < 32) {
        if (blockSize >= 64) {
            sdata[tid] = sdata[tid] > sdata[tid + 32] ? sdata[tid] : sdata[tid + 32];
        }
        if (blockSize >= 32) {
            sdata[tid] = sdata[tid] > sdata[tid + 16] ? sdata[tid] : sdata[tid + 16];
        }
        if (blockSize >= 16) {
            sdata[tid] = sdata[tid] > sdata[tid + 8] ? sdata[tid] : sdata[tid + 8];
        }
        if (blockSize >= 8) {
            sdata[tid] = sdata[tid] > sdata[tid + 4] ? sdata[tid] : sdata[tid + 4];
        }
        if (blockSize >= 4) {
            sdata[tid] = sdata[tid] > sdata[tid + 2] ? sdata[tid] : sdata[tid + 2];
        }
        if (blockSize >= 2) {
            sdata[tid] = sdata[tid] > sdata[tid + 1] ? sdata[tid] : sdata[tid + 1];
        }
    }

    if (tid == 0) dst[blockIdx.x] = sdata[0];

    return;
}

__global__ void writeToImageKernel(float* weights, unsigned char* color, int num_pixels,
    int max_weight, const heatmap_colorscheme_t* colorscheme)
{
    int idx = threadIdx.x + blockDim.x * blockIdx.x;

    for (int i = idx; i < num_pixels; i += blockDim.x * gridDim.x) {
        float val = weights[i] / (float)max_weight;
        size_t color_idx = (size_t)((float)(colorscheme->ncolors-1)*val + 0.5f);
        color[4*i] = (colorscheme->colors)[color_idx*4];
        color[4*i+1] = (colorscheme->colors)[color_idx*4+1];
        color[4*i+2] = (colorscheme->colors)[color_idx*4+2];
        color[4*i+3] = (colorscheme->colors)[color_idx*4+3];
    }
}

void cudaInit()
{
    cudaMalloc(&pixel_weights, renderH * renderW * sizeof(float));
    cudaMalloc(&pixel_color, renderH * renderW * sizeof(unsigned char));
    cudaMalloc(&cuda_stamp, 81 * sizeof(float));
    //cudaMalloc(&max_buf, 1 * sizeof(float));
    //cudaMalloc(&sizes, 2 * sizeof(int));

    cudaMemcpy((void *)cuda_stamp, (void *)stamp,
        81 * sizeof(float), cudaMemcpyHostToDevice);
    //cudaMemcpy((void *)pixel_weights, (void *)hm->buf,
    //    renderH * renderW * sizeof(float), cudaMemcpyHostToDevice);
}

__global__ void tempMax(float* src, float* dst, int n)
{
    int idx = threadIdx.x + blockDim.x * blockIdx.x;
    float &max_weight = dst[0];
    if (idx == 0) {
        for (int i = 0; i < n; i++) {
            max_weight = max_weight > src[i] ? max_weight : src[i];
        }
    }
}

void renderNewPointsCUDA(float x0, float y0, float w, float h,
    std::string filename, float* stamp)
{
    printf("Here3\n");
    start_cuda = std::clock();
    float pt_width = w * 9 / renderW;
    float pt_height = h * 9 / renderH;

    printf("Here3\n");
    renderNewPointsKernel<<<128, 128>>>(x0, y0, w, h, renderW, renderH,
        pixel_weights, cuda_nodes, cuda_points, pt_width, pt_height, stamp);

    // get the maximum value of all weigths
    float max_weight;
    //tempMax<<<1, 1>>>(pixel_weights, max_buf, renderH * renderW);
    //cudaMemcpy((void *)&max_weight, (void *)max_buf, 1 * sizeof(float), cudaMemcpyDeviceToHost);

    printf("Here4\n");
    cudaMalloc(&max_buf, 1 * sizeof(float));

    int npixel = renderH * renderW;
    reduceMaxKernel<<<1, 512, 512 * sizeof(float)>>>(pixel_weights, max_buf, npixel);
    cudaMemcpy((void *)&max_weight, (void *)max_buf, 1 * sizeof(float), cudaMemcpyDeviceToHost);

    writeToImageKernel<<<128, 128>>>(pixel_weights, pixel_color, npixel, max_weight, heatmap_cs_default);
    cudaDeviceSynchronize();
    std::cout << (std::clock() - start_cuda) * 1000  / (double) CLOCKS_PER_SEC << " ms\n";
    cudaMemcpy((void *)ppmOutput->data, (void *)pixel_color,
        npixel * sizeof(unsigned char), cudaMemcpyDeviceToHost);
    writePPMImage(ppmOutput, filename);
}