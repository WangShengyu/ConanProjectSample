#include "Sample.h"

int StrangeSum(int a, int b)
{
    if (b == 0) return a;
    return a / b * b + b;
}