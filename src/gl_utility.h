#ifndef GL_UTILITY_H
#define GL_UTILITY_H

/*
 *  Contains all OpenGL utilities needed.
 */

#ifdef __APPLE__

#include <OpenGL/gl.h>
#include <OpenGL/glu.h>
#include <GLUT/glut.h>

#else

#include <GL/gl.h>
#include <GL/glu.h>
#include <GL/glut.h>

#endif

#include "general.h"

void setupTexture();

void updateTexture();

void renderScene();

void zooming(int button, int state, int x, int y);

#endif /* GL_UTILITY_H */