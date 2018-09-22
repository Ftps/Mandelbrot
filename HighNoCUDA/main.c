#include "mandel.h"

int main(int argc, char* argv[])
{
    DATA dat = init_data();

    mandelbrot(dat);

    return 0;
}
