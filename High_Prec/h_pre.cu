#include "h_pre.h"

int _SIZE = DEFAULT_SIZE;



void change_mant_size(int size)
{
    if(size < sizeof(int)) _SIZE = sizeof(int)*8;
    else _SIZE = size*8;
}

void check_size(NUM *n)
{
    if(n->mant_size == _SIZE) return;
    else n->mant = (bool*)realloc(n->mant, sizeof(bool)*_SIZE);

    if(_SIZE > n->mant_size){
        for(int i = n->mant_size; i < _SIZE; ++i) n->mant[i] = 0;
    }
    n->mant_size = _SIZE;

}

int is_zero(NUM *n)
{
    if(n->is_zero) return 1;

    for(int i = 0; i < _SIZE; ++i){
        if(n->mant[i]) return 0;
    }

    n->is_zero = 1;
    n->exp = n->sig = 0;
    strcpy(n->dec, ZERO);
    return 1;
}

void num_str(NUM *n)
{
    double p = 0;

    if(is_zero(n)) return;

    for(int i = 0; i < _SIZE; ++i){
        p += n->mant[i]*pow(2, n->exp - i);
    }

    (n->sig) ? sprintf(n->dec, "-%.10e", p): sprintf(n->dec, "%.10e", p);
}





NUM* init_num()
{
    NUM *new = (NUM*)malloc(sizeof(NUM));

    new->mant = (bool*)calloc(_SIZE, sizeof(bool));
    new->is_zero = 1;
    new->exp = new->sig = 0;
    new->mant_size = _SIZE;
    new->dec = (char*)malloc(sizeof(char)*(NUM_SIZE+1));
    strcpy(new->dec, ZERO);

    return new;
}

void free_num(NUM *n)
{
    free(n->mant);
    free(n->dec);
    free(n);
}

void print_num(NUM *n, bool f)
{
    num_str(n);
    (n->sig) ? printf("\n-"): putchar('\n');

    printf("%d.", n->mant[0]);
    for(int i = 1; i < _SIZE; ++i){
        (n->mant[i]) ? putchar('1'): putchar('0');
    }
    printf("e%ld\n%s\n\n", n->exp, n->dec);

    if(f) free_num(n);
}

NUM* num_cpy(NUM *n)
{
    NUM *new = init_num();

    for(int i = 0; i < _SIZE; ++i) new->mant[i] = n->mant[i];

    new->exp = n->exp;
    new->sig = n->sig;
    new->is_zero = n->is_zero;
    strcpy(new->dec, n->dec);

    return new;
}

NUM* int_num(int n)
{
    NUM *new = init_num();

    if(!n) return new;
    else if(n < 0) new->sig = 1;

    new->is_zero = 0;
    new->exp = sizeof(int)*8-1;
    n = abs(n);

    for(int i = sizeof(int)*8-1; i >= 0; --i){
        new->mant[sizeof(int)*8-1-i] = n & (0b1 << i);
    }

    while(!(new->mant[0])){
        for(int i = 0; i < sizeof(int)*8; ++i){
            new->mant[i] = new->mant[i+1];
        }
        --new->exp;
    }

    num_str(new);

    return new;
}

NUM* dou_num(double p)
{
    NUM *new = init_num();
    double n;

    if(!p) return new;
    else if(p < 0){
        new->sig = 1;
        p = abs(p);
    }
    new->is_zero = 0;
    new->exp = (int)(1+log2(p));
    p = p*pow(2, -(new->exp));

    for(int i = 0; i < _SIZE && p; ++i){
        if((n = pow(2, -i)) < p){
            new->mant[i] = 1;
            p -= n;
        }
    }

    while(!(new->mant[0])){
        for(int i = 0; i < _SIZE-1; ++i){
            new->mant[i] = new->mant[i+1];
        }
        --new->exp;
    }

    num_str(new);

    return new;

}






