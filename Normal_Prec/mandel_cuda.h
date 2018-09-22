#ifndef MANDEL_CUDA
#define MANDEL_CUDA

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#define l 4
#define h l*((double)dat.hei)/((double)dat.len)

#define gpuErrchk(ans) { gpuAssert((ans), __FILE__, __LINE__); }
inline void gpuAssert(cudaError_t code, const char *file, int line, bool abort=true)
{
   if (code != cudaSuccess)
   {
      fprintf(stderr,"GPUassert: %s %s %d\n", cudaGetErrorString(code), file, line);
      if (abort) exit(code);
   }
}

typedef struct{
  double zoom;
  int len, hei;
  int it, colormax;
  double cx, cy;
}DATA;

void mandelbrot();
__global__ void image_gen(DATA dat, int* map);

#endif
