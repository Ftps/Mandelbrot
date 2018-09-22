#ifndef H_PREC
#define H_PREC

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <math.h>
#include <cuda.h>

#define WAIT while(getchar() != '\n');
#define LOG         {printf("\nIN FILE %s || IN LINE %d\n\n", __FILE__, __LINE__); fflush(stdout);}
#define LOG_WAIT    {printf("\nIN FILE %s || IN LINE %d\n\n", __FILE__, __LINE__); fflush(stdout); WAIT}
#define PRINT_ERROR(X, d)   {printf(X); putchar('\n'); exit(d);}
#define ERR_DIV_ZERO        -2

#define DEFAULT_SIZE    128
#define NUM_SIZE        20
#define ZERO            "0.000000000e0"

typedef struct NUM{
    bool *mant;
    int mant_size;
    long int exp;
    bool sig, is_zero;
    char *dec;
}NUM;

double d2b(double p, int *exp);

void change_mant_size(int size);
void check_size(NUM *n);
int is_zero(NUM *n);
void num_str(NUM *n);

NUM* init_num();
void free_num(NUM *n);
void print_num(NUM *n, bool f);
NUM* num_cpy(NUM *n);
NUM* int_num(int n);
NUM* dou_num(double p);

int compare_num(NUM *n1, NUM *n2);
NUM* add_num(NUM *n1, NUM *n2, int f);
NUM* mult_num(NUM *n1, NUM *n2, int f);
NUM* inv_num(NUM *n, bool f);
NUM* div_num(NUM *n1, NUM *n2, int f);

#endif
