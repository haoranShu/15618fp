#include <string>
#include <ctime>
#include <iostream>

#include "gl_utility.h"

clock_t start;

__global__ void renderNewPointsKernel(float x0, float y0, float w, float h, 
    int W, int H, float* buf, Quadtree_node* nodes, float pt_width, float pt_width)
{
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    for (int i = idx; i < W * H; i += blockDim.x * gridDim.x) {
        buf[i] = 0;
        float pt_x = x0 + (i%W + 0.5) * w / W;
        float pt_y = y0 + (i/W + 0.5) * h / H;
        traverse(nodes, buf+i, pt_width, pt_height, pt_x, pt_y);
    }
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