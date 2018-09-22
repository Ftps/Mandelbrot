/* compile with:
nvcc *.cu -I. -o exe -arch=sm_xx --relocatable-device-code true
-lineinfo -lcuda -lcudart -lm -use_fast_math


for me, xx = 50
*/

#include "mandel_cuda.h"

int main(int argc, char* argv[])
{
  mandelbrot();

  return 0;
}
