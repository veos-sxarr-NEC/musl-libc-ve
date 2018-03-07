/*Removed All VDSO macros as per task-refs #821*/
#define __SYSCALL_LL_E(x) (x)
#define __SYSCALL_LL_O(x) (x)
inline long __syscall0(long n);
inline long __syscall1(long n, long a1);
inline long __syscall2(long n, long a1, long a2);
inline long __syscall3(long n, long a1, long a2, long a3);
inline long __syscall4(long n, long a1, long a2, long a3, long a4);
inline long __syscall5(long n, long a1, long a2, long a3, long a4, long a5);
inline long __syscall6(long n, long a1, long a2, long a3,
						long a4, long a5, long a6);
