//Author by [Rainboy](https://github.com/rainboylvx)
//date: 2025-10-02 10:34:43

//oisnip_begin 头文件
#include <algorithm>
#include <bitset>
#include <complex>
#include <deque>
#include <exception>
#include <fstream>
#include <functional>
#include <iomanip>
#include <ios>
#include <iosfwd>
#include <iostream>
#include <istream>
#include <iterator>
#include <limits>
#include <list>
#include <locale>
#include <map>
#include <memory>
#include <new>
#include <numeric>
#include <ostream>
#include <queue>
#include <set>
#include <sstream>
#include <stack>
#include <stdexcept>
#include <streambuf>
#include <string>
#include <typeinfo>
#include <utility>
#include <valarray>
#include <vector>
//oisnip_end 
using namespace std;

typedef long long ll;

// #define NO_DEBUG // switch debug
#if defined(onlinejudge) || defined(ONLINE_JUDGE) || defined(NO_DEBUG)
#define log(...)
#else
#define log(args...) { cout << "LINE:" << __LINE__ << " : ";string _s = #args; replace(_s.begin(), _s.end(), ',', ' '); stringstream _ss(_s); istream_iterator<string> _it(_ss); err(_it, args); }
void err(istream_iterator<string> it) {}

template<typename T>
void err(istream_iterator<string> it, T a) {
cerr << *it << " = " << a << "\n";
}

template<typename T, typename... Args>
void err(istream_iterator<string> it, T a, Args... args) {
cerr << *it << " = " << a << ", ";
err(++it, args...);
}
#endif
const int maxn = 1e6+5;
int n,m;
int a[maxn];

void init() {

}

int main () {
    std::ios::sync_with_stdio(false); cin.tie(0); cout.tie(0); // 关闭io同步


    return 0;
}
