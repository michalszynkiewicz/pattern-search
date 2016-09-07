#include <string>
#include <iostream>
#include <vector>
#include <cstring>
#include <cstdlib>

using namespace std;

int p;
char **patterns;
int* preprocessed;
int* patternLengths;

void preprocess(int idx) {
  preprocessed[0] = -1;
  preprocessed[1] = 0;
  int current = 0;
  int  pos = 2;
  while (pos < patternLengths[idx]) {
    if (patterns[idx][pos] == patterns[idx][current]) {
      current++; preprocessed[pos] = current; pos ++;
    } else if (current > 0) {
      current = preprocessed[current];
    } else {
      preprocessed[pos] = 0; pos ++;
    }
  }
}

void search(const string& text, int idx) {
  int m = 0, i = 0;
  while (m + i < text.length()) {
    if (patterns[idx][i] == text[m + i]) {
      if (i == patternLengths[idx] - 1) {
        cout << "Match for pattern " << idx << " at: " << m << endl;
        m = m + i - preprocessed[i];
        i = preprocessed[i];
      } else {
        i ++;
      }
    } else {
      if (preprocessed[i] > -1) {
        m = m + i - preprocessed[i];
        i = preprocessed[i];
      } else {
        m++;
        i = 0;
      }
    }
  }
}

void findPatterns(int patternNo, const string &text) {
  preprocessed = new int[30];
  for (int i=0; i<patternNo; i++) {
    preprocess(i);
//    cout << i << ": ";
    search(text, i);
//    cout << endl;
  }
}

void readPatterns() {
  cin >> p;
  patterns = new char*[p];
  patternLengths = new int[p];
  for (size_t i = 0; i < p; i++) {
    patterns[i] = new char[20];
    cin >> patterns[i];
    patternLengths[i] = strlen(patterns[i]);
  }
}

int main(int argc, char **argv) {
  int patternNo = atoi(argv[1]);
  string text;

  getline(cin, text);
  readPatterns();
  findPatterns(patternNo, text);
  return 0;
}
