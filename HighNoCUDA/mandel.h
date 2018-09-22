#ifndef MANDEL_C
#define MANDEL_C

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include "h_pre.h"

#define NAME_SIZE 50
#define l 4
#define h l*((double)dat.hei)/((double)dat.len)

typedef NUM* num;

typedef struct DATA{
    int len, hei, iter;
    double cx, cy, zoom;
    char *filename;
}DATA;

DATA init_data();
int** gen_map(int len, int hei);
void mandelbrot(DATA dat);
double sqr_add(num n1, num n2, int f);


#endif
