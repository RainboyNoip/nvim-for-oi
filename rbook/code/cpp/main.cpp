// Author by [Rainboy](https://github.com/rainboylvx)

// 只留常用头。按需补：<map> <set> <queue> <stack> <bitset> <numeric>
//                     <functional> <iomanip> <climits> <deque>
// 刻意不用 <bits/stdc++.h>：本机是 Apple clang，没有这个头，
// clangd 解析不了会连带失去 std 补全（见 docs/config-optimization.md §2.2）。
#include <algorithm>
#include <iostream>
#include <sstream>
#include <string>
#include <vector>

using namespace std;

typedef long long ll;
const int maxn = 1e6 + 5;
const int INF = 0x3f3f3f3f;

int n, m;

// 调试宏：提交时带 -D onlinejudge 或 -D NO_DEBUG 自动失效。
#if defined(onlinejudge) || defined(ONLINE_JUDGE) || defined(NO_DEBUG)
#define log(...)
#define fenc
#else
void err(istream_iterator<string> it) {}
template <typename T>
void err(istream_iterator<string> it, T a) {
    cerr << *it << " = " << a << "\n";
}
template <typename T, typename... Args>
void err(istream_iterator<string> it, T a, Args... args) {
    cerr << *it << " = " << a << ", ";
    err(++it, args...);
}
#define log(args...)                                            \
    {                                                           \
        cout << "LINE:" << __LINE__ << " : ";                   \
        string _s = #args;                                      \
        replace(_s.begin(), _s.end(), ',', ' ');                \
        stringstream _ss(_s);                                   \
        istream_iterator<string> _it(_ss);                      \
        err(_it, args);                                         \
    }
#define fenc cout << "================================" << "\n";
#endif

void init() {}

int main() {
    ios::sync_with_stdio(false);
    cin.tie(nullptr);

    init();

    return 0;
}
