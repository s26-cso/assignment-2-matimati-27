#include <stdio.h>
#include <dlfcn.h>

int main() {

    char command[6];
    int op_1, op_2;

    while((scanf("%s %d %d", command, &op_1, &op_2)) == 3) {    // To prevent deformed input from affecting the code
        char path[20];
        snprintf(path, sizeof(path), "./lib%s.so", command);

        void* fetch = dlopen(path, RTLD_LAZY);
        if(fetch) {
            int(*function)(int, int) = dlsym(fetch, command);
            if(function) {
                int result = function(op_1, op_2);
                printf("%d\n", result);
                dlclose(fetch);
            }
        }
    }
    return 0;
}