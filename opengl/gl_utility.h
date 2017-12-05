#ifndef GL_UTILITY_H
#define GL_UTILITY_H

/*
 *  Contains all OpenGL utilities needed.
 */

#include <vector>

#include <OpenGL/gl.h>
#include <OpenGL/glu.h>
#include <GLUT/glut.h>

extern float scale;
extern float curr_scale;
extern std::vector<unsigned char> image;

void setupTexture();

void updateTexture();

void renderScene();

void zooming(int button, int state, int x, int y);

#endif /* GL_UTILITY_H */
