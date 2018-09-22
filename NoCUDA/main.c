#include "mandel.h"

int main()
{
  DATA dat;

  init_dat(&dat);
  mandelbrot(dat);

  return 0;
}
