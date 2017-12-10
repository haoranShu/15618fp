#include <string>
#include <ctime>
#include <iostream>
#include <stdio.h>

#include <cuda.h>
#include <cuda_runtime.h>

#include "cuda_renderer.h"
#include "cdpQuadtree.h"

clock_t start_cuda;

__device__ void traverse(Quadtree_node* nodes, float* weight,
    float pt_width, float pt_height, float pt_x, float pt_y)
{

}

__global__ void renderNewPointsKernel(float x0, float y0, float w, float h, 
    int W, int H, float* buf, Quadtree_node* nodes, float pt_width, float pt_height)
{
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    for (int i = idx; i < W * H; i += blockDim.x * gridDim.x) {
        buf[i] = 0;
        float pt_x = x0 + (i%W + 0.5) * w / W;
        float pt_y = y0 + (i/W + 0.5) * h / H;
        traverse(nodes, buf+i, pt_width, pt_height, pt_x, pt_y);
    }
}

template <int blockSize>
__global__ void reduceMaxKernel(float* src, float* dst, int n)
{
    extern __shared__ float sdata[];

    int tid = threadIdx.x;
    int i = blockIdx.x * (blockSize * 2) + tid;
    int gridSize = blockSize * 2 * gridDim.x;
    sdata[tid] = 0;

    while (i < n) {
        sdata[tid] = src[i] > src[i + blockSize] ? src[i] : src[i + blockSize];
        i += gridSize;
    }
    __syncthreads();

    int startSize = 512;
    while (startSize > warpSize) {
        if (blockSize > startSize) {
            if (tid < startSize/2) { sdata[tid] = src[tid] > src[tid + startSize/2] ? src[tid] : src[tid + startSize/2]; }
            __syncthreads();
        }
        startSize /= 2;
    }

    // assuming a warpSize of 32
    if (tid < 32) {
        if (blockSize >= 64) {
            sdata[tid] = src[tid] > src[tid + 32] ? src[tid] : src[tid + 32];
        }
        if (blockSize >= 32) {
            sdata[tid] = src[tid] > src[tid + 16] ? src[tid] : src[tid + 16];
        }
        if (blockSize >= 16) {
            sdata[tid] = src[tid] > src[tid + 8] ? src[tid] : src[tid + 8];
        }
        if (blockSize >= 8) {
            sdata[tid] = src[tid] > src[tid + 4] ? src[tid] : src[tid + 4];
        }
        if (blockSize >= 4) {
            sdata[tid] = src[tid] > src[tid + 2] ? src[tid] : src[tid + 2];
        }
        if (blockSize >= 2) {
            sdata[tid] = src[tid] > src[tid + 1] ? src[tid] : src[tid + 1];
        }
    }

    if (tid == 0) dst[blockIdx.x] = sdata[0];
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
    //cudaMalloc(&max_buf, 1 * sizeof(float));
    cudaMalloc(&sizes, 2 * sizeof(int))

    cudaMemcpy((void *)pixel_weights, (void *)hm->buf,
        renderH * renderW * sizeof(float), cudaMemcpyHostToDevice);
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

void shrink(int n, int* sizes)
{
    int &g = sizes[0];
    int &b = sizes[1];
    if (n <= 2 * b) {
        g = 1;
        while (b > n) b >>= 1;
    } else {
        int m = (n + (b - 1)) / b;
        while (g > m) g >>= 1;
    }
}

void renderNewPointsCUDA(float x0, float y0, float w, float h, std::string filename,
    int* sizes)
{
    start_cuda = std::clock();
    float pt_width = w * 9 / renderW;
    float pt_height = h * 9 / renderH;
    //renderNewPointsKernel<<<128, 128>>>(x0, y0, w, h, renderW, renderH,
    //    pixel_weights, nodes, pt_width, pt_height);

    // get the maximum value of all weigths
    float max_weight;
    //tempMax<<<1, 1>>>(pixel_weights, max_buf, renderH * renderW);
    //cudaMemcpy((void *)&max_weight, (void *)max_buf, 1 * sizeof(float), cudaMemcpyDeviceToHost);
    
    int npixel = renderH * renderW;
    shrink(npixel, sizes);
    cudaMalloc(&max_buf, (sizes[0] + sizes[0] >> 1) * sizeof(float));

    int slen = sizes[0];
    float* ps = pixel_weights;
    int smemSize = 0;
    if (slen > 1) {
        float* pd = max_buf + sizes[0];
        do {
            shrink(slen, sizes);
            smemSize = sizes[1] * sizeof(float);
            reduceMaxKernel<<<sizes[0], sizes[1], smemSize>>>(ps, pd, sizes[0]);
            float *pt = ps;
            ps = pd;
            pd = pt;
        } while (slen > 1);
    }

    max_weight = ps[0];

    cudaDeviceSynchronize();
    start_cuda = std::clock();
    writeToImageKernel<<<128, 128>>>(pixel_weights, pixel_color, npixel, max_weight, heatmap_cs_default);
    cudaDeviceSynchronize();
    std::cout << (std::clock() - start_cuda) * 1000  / (double) CLOCKS_PER_SEC << " ms\n";
    cudaMemcpy((void *)ppmOutput->data, (void *)pixel_color,
        npixel * sizeof(unsigned char), cudaMemcpyDeviceToHost);
    writePPMImage(ppmOutput, filename);
}