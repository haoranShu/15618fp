#include <iostream>
#include <fstream>
#include <random>
#include <string>
#include <math.h>

using namespace std;

int main(int argc, char** argv)
{
    int ntraces;
    string filename;
    float width, height;

    if (argc != 5) {
        cout << "Not enough input!\n";
        return -1;
    } else {
        ntraces = atoi(argv[1]);
        filename = string(argv[2]);
        width = atof(argv[3]);
        height = atof(argv[4]);
    }

    int nphases = ntraces / 50 + 1;
    ntraces = (nphases - 1) * 50;

    ofstream file;
    file.open(filename + ".txt");
    file << ntraces + 1 << endl;

    float* xs = (float *)malloc(nphases * sizeof(float));
    float* ys = (float *)malloc(nphases * sizeof(float));
    float* ws = (float *)malloc(nphases * sizeof(float));
    float* hs = (float *)malloc(nphases * sizeof(float));

    xs[0] = 0;
    ys[0] = 0;
    ws[0] = width;
    hs[0] = height;

    for (int i = 1; i < nphases; i++) {
        xs[i] = (float)(rand()%(int)width);
        ys[i] = (float)(rand()%(int)height);
        ws[i] = (float)(rand()%(int)width);
        hs[i] = ws[i] * height / width;
    }

    file << xs[0] << ' ' << ys[0] << ' ' << ws[0] << ' ' << hs[0] << endl;
    for (int i = 1; i < nphases; i++) {
        float x_gap = (xs[i] - xs[i-1])/50;
        float y_gap = (ys[i] - ys[i-1])/50;
        float scale = pow(ws[i] / ws[i-1], 0.02);
        for (int j = 0; j < 50; j++) {
            file << xs[i-1] + (j+1) * x_gap << ' ' << ys[i-1] + (j+1) * y_gap << ' '
                 << ws[i-1] * pow(scale, j+1) << ' ' << hs[i-1] * pow(scale, j+1) << endl;
        }
    }

    file.close();

    free(xs);
    free(ys);
    free(ws);
    free(hs);

    return 0;
}