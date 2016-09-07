#include <string>
#include "cudaUtils.h"
using namespace std;

class TextHandler {
    string text;
    int32_t MULTIPLIER;
    int32_t MODULUS;
    int32_t* shas;
public:
    int32_t* dShas;
    int32_t length;
    TextHandler(
      const int32_t MULTIPLIER_,
      const int32_t MODULUS_) : MULTIPLIER(MULTIPLIER_), MODULUS(MODULUS_) {}

    void read() {
      cin >> text;
      length = text.length();
    }
    void preprocess() {
      shas = new int32_t[length];
      shas[0] = text[0] % MODULUS;
      for (int32_t i=1; i < length; i++) {
              int64_t newSha = shas[i-1];
              newSha *= MULTIPLIER;
              newSha += text[i];
              newSha %= MODULUS;
              shas[i] = (int32_t)newSha;
      }
    }

    void share() {
      cudaCall(cudaMalloc(&dShas, length * sizeof(int32_t)));
      cudaCall(cudaMemcpy(dShas, shas, length * sizeof(int32_t), cudaMemcpyHostToDevice));
    }

    int32_t* getPointer() {
      return dShas;
    }
};
