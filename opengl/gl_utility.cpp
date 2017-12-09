#include <math.h>
#include <iostream>
#include <string>
#include <ctime>

#include "gl_utility.h"

using namespace std;

float scale = 1.0f;
float curr_scale = 1.0f;

float g_x0 = 0;
float g_y0 = 0;

clock_t start;

void renderNewPoints(float x0, float y0, float w, float h, string filename)
{
    start = clock();
    memset(hm->buf, 0, hm->w * hm->h * sizeof(float));
    hm->max = 0;
    float x1 = x0 + w;
    float y1 = y0 + h;

    float x_gap = w / renderW;
    float y_gap = h / renderH;

    Point a(x0, y0);
    Point b(x1, y1);
    leveledPts->search(a, b, x_gap, y_gap);
    heatmap_render_default_to(hm, &image[0]);
    cout << (clock() - start) * 1000  / (double) CLOCKS_PER_SEC << " ms\n";
    heatmap_render_default_to(hm, ppmOutput->data);
    writePPMImage(ppmOutput, filename);
}

void setupTexture()
{
    GLuint id;
    glGenTextures(1, &id);
    glBindTexture(GL_TEXTURE_2D, id);

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);

    renderNewPoints(0, 0, width, height, "output/output.ppm");

    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, renderW, renderH, 0, GL_RGBA, GL_UNSIGNED_BYTE, (GLvoid*)(&image[0]));
    glGenerateMipmap(GL_TEXTURE_2D);
    glBindTexture(GL_TEXTURE_2D, id);
}



void renderScene()
{
    glClear(GL_COLOR_BUFFER_BIT);

    // glTexSubImage2D(GL_TEXTURE_2D, 0 ,0, 0, 256, 512, GL_RGBA, GL_UNSIGNED_BYTE, (GLvoid*)(&image[0]));

    glBegin(GL_QUADS);
        glTexCoord2d(0.0, 0.0);         glVertex2d(-1.0, -1.0);
        glTexCoord2d(1.0, 0.0);         glVertex2d(1.0, -1.0);
        glTexCoord2d(1.0, 1.0);         glVertex2d(1.0, 1.0);
        glTexCoord2d(0.0, 1.0);         glVertex2d(-1.0, 1.0);
    glEnd();

    glutSwapBuffers();
}

void zooming(int button, int state, int x, int y)
{
    if (button == GLUT_LEFT_BUTTON) {
        if (state == GLUT_DOWN) {
            g_x0 = g_x0 + width * (((float)x/renderW - 0.5) * 0.5 + 0.5 - 0.45);
            g_y0 = g_y0 + height * ((1-(float)y/renderH - 0.5) * 0.5 + 0.5 - 0.45);
            cout << x << ' ' << y << endl;
            width = width*0.9;
            height = height*0.9;
            renderNewPoints(g_x0, g_y0, width, height, "output/output.ppm");
            glTexSubImage2D(GL_TEXTURE_2D, 0 ,0, 0, renderW, renderH, GL_RGBA, GL_UNSIGNED_BYTE, (GLvoid*)(&image[0]));
        }
    } else if (button == GLUT_RIGHT_BUTTON) {
        if (state == GLUT_DOWN) {
            g_x0 = g_x0 - width * 0.05;
            g_y0 = g_y0 - height * 0.05;
            width = width*1.1;
            height = height*1.1;
            renderNewPoints(g_x0, g_y0, width, height, "output/output.ppm");
            glTexSubImage2D(GL_TEXTURE_2D, 0 ,0, 0, renderW, renderH, GL_RGBA, GL_UNSIGNED_BYTE, (GLvoid*)(&image[0]));
        }
    }
}
