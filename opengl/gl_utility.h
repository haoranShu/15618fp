#ifndef GL_UTILITY_H
#define GL_UTILITY_H

/*
 *  Contains all OpenGL utilities needed.
 */

#include <vector>
#include <string>

#ifdef __APPLE__

#include <OpenGL/gl.h>
#include <OpenGL/glu.h>
#include <GLUT/glut.h>

#else

#include <GL/gl.h>
#include <GL/glu.h>
#include <GL/glut.h>

#endif

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

void renderNewPoints(float x0, float y0, float w, float h, std::string filename);

void renderNewPointsCUDA(float x0, float y0, float w, float h, std::string filename);

void setupTexture();

void setupTextureCUDA();

void updateTexture();

void updateTextureCUDA();

void renderScene();

void renderSceneCUDA();

void zooming(int button, int state, int x, int y);

void zoomingCUDA(int button, int state, int x, int y);

#endif /* GL_UTILITY_H */
