#include "mandel_cuda.h"

void mandelbrot()
{
  int *map, *CUDA_map;
  DATA dat;
  FILE *fp;

  dat.zoom = 1;
  dat.len = 11880; dat.hei = 6480;
  dat.it = 1000, dat.colormax = 255;
  dat.cx = dat.cy = 0;

  map = (int*)malloc(sizeof(int)*dat.len*dat.hei);
  cudaMalloc(&CUDA_map, sizeof(int)*dat.len*dat.hei);

  image_gen<<< (dat.len*dat.hei)/512 + 1, 512>>>(dat, CUDA_map);

  cudaMemcpy(map, CUDA_map, sizeof(int)*dat.len*dat.hei, cudaMemcpyDeviceToHost);

  fp = fopen("cancer.xpm", "w");
  fprintf(fp, "! XPM2\n%d %d %d 3\n", dat.len, dat.hei, dat.colormax+1);
  fprintf(fp, "000 c #000000");
  for(int i = 255; i > 0; --i){
    fprintf(fp, "\n%03d c #%02x%02x%02x", 256-i, i, i, i);
  }
  for(int i = 0; i < dat.len*dat.hei; ++i){
    if(i%dat.len == 0) fprintf(fp, "\n");
    fprintf(fp, "%03d", map[i]);
  }
  fclose(fp);
  free(map);
  cudaFree(CUDA_map);
}

__global__ void image_gen(DATA dat, int* map)
{
  int N = blockDim.x*blockIdx.x + threadIdx.x;
  int x, y, i;
  double px, py, itx, ity, aux, pal;

  if(N < dat.len*dat.hei){
    x = N%dat.len;
    y = N/dat.len;

    itx = px = (l/(dat.zoom))*(((double)x)/((double)dat.len) - 0.5) + dat.cx;
    ity = py = (h/(dat.zoom))*(((double)y)/((double)dat.hei) - 0.5) + dat.cy;

    for(i = 0; i < dat.it && (itx*itx+ity*ity) < 4; ++i){
      aux = itx*itx - ity*ity + px;
      ity = 2*itx*ity + py;
      itx = aux;
    }
    if(i < dat.it){
      pal = (double)(i+1) + log2(0.5*log2(itx*itx+ity*ity));
      map[x+y*dat.len] = (int)pal%dat.colormax + 1;
    }
    else{
      map[x+y*dat.len] = 0;
    }
  }
}
