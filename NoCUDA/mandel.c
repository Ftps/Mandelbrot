#include "mandel.h"

void mandelbrot(DATA dat)
{
  int *map = (int*)malloc(sizeof(int)*dat.len*dat.hei);
  int x, y, i;
  double px, py, itx, ity, aux, pal;
  FILE *fp;

  for(int N = 0; N < dat.len*dat.hei; ++N){
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

  fp = fopen("cancer.xpm", "w");

  fprintf(fp, "/* XPM */\n");
  fprintf(fp, "static const char * sample_xpm[] = {\n/* columns rows colors chars-per-pixel */\n");
  fprintf(fp, "\"%d %d 256 3\",\n", dat.len, dat.hei);
  fprintf(fp, "\"000 c #000000\",\n");
  for(int i = 255; i > 0; --i){
    fprintf(fp, "\"%03d c #%02x%02x%02x\",\n", 256-i, i, i, i);
  }

  for(int i = 0; i < dat.hei; ++i){
    fputc('\"', fp);
    for(int j = 0; j < dat.len; ++j){
        fprintf(fp, "%03d", map[i*dat.len + j]);
    }
    fprintf(fp, "\",\n");
  }
  fprintf(fp, "};");
  fclose(fp);
  free(map);
}

void init_dat(DATA *dat)
{
  dat->cx = dat->cy = 0;
  dat->zoom = 1;
  dat->colormax = 255;
  dat->it = 1000;
  dat->len = 1980; dat->hei = 1080;
}
