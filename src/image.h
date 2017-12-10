#ifndef  __IMAGE_H__
#define  __IMAGE_H__

template <typename T>
struct Image {

    Image(int w, int h) {
        width = w;
        height = h;
        data = new T[4 * width * height];
    }

    void clear(T r, T g, T b, T a) {

        int numPixels = width * height;
        T* ptr = data;
        for (int i=0; i<numPixels; i++) {
            ptr[0] = r;
            ptr[1] = g;
            ptr[2] = b;
            ptr[3] = a;
            ptr += 4;
        }
    }

    int width;
    int height;
    T* data;
};


#endif
