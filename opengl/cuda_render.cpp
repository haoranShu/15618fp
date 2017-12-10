#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#include <iostream>
#include <fstream>
#include <random>
#include <vector>

#include "gl_utility.h"

std::vector<unsigned char> image;
int npoints;
float* xs;
float* ys;
float* ws;
heatmap_t* hm;
int renderW, renderH;
float width, height;
Quad* leveledPts;

int main(int argc, char** argv)
{

    if (argc != 3) {
        return -1;
    } else {
        renderW = std::atoi(argv[1]);
        renderH = std::atoi(argv[2]);
        image.resize(renderW * renderH * 4);
        hm = heatmap_new(renderW, renderH);
    }

    std::cin >> npoints;

    int weighted;
    std::cin >> weighted;
    std::cin >> width >> height;

    leveledPts = new Quad(Point(0, 0), Point(width, height));
    float x, y, w;

    if (weighted == 0) {
        for (int i = 0; i < npoints; i++) {
            std::cin >> x >> y;
            Point p(x, y, 1.0f);
            leveledPts->insert(p);
        }
    } else {
        for (int i = 0; i < npoints; i++) {
            std::cin >> x >> y >> w;
            Point p(x, y, w);
            leveledPts->insert(p);
        }
    }

    /* TODO: CUDA codes
    */
    cudaMalloc(&cuda_texture, sizeof(unsigned char) * renderW * renderH);

    return 0;
}
