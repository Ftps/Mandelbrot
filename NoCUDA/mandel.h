#ifndef MANDEL
#define MANDEL

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#define l 4
#define h l*((double)dat.hei)/((double)dat.len)

typedef struct data{
  double cx, cy;
  double zoom;
  int len, hei;
  int colormax, it;
}DATA;

void mandelbrot(DATA dat);
void init_dat(DATA *dat);

#endif
