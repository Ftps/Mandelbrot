#include "mandel_cuda.h"

// FOR TEST NOW
void mandelbrot()
{
  int *map, *CUDA_map;
  DATA dat;

  dat.pre = 1;
  dat.cx = generate(dat.pre);
  dat.cy = generate(dat.pre);
  dat.len = 1980; dat.hei = 1080;
  dat.zoom = 1;
  dat.it = 100;
  dat.colormax = 1;

  dat.CUDA_cx = num2CUDA(dat.cx, dat.pre);
  dat.CUDA_cy = num2CUDA(dat.cy, dat.pre);

  map = (int*)malloc(sizeof(int)*dat.len*dat.hei);
  cudaMalloc(&CUDA_map, sizeof(int)*dat.len*dat.hei);

  image_gen<<< (dat.len*dat.hei+SIZE_THREAD-1)/SIZE_THREAD, SIZE_THREAD>>>(dat, CUDA_map);

  cudaMemcpy(map, CUDA_map, sizeof(int)*dat.len*dat.hei, cudaMemcpyDeviceToHost);

  for(int i = 0; i < dat.len*dat.hei; ++i){
    if(i%dat.len == 0) putchar('\n');
    if(map[i] == 0) printf("* ");
    else printf(". ");
  }

  putchar('\n');

  cudaFree(CUDA_map);
  free(map);
}







int test(int argc, char* argv[])
{
  int pre = 4;

  if(argc == 3 && !strcmp("-j", argv[1])){
    sscanf(argv[2], "%d", &pre);
    if(pre%deci == 0) pre = pre/deci;
    else pre = pre/deci + 1;
  }

  return pre;
}

void printnum(num *n1, int pre, int free)
{
  //long double c = (10.0*(long double)n1->mant[0])/((long double)powdeci);

  if(n1->signal == 0){
    printf("0.000e0\n");
    if(free) free_num(n1);
    return;
  }
  if(n1->signal == -1) printf("-");
  //printf("%.16llf", c);*/
  for(int i = 0; i < pre; ++i){
    printf("%017ld", n1->mant[i]);
  }
  printf("e%d\n\n", n1->exp);
  if(free) free_num(n1);
}

num generaterand(int pre)
{
  num gen;
  gen.exp = rand()%12 + 1;
  do{
    gen.signal = ((rand()%3)-1);
    printf("Signal = %d\n", gen.signal);
  }while(gen.signal == 0);

  for(int i = 0; i < pre; ++i){
    gen.mant[i] = (((long int)rand())*((long int)rand()))%powdeci;
  }

  return gen;
}

double rand_double()
{
  double p;

  p = (double)((rand()*rand())%powdeci)*(double)pow(10, (rand()%24)-11);

  return p;
}

__device__ double mod_numAp(num *n1, num *n2)
{
  double p = 0, n11, n12;

  n11 = (((double)10*n1->mant[0])/powdeci)*(((double)10*n1->mant[0])/powdeci);

  n12 = (((double)10*n2->mant[0])/powdeci)*(((double)10*n2->mant[0])/powdeci);

  if(n1->exp > -4) p += n11*pow(10, 2*n1->exp);
  if(n2->exp > -4) p += n12*pow(10, 2*n2->exp);

  return p;
}





__global__ void image_gen(DATA dat, int* map)
{
  num *posx, *posy, *intx, *inty, *aux;
  int x, y;
  int N = blockDim.x*blockIdx.x + threadIdx.x;
  int i;
  double pal;

  if(N < dat.len*dat.hei){
    x = N%dat.len;
    y = N/dat.len;

    //posx = d2n((l/(dat.zoom))*(((double)x)/((double)dat.len) - 0.5), dat.pre);
    //posy = d2n((h/(dat.zoom))*(((double)y)/((double)dat.hei) - 0.5), dat.pre);

    posx = generateCUDA(dat.pre);
    posy = generateCUDA(dat.pre);

    posx = addnumber(posx, dat.CUDA_cx, dat.pre, 0, 1);
    posy = addnumber(posy, dat.CUDA_cy, dat.pre, 0, 1);

    intx = num_cpy(posx, dat.pre);
    inty = num_cpy(posy, dat.pre);

    for(i = 0; (i < dat.it) && (pal = mod_numAp(intx, inty) < 4); ++i){
      aux = addnumber(sq_num(intx, dat.pre, 0, 0), sq_num(inty, dat.pre, 1, 0), dat.pre, 0, 3);
      aux = addnumber(aux, posx, dat.pre, 0, 1);
      inty = opt_mult(2, multiply(intx, inty, dat.pre, 3), dat.pre, 1, 1);
      inty = addnumber(inty, posy, dat.pre, 0, 1);
      intx = aux;
    }

    free_numCUDA(posx);
    free_numCUDA(posy);
    free_numCUDA(intx);
    free_numCUDA(inty);

    /*if(i < dat.it){
      pal = (double)(i+1) + log2(0.5*log2(pal));
      map[x+y*dat.len] = ((int)pal)%dat.colormax + 1;
      //map[x+y*dat.len] = 1;
    }
    else{*/
      map[x+y*dat.len] = 0;
    //}
  }
}




__global__ void test_func(double* line, int size, int pre)
{
  int N = blockIdx.x*blockDim.x + threadIdx.x;
  num *aux;

  if(N < size){
    aux = d2n(line[N], pre);
    aux = addnumber(aux, aux, pre, 0, 1);
    line[N] = n2d(aux, 1);
  }
}

void test(){
  double *line, *CUDA_line;

  line = (double*)malloc(sizeof(double)*40);
  gpuErrchk(cudaMalloc(&CUDA_line, sizeof(double)*40));
  for(int i = 0; i < 40; ++i){
    line[i] = rand_double();
    printf("%lf ", line[i]);
  }
  gpuErrchk(cudaMemcpy(CUDA_line, line, sizeof(double)*40, cudaMemcpyHostToDevice));

  test_func<<<40/SIZE_THREAD + 1, SIZE_THREAD>>>(CUDA_line, 40, 2);
  gpuErrchk( cudaPeekAtLastError() );
  gpuErrchk( cudaDeviceSynchronize() );

  gpuErrchk(cudaMemcpy(line, CUDA_line, sizeof(double)*40, cudaMemcpyDeviceToHost));

  printf("\n\n\n\n");
  for(int i = 0; i < 40; ++i){
    printf("%lf ", line[i]);
  }
}

void test2()
{
  double *lin1, *lin2;
  num *aux;
  int pre = 2, size = 2000;
  lin1 = (double*)malloc(sizeof(double)*size);
  lin2 = (double*)malloc(sizeof(double)*size);

  for(int i = 0; i < size; ++i){
    lin1[i] = rand_double();
  }

  for(int i = 0; i < size; ++i){
    aux = d2n(lin1[i], pre);
    aux = addnumber(aux, sq_num(aux, pre, 1, 0), pre, 0, 3);
    lin2[i] = n2d(aux, 1);
    printf("%lf - %lf^2 = %lf\n", lin1[i], lin1[i], lin2[i]);
  }
  free(lin1);
  free(lin2);
}
