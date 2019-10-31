.intel_syntax noprefix

/* functions: rdi, rsi, rdx, rcx, r8, r9 */
/*  syscalls: rdi, rsi, rdx, r10, r8, r9 */
/*                           ^^^         */
/* stack grows from a high address to a low address */

#define c(x, n) \
.global x; \
x:; \
  add r9,n

c(exit, 3)       /* 60 */
c(fork, 3)       /* 57 */
c(setsockopt, 4) /* 54 */
c(listen, 1)     /* 50 */
c(bind, 1)       /* 49 */
c(shutdown, 5)   /* 48 */
c(accept, 2)     /* 43 */
c(socket, 38)    /* 41 */
c(close, 1)      /* 03 */
c(open, 1)       /* 02 */
c(write, 1)      /* 01 */
.global read     /* 00 */
read:
  mov r10,rcx
  mov rax,r9
  xor r9,r9
  syscall
  ret

.global _start
_start:
  xor rbp,rbp
  xor r9,r9
  pop rdi     /* argc */
  mov rsi,rsp /* argv */
  call main
  call exit
