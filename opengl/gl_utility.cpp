#include "gl_utility.h"

float scale = 0.0f;
float curr_scale = 0.0f;
std::vector<unsigned char> image{};

void setupTexture()
{
    GLuint id;
    glGenTextures(1, &id);
    glBindTexture(GL_TEXTURE_2D, id);

    //glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, 256, 512, 0, GL_RGBA, GL_UNSIGNED_BYTE, (GLvoid*)(&image[0]));

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);

    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, 256, 512, 0, GL_RGBA, GL_UNSIGNED_BYTE, (GLvoid*)(&image[0]));
    glGenerateMipmap(GL_TEXTURE_2D);
    glBindTexture(GL_TEXTURE_2D, id);
}

void renderScene()
{
    glClear(GL_COLOR_BUFFER_BIT);

    // glDrawPixels(256, 512, GL_RGBA, GL_UNSIGNED_BYTE, &image[0]);

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
            scale = 1.1f;
            curr_scale *= scale;
            glScalef(scale, scale, scale);
        }
    } else if (button == GLUT_RIGHT_BUTTON) {
        if (state == GLUT_DOWN && curr_scale > 1) {
            scale = 1/1.1f;
            curr_scale *= scale;
            glScalef(scale, scale, scale);
        }
    }
}
