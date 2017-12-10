#include <iostream>
#include <fstream>
#include <random>
#include <string>
#include <math.h>

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
    normal_distribution<float> distribution(0.0,25.0);

    float x, y;
    for (int i = 0; i < npoints; i++) {
        x = rand() % 800;
        y = xToy(x);

        y += distribution(generator);
        if (y > 799) {
            y = 799.0;
        } else if (y < 0) {
            y = 0.0;
        }

        file << x << ' ' << y << endl;
    }
}
