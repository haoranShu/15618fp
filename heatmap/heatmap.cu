#include <iostream>
#include <vector>
#include <math.h>

#include "heatmap.h"

__global__ void KDE_renderer_kernel(float* hm, unsigned w, unsigned h,
                                    float* xs, float* ys, float* ws, unsigned num_points,
                                    float x_min, float x_max, float y_min, float y_max,
                                    float KDE_sd)
{
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    int total_ths = blockDim.x * gridDim.x;

    float x_norm, y_norm;
    float x_range = x_max - x_min;
    float y_range = y_max - y_min;
    float exp_scalar = - 1 / (2 * KDE_sd * KDE_sd);
    float scalar = 1 / (KDE_sd * sqrt(2 * M_PI));
    float hx = idx % w;
    float hy = idx / w;
    for (int i = idx; i < w * h; i += total_ths) {
        for (int j = 0; j < num_points; j++) {
            x_norm = (xs[j] - x_min) / x_range * w - hx;
            y_norm = (ys[j] - y_min) / y_range * h - hy;
            hm[i] += ws[j] * exp((x_norm * x_norm + y_norm * y_norm) * exp_scalar);
        }
        hm[i] *= scalar;
    }
}

void cudaKDE_renderer(heatmap_t* h, float* xs, float* ys, float* ws, unsigned num_points,
                      float x_min, float x_max, float y_min, float y_max, float KDE_sd)
{
    float* cudaH_buf;
    float* cuda_xs;
    float* cuda_ys;
    float* cuda_ws;

    cudaMalloc(&cudaH_buf, sizeof(float) * h->w * h->h);
    cudaMalloc(&cuda_xs, sizeof(float) * num_points);
    cudaMalloc(&cuda_ys, sizeof(float) * num_points);
    cudaMalloc(&cuda_ws, sizeof(float) * num_points);

    cudaMemset(cudaH_buf, 0, sizeof(float) * h->w * h->h);
    cudaMemcpy(cuda_xs, xs, sizeof(float) * num_points, cudaMemcpyHostToDevice);
    cudaMemcpy(cuda_ys, ys, sizeof(float) * num_points, cudaMemcpyHostToDevice);
    cudaMemcpy(cuda_ws, ws, sizeof(float) * num_points, cudaMemcpyHostToDevice);

    KDE_renderer_kernel<<<1024, 1024>>>(cudaH_buf, h->w, h->h, cuda_xs, cuda_ys, cuda_ws,
                                      num_points, x_min, x_max, y_min, y_max, KDE_sd);

    cudaMemcpy(h->buf, cudaH_buf, sizeof(float) * h->w * h->h, cudaMemcpyDeviceToHost);
    cudaDeviceSynchronize();
}
