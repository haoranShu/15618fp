#ifndef GL_UTILITY_H
#define GL_UTILITY_H

/*
 *  Contains all OpenGL utilities needed.
 */

#include <vector>

#include <OpenGL/gl.h>
#include <OpenGL/glu.h>
#include <GLUT/glut.h>

#include "heatmap.h"

extern float scale;
extern float curr_scale;
extern std::vector<unsigned char> image;
extern int npoints;
extern float* xs;
extern float* ys;
extern float* ws;
extern heatmap_t* hm;
extern int renderW, renderH;
extern float width, height;

void renderNewPoints(float x0, float y0, float w, float h);

void setupTexture();

void updateTexture();

void renderScene();

void zooming(int button, int state, int x, int y);

#endif /* GL_UTILITY_H */
