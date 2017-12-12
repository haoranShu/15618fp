#include <iostream>
#include <fstream>
#include <random>
#include <string>
#include <math.h>
#include <vector>
#include <algorithm>

using namespace std;

float xToy(float x)
{
    return (x - 400) * (x - 400) / 400 + 200;
}

int main(int argc, char** argv)
{
    int npoints;
    string filename;
    if (argc != 3) {
        cout << "Not enough input!\n";
        return -1;
    } else {
        npoints = atoi(argv[1]);
        filename = string(argv[2]);
    }

    ofstream file;
    file.open(filename + ".txt");
    file << argv[1] << endl;
    file << "0\n";
    file << "800 800\n";

    default_random_engine generator;

    vector<float> xs;
    vector<float> ys;
    xs.resize(50);
    ys.resize(50);

    for (int i = 0; i < 50; i++) {
        xs[i] = rand()%800;
        ys[i] = rand()%800;
    }

    float x, y;

    vector<float> xsd;
    vector<float> ysd;
    xsd.resize(50);
    ysd.resize(50);
    float sumx = 0;
    float sumy = 0;
    vector<int> xnum;
    vector<int> ynum;
    xnum.resize(50);
    ynum.resize(50);
   
    float sd[50];
    int yc[50]; 
    for (int i = 0; i < 50; i++) {
        sd[i] = (float)(rand()%5 + 1);
        yc[i] = rand() % 800;
        float sd_y = (float)min(800 - yc[i], yc[i] + 1) / 3;
	ysd[i] = sd_y;
        sumy += sd_y * sd_y;
    }
    int accu = 0;
    for (int i = 0; i < 50; i++) {
        normal_distribution<float> distribution1(xs[i], sd[i]);
        normal_distribution<float> distribution2(yc[i], ysd[i]);
	xnum[i] = (int)(ysd[i]*ysd[i] / sumy * (npoints/2));
        if (i == 49) xnum[i] = npoints/2 - accu;
        for (int j = 0; j < xnum[i]; j++) {
            x = distribution1(generator);
            y = distribution2(generator);
            if (y > 799) {
                y = 799.0;
            } else if (y < 0) {
                y = 0.0;
            }
            if (x > 799) {
                x = 799.0;
            } else if (x < 0) {
                x = 0.0;
            }
            file << x << ' ' << y << endl;
	}
        accu += xnum[i];
    }

    for (int i = 0; i < 50; i++) {
        sd[i] = (float)(rand()%5 + 1);
        yc[i] = rand() % 800;
        float sd_y = (float)min(800 - yc[i], yc[i] + 1) / 3;
	xsd[i] = sd_y;
        sumx += sd_y * sd_y;
    }
    accu = 0;
    for (int i = 0; i < 50; i++) {
        normal_distribution<float> distribution3(ys[i], sd[i]);
        normal_distribution<float> distribution4(yc[i], xsd[i]);
	ynum[i] = (int)(xsd[i]*xsd[i] / sumx * (npoints/2));
        if (i == 49) ynum[i] = npoints/2 - accu;
        for (int j = 0; j < ynum[i]; j++) {
            x = distribution3(generator);
            y = distribution4(generator);
            if (y > 799) {
                y = 799.0;
            } else if (y < 0) {
                y = 0.0;
            }
            if (x > 799) {
                x = 799.0;
            } else if (x < 0) {
                x = 0.0;
            }
            file << y << ' ' << x << endl;
	}
        accu += ynum[i];
    }

    return 0;
}
