#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#include <iostream>
#include <fstream>
#include <random>
#include <vector>

#include "heatmap.h"
#include "gl_utility.h"

int main(int argc, char** argv)
{
    static const size_t w = 256, h = 512, npoints = 1000;

    // Create the heatmap object with the given dimensions (in pixel).
    heatmap_t* hm = heatmap_new(w, h);

    // This creates two normal random distributions which will give us random points.
    std::random_device rd;
    std::mt19937 prng(rd());
    std::normal_distribution<float> x_distr(0.5f*w, 0.5f/3.0f*w), y_distr(0.5f*h, 0.25f*h);

    // Add a bunch of random points to the heatmap now.
    for(unsigned i = 0 ; i < npoints ; ++i) {
        heatmap_add_point(hm, x_distr(prng), y_distr(prng));
    }

    // This creates an image out of the heatmap.
    // `image` now contains the image data in 32-bit RGBA.
    image.resize(w*h*4);
    heatmap_render_default_to(hm, &image[0]);

    // Now that we've got a finished heatmap picture, we don't need the map anymore.
    heatmap_free(hm);

    // init GLUT and create window
	glutInit(&argc, argv);
	glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGBA);
	glutInitWindowPosition(100, 100);
	glutInitWindowSize(256, 512);
	glutCreateWindow("Heatmap");

    glutDisplayFunc(renderScene);
    glutIdleFunc(renderScene);
    glutMouseFunc(zooming);

    glEnable(GL_TEXTURE_2D);
    setupTexture();

	// enter GLUT event processing cycle
	glutMainLoop();

	return 0;
}
