// Input generator
// See
// https://github.com/sio2project/oioioi/wiki/%5BEN%5D-5.-Package-with-input-generator
// Remove this file if tests are created manually or outside of this file
#include "oi.h"
#include <bits/stdc++.h>

#define __RANDOM_SEED__ 0
#define __RANDOM_SEED_1__ 1
#define __RANDOM_SEED_2__ 2
#define __RANDOM_SEED_3__ 3
#define __RANDOM_SEED_4__ 4

using namespace std;
typedef long long ll;
const string id = "xyz";

oi::Random RG(__RANDOM_SEED__);

unsigned randomUInt(unsigned a, unsigned b) { // both ends inclusive
  return RG.randUInt() % (b - a + 1) + a;
}

template <class ForwardIt>
ostream &print_collection(ostream &out, ForwardIt first,
                          ForwardIt last) { // no trailing space
  if (first == last)
    return out;

  out << *first;
  ++first;
  for (; first != last; ++first) {
    out << " " << *first;
  }
  return out;
}

struct Test {
  Test() {}

  void saveToFile(int no, char *letter, bool isOcen = false) {
    assert('a' <= *letter && *letter <= 'z');
    string name = id + to_string(no);
    if (isOcen)
      name += "ocen";
    else if (no > 0) {
      name += *letter;
      (*letter)++;
    }

    // printing
    name += ".in";
    cerr << "Printing to file: " << name << "\n";
    ofstream outFile(name);

    outFile.close();
  }
};

int main() {
  { // Test group 1
    int no = 1;
    char c = 'a';
    RG.setSeed(__RANDOM_SEED_1__);
    Test().saveToFile(no, &c, true);
    Test().saveToFile(no, &c);
  }
  { // Test group 2
    int no = 2;
    char c = 'a';
    RG.setSeed(__RANDOM_SEED_2__);
    Test().saveToFile(no, &c, true);
    Test().saveToFile(no, &c);
  }
  {
    // Test group 3
    int no = 3;
    char c = 'a';
    RG.setSeed(__RANDOM_SEED_3__);
    Test().saveToFile(no, &c, true);
    Test().saveToFile(no, &c);
  }
  { // Test group 4
    int no = 4;
    char c = 'a';
    RG.setSeed(__RANDOM_SEED_4__);
    Test().saveToFile(no, &c, true);
    Test().saveToFile(no, &c);
  }
}
