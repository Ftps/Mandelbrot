#ifndef MANDEL_CUDA
#define MANDEL_CUDA

#include "h_pre.h"

#define LEN 0
#define HEI 1
#define l 4
#define h l*dat.hei/dat.len

#define LOG_mandel {if(N == 0) printf("IN FILE %s || IN LINE %d\n", __FILE__, __LINE__);}

typedef struct data{
  num *cx, *cy;
  num *CUDA_cx, *CUDA_cy;
  int len, hei;
  double zoom;
  int pre;
  int it;
  int colormax;
}DATA;


void mandelbrot();
int test(int argc, char* argv[]);
__host__ __device__ void printnum(num *n1, int pre, int free);
num generaterand(int pre);
double rand_double();
__device__ double mod_numAp(num *n1, num *n2);
__global__ void image_gen(DATA dat, int* map);

__global__ void test_func(double* line, int size, int pre);
void test();

void test2();

#endif
