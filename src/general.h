#ifndef GENERAL_H
#define GENERAL_H

#include <vector>
#include <string>

#include "heatmap.h"
#include "quad_tree.h"
#include "image.h"
#include "ppm.h"

extern Image<unsigned char>* ppmOutput;
extern float scale;
extern float curr_scale;
extern std::vector<unsigned char> image;
extern unsigned char * cuda_texture;
extern int npoints;
extern heatmap_t* hm;
extern int renderW, renderH;
extern float width, height;
extern Quad* leveledPts;

// cuda objects
extern float* pixel_weights;
extern unsigned char* pixel_color;
extern float* max_buf;
extern int* sizes;

#endif /* GENERAL_H */