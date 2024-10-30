// Source: https://github.com/FilipKon13/tests-generation/tree/0926e58

// Typical (idiomatic?) usage of this library for the SIO2/OIOIOI system.

// This is an actual ingen file written for a problem where input is in the
// following format:
// #####################
// n
// a_1 a_2 ... a_n
// #####################
// The task was to compute a value of \sum_{1 <= i <= j <= n} max(a[i:j]) *
// gcd(a[i:j]) mod 10^9 + 7.

// useful things (search for examples):
// test.randInt / test.randLong
// test.shuffle
// test.assumption{Global, Suite, Test}

#include "testgen.hpp"
#include <bits/stdc++.h>
using namespace std;
using namespace test;

struct Testcase {
  vector<int> T;
  friend ostream &operator<<(ostream &s, Testcase const &tc) {
    auto &T = tc.T;
    s << T.size() << '\n';
    auto it = T.begin();
    s << *it++;
    for_each(it, T.end(), [&](int x) { s << ' ' << x; });
    return s << '\n';
  }
  // template T& or auto& if you want reference to test here (hard to use
  // explicit name) or 'RngUtilities<auto> & test' for intellisense
  void do_something(auto &test) { T.push_back(test.randInt(1, 20)); }
};

const int MAX_N = 200'000;
const int MAX_RANGE = 1'000'000'000;

