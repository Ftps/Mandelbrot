#include "mandel.h"

DATA init_data()
{
    DATA dat;

    dat.len = 80;
    dat.hei = 60;
    dat.iter = 500;
    dat.zoom = 1;
    dat.cx = dat.cy = 0;
    dat.filename = (char*)malloc(sizeof(char)*(NAME_SIZE+1));
    strcpy(dat.filename, "cancer.xpm");

    return dat;
}

int** gen_map(int len, int hei)
{
    int **map = (int**)malloc(sizeof(int*)*hei);

    for(int i = 0; i < hei; ++i){
        map[i] = (int*)calloc(sizeof(int), len);
    }

    return map;
}

void free_map(int **map, int hei)
{
    for(int i = 0; i < hei; ++i){
        free(map[i]);
    }

    free(map);
}

void mandelbrot(DATA dat)
{
    //FILE *fp = fopen(dat.filename, "w");
    num itx, ity, aux, px, py, two = int_num(2);
    int **map = gen_map(dat.len, dat.hei);

    for(int i = 0; i < dat.hei; ++i){
        for(int j = 0; j < dat.len; ++j){
            px = itx = dou_num((l/(dat.zoom))*(((double)j)/((double)dat.len) - 0.5) + dat.cx);
            py = ity = dou_num((h/(dat.zoom))*(((double)i)/((double)dat.hei) - 0.5) + dat.cy);
            for(int k = 0; k < dat.iter; ++k){
                LOG
                aux = mult_num(ity, ity, 0b00);
                aux->sig = 1;
                LOG
                aux = add_num(add_num(mult_num(itx, itx, 0b00), aux, 0b11, 1), px, 0b01, 1);
                LOG
                ity = add_num(mult_num(two, mult_num(itx, ity, 0b11), 0b10), py, 0b01, 1);
                LOG
                itx = aux;
                if(sqr_add(itx, ity, 0b00) >= 4){
                    map[i][j] = 1;
                    LOG
                    break;
                }
                LOG
            }
            free_num(px);
            free_num(py);
            free_num(itx);
            free_num(ity);

            (map[i][j]) ? printf(" "): printf("* ");
        }
        putchar('\n');
    }
    free_num(two);
    free_map(map, dat.hei);
    //fclose(fp);
}

double sqr_add(num n1, num n2, int f)
{
    double p;
    num aux = add_num(mult_num(n1, n1, f & 0b01), mult_num(n2, n2, f & 0b10), 0b11, 0);

    num_str(aux);

    sscanf(aux->dec, "%lf", &p);

    return p;
}
