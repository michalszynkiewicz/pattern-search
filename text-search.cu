#include <cstdio>
#include <cstdlib>
#include <iostream>
#include <string>
#include "TextHandler.h"
#include "MultiplierHandler.h"
#include "PatternHandler.h"

#define THREAD_COUNT 10
#define DIM_COUNT 10
#define MAX_PATTERN_LENGTH 20
#define MULTIPLIER 1117
#define MODULUS 2147483647

using namespace std;

void init(){}

TextHandler* handleText() {
  TextHandler* handler = new TextHandler(MULTIPLIER, MODULUS);
  handler->read();
  handler->preprocess();
  handler->share();
  return handler;
}

int32_t* handleMultipliers() {
  MultiplierHandler* handler = new MultiplierHandler(MULTIPLIER, MODULUS, MAX_PATTERN_LENGTH);
  handler->calculate();
  handler->share();
  return handler->dMultipliers;
}

PatternHandler* handlePatterns(size_t maxPatterns) {
  PatternHandler* handler = new PatternHandler();
  handler->read(maxPatterns);
  handler->share();
  return handler;
}

__global__ void searchForPatterns(
		int32_t *shas, int32_t shasLength,
		int32_t* multipliers, char* mergedPatterns,
		int32_t *patternStarts, int32_t* patternEnds,
		int32_t patternsCount) {

    int32_t idx = THREAD_COUNT * blockIdx.x + threadIdx.x;
    int64_t resultAtPosition;
    int64_t sha;
    // printf("[%d, %d] will work starting from: %d", blockIdx.x, threadIdx.x, idx);

    while (idx < patternsCount) {
      sha = 0;
      const int32_t length = patternEnds[idx] - patternStarts[idx];
      for (int32_t i = patternStarts[idx]; i<patternEnds[idx]; i++) {
        sha = (sha * MULTIPLIER + mergedPatterns[i]) % MODULUS;
      }
      if (shas[length - 1] == (int32_t)sha) {
        printf("Possible match at 0 for %d\n", idx);
      }
      for (int32_t i = length; i<shasLength; i++) {
        resultAtPosition = -shas[i - length];
        resultAtPosition *= multipliers[length];
        resultAtPosition += shas[i];
        resultAtPosition %= MODULUS;
        resultAtPosition = resultAtPosition < 0 ? resultAtPosition + MODULUS : resultAtPosition;
       if (resultAtPosition == sha) {
          printf("Possible match at %d for %d\n", i - length + 1, idx);
       }
      }
      idx += DIM_COUNT * THREAD_COUNT;;
    }
}

void calculate(int32_t *preprocessed, int32_t preprocessedLength, int32_t* multipliers, char* mergedPatterns,
  int32_t *patternStarts, int32_t* patternEnds, int32_t patternsCount) {
  searchForPatterns<<<DIM_COUNT, THREAD_COUNT>>>(
          preprocessed, preprocessedLength,
          multipliers,
          mergedPatterns, patternStarts, patternEnds, patternsCount
        );
}

void join() {
  cudaDeviceSynchronize();
  cudaError_t code = cudaGetLastError();
  if (code != cudaSuccess)
  {
          fprintf(stderr,"Cuda call failed: [%d] %s\n", code, cudaGetErrorString(code));
          exit(code);
  }
}

int main(int argc, char **argv) {
  size_t maxPatterns = 100000000;
  if (argc > 1) {
    maxPatterns = atoi(argv[1]);
  }
  init();

  TextHandler* preprocessed = handleText();
  int32_t* multipliers = handleMultipliers();
  PatternHandler* patterns = handlePatterns(maxPatterns);
  int patternCount = min(patterns -> count, maxPatterns);
  printf("Will work on %d patterns\n", patternCount);
  calculate(preprocessed -> dShas, preprocessed -> length, multipliers,
    patterns -> dMerged, patterns -> dStarts, patterns -> dEnds, patternCount
  );

  join();
}