int main() {
  Testing<OIOIOIManager<>, Testcase> test("sza", true); // true for ocen
  test.assumptionGlobal(
      [](Testcase const &tc) { // by const ref or by value only atm
        int n = tc.T.size();
        if (!(1 <= n && n <= MAX_N))
          return false;
        for (auto v : tc.T)
          if (!(1 <= v && v <= MAX_RANGE))
            return false;
        return true;
      });
  // Personal preference to lambdas, however member function in Testcase class
  // may be more readable
  auto rand = [&](vector<int> &T, int from, int to, int n) {
    for (int i = 0; i < n; i++)
      T.push_back(test.randInt(from, to));
  };
  auto long_equal = [&](vector<int> &T, int n, vector<int> const &vals,
                        int cnt) {
    set<int> S;
    while (--cnt)
      S.insert(test.randInt(1, n));
    S.insert(n);
    int c = 0;
    for (auto v : S) {
      int r = vals[test.randInt(0, vals.size() - 1)];
      while (c < v)
        T.push_back(r), c++;
    }
  };
  test.skipTest(); // do not touch sza1ocen.in

  { // sza2ocen.in
    auto tc = test.getTest();
    rand(tc.T, 1, 10, 4);
    test << tc;
  }
  { // sza3ocen.in
    auto tc = test.getTest();
    rand(tc.T, 1, 1, 2000);
    test << tc;
  }
  { // sza4ocen.in
    auto tc = test.getTest();
    for (int i = 0; i < MAX_N; i++)
      tc.T.push_back(1 + (MAX_RANGE - 1) * (i & 1));
    test << tc;
  }
  { // sza5ocen.in
    auto tc = test.getTest();
    rand(tc.T, 1, MAX_RANGE, MAX_N);
    test << tc;
  }
  // 1. n <= 2000
  {                               // sza1c.in
    auto tc = test.setTest(3, 1); // start with sza1c.in
    test.assumptionSuite(
        [](Testcase const &tc) { return tc.T.size() <= 2000; });
    rand(tc.T, 1, MAX_RANGE, 2000);
    test << tc;
  }
  { // sza1d.in
    auto tc = test.getTest();
    rand(tc.T, MAX_RANGE, MAX_RANGE, 2000);
    test << tc;
  }
  { // sza1e.in
    auto tc = test.getTest();
    rand(tc.T, 1, 1, 2000); // To show assumption functionality, change to 2000
    test << tc;
  }
  { // sza1f.in
    auto tc = test.getTest();
    long_equal(tc.T, 2000,
               {MAX_RANGE, MAX_RANGE / 2, MAX_RANGE / 4, MAX_RANGE / 5}, 10);
    test << tc;
  }
  { // sza1g.in
    auto tc = test.getTest();
    tc.T.push_back(2);
    test << tc;
  }
  // 2. a_i <= 2
  test.nextSuite();
  test.assumptionSuite([](Testcase const &tc) {
    for (auto v : tc.T)
      if (v > 2)
        return false;
    return true;
  });
  { // sza2a.in
    auto tc = test.getTest();
    rand(tc.T, 1, 2, MAX_N);
    test << tc;
  }
  { // sza2b.in
    auto tc = test.getTest();
    rand(tc.T, 2, 2, MAX_N - 1);
    test << tc;
  }
  { // sza2c.in
    auto tc = test.getTest();
    tc.T.push_back(2);
    test << tc;
  }
  { // sza2d.in
    auto tc = test.getTest();
    long_equal(tc.T, MAX_N, {1, 2, 2, 2}, 20);
    test << tc;
  }
  // 3. a_i <= 10
  test.nextSuite();
  test.assumptionSuite([](Testcase const &tc) {
    for (auto v : tc.T)
      if (v > 10)
        return false;
    return true;
  });
  { // sza3a.in
    auto tc = test.getTest();
    rand(tc.T, 1, 10, MAX_N);
    test << tc;
  }
  { // sza3b.in
    auto tc = test.getTest();
    long_equal(tc.T, MAX_N, {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}, 20);
    test << tc;
  }
  { // sza3c.in
    auto tc = test.getTest();
    long_equal(tc.T, MAX_N, {2, 4, 8, 10}, 20);
    test << tc;
  }
  { // sza3d.in
    auto tc = test.getTest();
    tc.T.push_back(10);
    test << tc;
  }
  // 4. a_i = 2^k
  test.nextSuite();
  test.assumptionSuite([](Testcase const &tc) {
    for (auto v : tc.T)
      if ((v & (-v)) != v)
        return false;
    return true;
  });
  { // sza4a.in
    auto tc = test.getTest();
    rand(tc.T, 1, 4, MAX_N);
    tc.T.resize(remove(tc.T.begin(), tc.T.end(), 3) - tc.T.begin());
    test << tc;
  }
  { // sza4b.in
    auto tc = test.getTest();
    tc.T = vector(MAX_N, 1 << 19);
    test << tc;
  }
  { // sza4c.in
    auto tc = test.getTest();
    long_equal(tc.T, MAX_N - 7, {2, 4, 8, 16, 32, 64, 128}, 20);
    test << tc;
  }
  { // sza4d.in
    auto tc = test.getTest();
    long_equal(tc.T, MAX_N / 2, {2, 4, 8, 16, 32, 64, 128}, 20);
    long_equal(tc.T, MAX_N / 2,
               {1 << 20, 1 << 21, 1 << 22, 1 << 23, 1 << 24, 1 << 25, 1 << 26},
               20);
    test << tc;
  }
  { // sza4e.in
    auto tc = test.getTest();
    long_equal(tc.T, MAX_N,
               {1 << 20, 1 << 21, 1 << 22, 1 << 23, 1 << 24, 1 << 25, 1 << 26},
               1000);
    test << tc;
  }
  // 5. a_i < a_{i+1}
  test.nextSuite();
  test.assumptionSuite([](Testcase const &tc) {
    return is_sorted(tc.T.begin(), tc.T.end(),
                     [](int a, int b) { return a <= b; });
  });
  { // sza5a.in
    auto tc = test.getTest();
    rand(tc.T, 1, MAX_RANGE, MAX_N);
    sort(tc.T.begin(), tc.T.end());
    tc.T.resize(unique(tc.T.begin(), tc.T.end()) - tc.T.begin());
    test << tc;
  }
  { // sza5b.in
    auto tc = test.getTest();
    tc.T.resize(MAX_N);
    iota(tc.T.begin(), tc.T.end(), 1);
    test << tc;
  }
  { // sza5c.in
    auto tc = test.getTest();
    long_equal(tc.T, MAX_N / 2, {43234, 34758, 34758}, 20);
    long_equal(tc.T, MAX_N / 2,
               {3 << 20, 3 << 21, 3 << 22, 3 << 23, 3 << 24, 3 << 25, 3 << 26},
               20);
    sort(tc.T.begin(), tc.T.end());
    tc.T.resize(unique(tc.T.begin(), tc.T.end()) - tc.T.begin());
    test << tc;
  }
  // 6. general
  test.nextSuite();
  { // sza6a.in
    auto tc = test.getTest();
    rand(tc.T, 1, MAX_RANGE, MAX_N);
    test << tc;
  }
  { // sza6b.in
    auto tc = test.getTest();
    rand(tc.T, 1, MAX_RANGE, MAX_N);
    sort(tc.T.begin(), tc.T.end());
    tc.T.resize(unique(tc.T.begin(), tc.T.end()) - tc.T.begin());
    test << tc;
  }
  { // sza6c.in
    auto tc = test.getTest();
    long_equal(tc.T, MAX_N - 5, {1 << 20, 1 << 21, 1 << 22}, 20);
    tc.T.push_back(1);
    tc.T.push_back(1);
    tc.T.push_back(1);
    tc.T.push_back(1);
    test.shuffle(tc.T); // like this
    test << tc;
  }
  { // sza6d.in
    auto tc = test.getTest();
    long_equal(tc.T, MAX_N - 7, {1 << 20, 1 << 21, 1 << 22}, 10);
    test.shuffle(tc.T.begin(), tc.T.end()); // or like this
    test << tc;
  }
  { // sza6e.in
    auto tc = test.getTest();
    long_equal(tc.T, MAX_N - 7, {5 << 20, 5 << 21, 1 << 22}, 10);
    test << tc;
  }
  { // sza6f.in
    auto tc = test.getTest();
    long_equal(tc.T, MAX_N / 3, {5 << 20, 5 << 21, 1 << 22}, 20);
    rand(tc.T, 1, MAX_RANGE, MAX_N / 3);
    long_equal(tc.T, MAX_N / 3, {5 << 20, 5 << 21, 1 << 22}, 20);
    test << tc;
  }
  { // sza6g.in
    auto tc = test.getTest();
    tc.T.push_back(17);
    test << tc;
  }
  { // sza6h.in
    auto tc = test.getTest();
    tc.T.push_back(9);
    tc.T.push_back(12);
    test << tc;
  }
  { // sza6i.in
    auto tc = test.getTest();
    rand(tc.T, 7, 7, MAX_N);
    test << tc;
  }
  { // sza6j.in
    auto tc = test.getTest();
    tc.do_something(test);
    test << tc;
  }
}
