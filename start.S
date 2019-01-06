.intel_syntax noprefix

/* functions: rdi, rsi, rdx, rcx, r8, r9 */
/*  syscalls: rdi, rsi, rdx, r10, r8, r9 */
/*                           ^^^         */
/* stack grows from a high address to a low address */

.global _syscall
_syscall:
  mov r10,rcx
  syscall
  ret

#define c(x, n) \
.global x; \
x:; \
  mov eax,n; \
  jmp _syscall

c(read, 0)
c(write, 1)
c(open, 2)
c(close, 3)
c(socket, 41)
c(accept, 43)
c(shutdown, 48)
c(bind, 49)
c(listen, 50)
c(setsockopt, 54)
c(fork, 57)
c(exit, 60)

.global _start
_start:
  xor rbp,rbp
  pop rdi     /* argc */
  mov rsi,rsp /* argv */
  call main
  call exit
