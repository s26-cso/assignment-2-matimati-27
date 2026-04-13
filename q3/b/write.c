#include <stdio.h>

int main(){
    long address = 0x104e8;

    fwrite(&address, 8, 1, stdout);

    return 0;
}