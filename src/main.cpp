#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <getopt.h>
#include <iostream>
#include <fstream>
#include <random>

#include "general.h"
#include "gl_utility.h"
#include "cuda_renderer.h"
#include "cdpQuadtree.h"

using namespace std;

Image<unsigned char>* ppmOutput;
std::vector<unsigned char> image;
int npoints;
float* xs;
float* ys;
float* ws;
heatmap_t* hm;
int renderW, renderH;
float width, height;
Quad* leveledPts;

// cuda objects
float* pixel_weights;
unsigned char* pixel_color;
float* max_buf;
int* sizes;

void usage(const char* progname) {
    printf("Usage: %s [options] width height input\n", progname);
    printf("Program Options:\n");
    printf("  -f  --file  <FILENAME>     Specify input file of zooming trace\n");
    printf("  -c  --cuda                 Use CUDA version\n");
    printf("  -?  --help                 This message\n");
}

int main(int argc, char** argv)
{

    string inputFile;
    string traceFile;
    bool zoom = false;
    bool useCuda = false;
    int ntrace = 0;
    float x0, y0;

    // parse command options
    int opt;
    static struct option long_options[] = {
        {"help", 0, 0, 'h'},
        {"cuda", 0, 0, 'c'},
        {"file", 1, 0, 'f'},
        {0, 0, 0, 0}
    };

    while ((opt = getopt_long(argc, argv, "f:ch", long_options, NULL)) != EOF) {
        switch (opt) {
            case 'f':
                zoom = true;
                traceFile = optarg;
                break;
            case 'c':
                useCuda = true;
                break;
            case 'h':
            default:
                usage(argv[0]);
                return 1;
        }
    }

    if (useCuda && !zoom) {
        fprintf(stderr, "Error: does not support CUDA with OpenGL on this machine\n");
        usage(argv[0]);
        return 1;
    }

    if (optind + 3 > argc) {
        fprintf(stderr, "Error: missing arguments\n");
        usage(argv[0]);
        return 1;
    }

    renderW = atoi(argv[optind]);
    renderH = atoi(argv[optind+1]);
    inputFile = argv[optind+2];
    image.resize(renderW * renderH * 4);
    hm = heatmap_new(renderW, renderH);
    ppmOutput = new Image<unsigned char>(renderW, renderH);

    fstream fs;

    if (!useCuda) {
        fs.open(inputFile, fstream::in);

        fs >> npoints;

        int weighted;
        fs >> weighted;
        fs >> width >> height;

        leveledPts = new Quad(Point(0, 0), Point(width, height));
        float x, y, w;

        if (weighted == 0) {
            for (int i = 0; i < npoints; i++) {
                fs >> x >> y;
                Point p(x, y, 1.0f);
                leveledPts->insert(p);
            }
        } else {
            for (int i = 0; i < npoints; i++) {
                fs >> x >> y >> w;
                Point p(x, y, w);
                leveledPts->insert(p);
            }
        }

        fs.close();

        if (!zoom) {
            // init GLUT and create window
            glutInit(&argc, argv);
            glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGBA);
            glutInitWindowPosition(100, 100);
            glutInitWindowSize(renderW, renderH);
            glutCreateWindow("Heatmap");

            glutDisplayFunc(renderScene);
            glutIdleFunc(renderScene);
            glutMouseFunc(zooming);

            glEnable(GL_TEXTURE_2D);
            setupTexture();
            // enter GLUT event processing cycle
            glutMainLoop();
        } else {
            fs.open(traceFile, fstream::in);
            fs >> ntrace;
            string outputPre = "medianoutput/trace";
            char outputName[30];
            for (int i = 0; i < ntrace; i++) {
                fs >> x0 >> y0 >> width >> height;
                sprintf(outputName, "%s%04d.ppm", outputPre.c_str(), i+1);
                renderNewPoints(x0, y0, width, height, string(outputName));
            }
            fs.close();
        }
    } else {
        fs.open(inputFile, fstream::in);

        fs >> npoints;

        int weighted;
        fs >> weighted;
        fs >> width >> height;

        leveledPts = new Quad(Point(0, 0), Point(width, height));
        float x, y, w;

        if (weighted == 0) {
            for (int i = 0; i < npoints; i++) {
                fs >> x >> y;
                Point p(x, y, 1.0f);
                leveledPts->insert(p);
            }
        } else {
            for (int i = 0; i < npoints; i++) {
                fs >> x >> y >> w;
                Point p(x, y, w);
                leveledPts->insert(p);
            }
        }

        fs.close();

        renderNewPoints(0, 0, width, height, "benchmark.ppm");

        // parse input from inputFile and construct Quadtree
        //fs.open(inputFile, fstream::in);
        //// TODO: declare extern Quadtree_node * in gl_utility.h
        //// TODO: declare Quadtree_node * in main.cpp
        //// TODO: cudaMalloc space for points
        //// TODO: thrust IO to set up Quadtree
        //fs.close();

        //// allocate device buffer to store processed data points for each pixel
        cudaInit();
        renderNewPointsCUDA(0, 0, width, height, "cuda.ppm", sizes);

        //fs.open(traceFile, fstream::in);
        //fs >> ntrace;
        //string outputPre = "cuda_medianoutput/trace";
        //char outputName[30];
        //for (int i = 0; i < ntrace; i++) {
            //fs >> x0 >> y0 >> width >> height;
            //sprintf(outputName, "%s%04d.ppm", outputPre.c_str(), i+1);
            //renderNewPointsCUDA(x0, y0, width, height, string(outputName));
        //}

        //fs.close();
    }

    return 0;
}