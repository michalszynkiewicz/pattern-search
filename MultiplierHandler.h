#include <string>
#include "cudaUtils.h"
using namespace std;

class MultiplierHandler {
int32_t multiplier;
int32_t modulus;
int32_t maxPatternLength;
int32_t* multipliers;
public:
int32_t* dMultipliers;

MultiplierHandler(
        int32_t multi,
        int32_t mod,
        int32_t max) : multiplier(multi), modulus(mod), maxPatternLength(max) {
        multipliers = new int32_t[maxPatternLength + 1];
}

void calculate() {
        int64_t tmp;
        multipliers[0] = 1;
        for (int32_t i = 1; i < maxPatternLength + 1; i++) {
                tmp = multipliers[i - 1];
                tmp *= multiplier;
                tmp %= modulus;
                multipliers[i] = tmp;
        }
}

void share() {
        cudaCall(cudaMalloc(&dMultipliers, (maxPatternLength + 1) * sizeof(int32_t)));
        cudaCall(cudaMemcpy(dMultipliers, multipliers, (maxPatternLength + 1) * sizeof(int32_t), cudaMemcpyHostToDevice));
}
};
