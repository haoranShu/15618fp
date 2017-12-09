#ifndef __PPM_H__
#define __PPM_H__

#include <string>

template <typename T>
struct Image;

void writePPMImage(const Image<unsigned char>* image, std::string filename);

#endif
