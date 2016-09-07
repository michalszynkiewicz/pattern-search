#include <string>
#include "cudaUtils.h"
using namespace std;

class PatternHandler {
  char* merged;
  int32_t* starts;
  int32_t* ends;
  int32_t lengthSum;
public:
  char* dMerged;
  int32_t* dStarts;
  int32_t* dEnds;
  int32_t count;
  void read() {
    std::cin >> count;
    string patterns[count];
    ends = new int32_t[count];
    starts = new int32_t[count];
    int32_t start = 0;
    for (int32_t i = 0; i < count; i++) {
      std::cin >> patterns[i];
      int32_t length = patterns[i].length();
      starts[i] = start;
      start += length;
      ends[i] = start;
      lengthSum += length;
    }

    merged = new char[lengthSum];
    int32_t pos = 0;
    for (int32_t i = 0; i < count; i++) {
      const string pattern = patterns[i];
      for (int32_t j = 0; j < pattern.length(); j++) {
        merged[pos++] = pattern[j];
      }
    }
  }

  void share() {
    cudaCall(cudaMalloc(&dMerged, lengthSum * sizeof(char)));
    cudaCall(cudaMemcpy(dMerged, merged,  lengthSum * sizeof(char), cudaMemcpyHostToDevice));
    cudaCall(cudaMalloc(&dStarts, count * sizeof(int32_t)));
    cudaCall(cudaMemcpy(dStarts, starts, count * sizeof(int32_t), cudaMemcpyHostToDevice));

    cudaCall(cudaMalloc(&dEnds, count * sizeof(int32_t)));
    cudaCall(cudaMemcpy(dEnds, ends,  count * sizeof(int32_t), cudaMemcpyHostToDevice));
  }
};
