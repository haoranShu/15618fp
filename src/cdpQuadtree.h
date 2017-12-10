#include <thrust/random.h>
#include <thrust/device_vector.h>
#include <helper_cuda.h>

////////////////////////////////////////////////////////////////////////////////
// A structure of 2D points (structure of arrays).
////////////////////////////////////////////////////////////////////////////////
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

bool cdpQuadtree(float, float, float *, float *, float *, int);