int compare_num(NUM *n1, NUM *n2)
{
    if(n1->exp > n2->exp) return 0b01;
    else if(n2->exp > n1->exp) return 0b10;
    else{
        for(int i = 0; i < _SIZE; ++i){
            if(n1->mant[i] != n2->mant[i]){
                if(n1->mant[i]) return 0b01;
                else return 0b10;
            }
        }
    }

    return 0b00;
}

NUM* add_num(NUM *n1, NUM *n2, int f)
{
    NUM *add, *big, *small;
    int cmp, a = 1, carry = 0, exp_dif, i;

    if(is_zero(n1)){add = num_cpy(n2); a = 0;}
    else if(is_zero(n2)){add = num_cpy(n1); a = 0;}
    else if((cmp = compare_num(n1, n2)) & 0b01){big = n1; small = n2;}
    else if(cmp & 0b10){big = n2; small = n1;}
    else{
        a = 0;
        if(n1->sig != n2->sig) add = init_num();
        else{
            add = num_cpy(n1);
            ++add->exp;
        }
    }

    if(a){
        if((exp_dif = big->exp - small->exp) >= _SIZE) add = num_cpy(big);
        else{
            a = (big->sig == small->sig) ? 0b0: 0b1;
            add = init_num();
            add->is_zero = 0;
            add->exp = big->exp;
            add->sig = big->sig;

            for(i = _SIZE-1; i >= exp_dif; --i){
                add->mant[i] = (big->mant[i]^(small->mant[i-exp_dif]^a))^carry;
                if((big->mant[i]+(small->mant[i-exp_dif]^a)+carry) > 1) carry = 1;
                else carry = 0;
            }
            for(int k = i; k >= 0; --k){
                add->mant[k] = (big->mant[k]^carry)^a;
                if((big->mant[k]+carry+a) > 1) carry = 1;
                else carry = 0;
            }
            if(carry && !a){
                for(int k = _SIZE-2; k >= 0; --k){
                    add->mant[k+1] = add->mant[k];
                }
                add->mant[0] = 1;
                ++add->exp;
            }
        }
    }

    if(f & 0b01) free_num(n1);
    if(f & 0b10) free_num(n2);

    return add;
}

NUM* mult_num(NUM *n1, NUM *n2, int f)
{
    NUM *mult = init_num(), *extra;

    if(n1->is_zero || n2->is_zero) return mult;

    extra = num_cpy(n1);
    extra->sig = 0;

    for(int i = 0; i < _SIZE; ++i){
        if(n2->mant[_SIZE-1-i]){
            extra->exp = i;
            mult = add_num(mult, extra, 0b01);
        }
    }

    if(n1->sig != n2->sig) mult->sig = 1;
    mult->exp += n1->exp + n2->exp - _SIZE+1;

    free_num(extra);

    if(f & 0b01) free_num(n1);
    if(f & 0b10) free_num(n2);

    return mult;
}

NUM* inv_num(NUM* n, bool f)
{
    NUM *iter, *two, *aux;
    double est;

    if(n->is_zero) PRINT_ERROR("ERR: DIVIDE BY ZERO", ERR_DIV_ZERO)

    num_str(n);
    sscanf(n->dec, "%lf", &est);
    iter = dou_num(1/est);
    two = int_num(2);

    for(int i = 0; i < (log2(_SIZE)+1); ++i){
        aux = mult_num(iter, n, 0b00);
        aux->sig = aux->sig^0b1;
        iter = mult_num(iter, add_num(two, aux, 0b10), 0b11);
    }

    free_num(two);
    if(f) free_num(n);

    return iter;
}

NUM* div_num(NUM *n1, NUM *n2, int f)
{
    NUM *inv, *div;

    if(n1->is_zero && !n1->is_zero) div = init_num();
    else{
        inv = inv_num(n2, 0b00);
        div = mult_num(n1, inv, 0b10);
    }

    if(f & 0b01) free_num(n1);
    if(f & 0b10) free_num(n2);

    return div;
}
