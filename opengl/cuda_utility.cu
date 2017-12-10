#include <string>
#include <ctime>
#include <iostream>

#include "gl_utility.h"

clock_t start;

__global__ void renderNewPointsKernel(float x0, float y0, float w, float h, 
    int W, int H, float* buf, Quadtree_node* nodes, Points *pts, float pt_width, float pt_height)
{
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    for (int i = idx; i < W * H; i += blockDim.x * gridDim.x) {
        buf[i] = 0;
        float pt_x = x0 + (i%W + 0.5) * w / W;
        float pt_y = y0 + (i/W + 0.5) * h / H;

        Bounding_box box();
        region.set(pt_x, pt_y, pt_x + pt_width, pt_y + pt_height);
        Parameters params(12, 64);
        traverse(nodes, 0, &buf[i], region, pts, params);
    }
}

__device__ 
void traverse(Quadtree_node *nodes, int idx, float *buf, Bounding_box &box, 
        Points *pts, Parameters params)
{
    Quadtree_node current = nodes[idx];
    if (!box.overlaps(current.bounding_box()))
        return;

    if (box.contains(current.bounding_box())) 
    {
         *buf = *buf + current.num_points();
         return;
    }

    if (params.depth == params.max_depth || current.num_points() <= params.min_points_per_node)
    {
        for (int it = node.points_begin() ; it < node.points_end() ; ++it)
        {
            float2 p = pts->get_point(it);
            if (!box.contains(p))
                *buf = *buf + 1;
        }
        return;
    }
    traverse(&nodes[params.num_nodes_at_this_level], 4*idx+0, buf, box, pts, Parameters(params, true));
    traverse(&nodes[params.num_nodes_at_this_level], 4*idx+1, buf, box, pts, Parameters(params, true));
    traverse(&nodes[params.num_nodes_at_this_level], 4*idx+2, buf, box, pts, Parameters(params, true));
    traverse(&nodes[params.num_nodes_at_this_level], 4*idx+3, buf, box, pts, Parameters(params, true));
}

__global__ void writeToImageKernel(float* weights, float* color, int num_pixels)
{

}

void renderNewPointsCUDA(float x0, float y0, float w, float h, std::string filename)
{
    start = std::clock();
    float pt_width = w * 9 / renderW;
    float pt_height = h * 9 / renderH;
    renderNewPointsKernel<<<128, 128>>>(x0, y0, w, h, renderW, renderH,
        pixel_weights, nodes, pt_width, pt_height);
    writeToImageKernel<<<128, 128>>>(pixel_weights, pixel_color, renderH * renderW);

    std::cout << (std::clock() - start) * 1000  / (double) CLOCKS_PER_SEC << " ms\n";
    cudaMemcpy((void *)ppmOutput->data, (void *)pixel_color,
        renderH * renderW * sizeof(unsigned char), cudaMemcpyDeviceToHost);
    writePPMImage(ppmOutput, filename);
}

void setupTextureCUDA()
{

}

void renderSceneCUDA()
{
    
}

void zoomingCUDA(int button, int state, int x, int y)
{

}
