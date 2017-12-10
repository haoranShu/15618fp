#ifndef GENERAL_H
#define GENERAL_H

#include <vector>
#include <string>

#include "cdpQuadtree.h"
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
extern Quadtree_node* cuda_nodes;
extern Points* cuda_points;
extern float* pixel_weights;
extern unsigned char* pixel_color;
extern float* max_buf;

extern float stamp[81];
extern float* cuda_stamp;
extern unsigned char *cuda_colors;

#endif /* GENERAL_H */
