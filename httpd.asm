; elf header see http://muppetlabs.com/~breadbox/software/tiny/teensy.html

BITS 64

        org     0x08048000

ehdr:                                           ; Elf32_Ehdr
        db      0x7F, "ELF", 2, 1, 1, 0         ;   e_ident
?_033:
        db      "usage: ", 0
        dw      2                               ;   e_type
        dw      62                              ;   e_machine
        dd      1                               ;   e_version
        dq      _start                          ;   e_entry
        dq      phdr - $$                       ;   e_phoff
?_034:
        db      " port fi"                      ;   e_shoff
        db      "le", 10, 0                     ;   e_flags
        dw      ehdrsize                        ;   e_ehsize
        dw      phdrsize                        ;   e_phentsize
phdr:                                                           ; Elf32_Phdr
        dd      1                               ;   e_phnum     ;   p_type
                                                ;   e_shentsize
        dd      5                               ;   e_shnum     ;   p_flags
                                                ;   e_shstrndx

ehdrsize      equ     $ - ehdr

        dq      0                               ;   p_offset
        dq      $$                              ;   p_vaddr
        dq      $$                              ;   p_paddr
        dq      filesize                        ;   p_filesz
        dq      filesize                        ;   p_memsz
        dq      0x1000                          ;   p_align

phdrsize      equ     $ - phdr

_start:
        xor     rbp, rbp
        xor     r9, r9
        pop     rdi
        mov     rsi, rsp
        push    r14
        push    r13
        push    r12
        push    rbp
        push    rbx
        mov     rbx, rsi
        sub     rsp, 8224
        cmp     edi, 3
        jnz     ?_004
        mov     rcx, qword [rsi+8H]
        xor     eax, eax
?_002:  movsx   dx, byte [rcx]
        test    dl, dl
        jz      ?_003
        lea     esi, [rdx-30H]
        cmp     sil, 9
        ja      ?_004
        imul    eax, eax, 10
        inc     rcx
        lea     eax, [rax+rdx-30H]
        jmp     ?_002

?_003:  xchg    al, ah
        test    ax, ax
        jnz     ?_007
?_004:  mov     rbp, qword [rbx]
        mov     edx, 7
        mov     edi, 1
        lea     rsi, [rel ?_033]
        call    ?_027
        mov     rdx, rbp
?_005:  cmp     byte [rdx], 0
        jz      ?_006
        inc     rdx
        jmp     ?_005

?_006:  sub     rdx, rbp
        mov     rsi, rbp
        mov     edi, 1
        call    ?_027
        mov     edx, 11
        mov     edi, 1
        lea     rsi, [rel ?_034]
        call    ?_027
        mov     edi, 1
        call    ?_017
        xor     eax, eax
?_007:  xorps   xmm0, xmm0
        lea     rsi, [rsp+0CH]
        lea     rdi, [rsp+10H]
        mov     edx, 4
        movups  oword [rsp+10H], xmm0
        mov     dword [rsp+0CH], 1
        mov     word [rsp+10H], 2
        mov     word [rsp+12H], ax
        call    ?_029
        mov     r13d, eax
?_008:  xor     edx, edx
        xor     esi, esi
        mov     edi, r13d
        call    ?_023
        mov     ebp, eax
        test    eax, eax
        js      ?_008
        xor     eax, eax
        call    ?_018
        mov     r12d, eax
        test    eax, eax
        jnz     ?_008
        mov     r14, qword [rbx+10H]
        lea     r13, [rsp+20H]
?_009:  mov     edx, 8192
        mov     rsi, r13
        mov     edi, ebp
        call    ?_028
        mov     ebx, eax
        test    eax, eax
        jle     ?_010
        mov     edx, ebx
        mov     rsi, r13
        mov     edi, 1
        call    ?_027
        movsxd  rax, ebx
        lea     rax, [r13+rax-3H]
        cmp     ebx, 2
        jg      ?_011
?_010:  xor     esi, esi
        mov     rdi, r14
        call    ?_026
        mov     ebx, eax
        test    eax, eax
        jns     ?_012
        mov     edx, 39
        lea     rsi, [rel ?_035]
        mov     edi, ebp
        call    ?_027
        jmp     ?_015

?_011:  cmp     byte [rax], 10
        jnz     ?_009
        cmp     byte [rax+1H], 13
        jnz     ?_009
        cmp     byte [rax+2H], 10
        jnz     ?_009
        jmp     ?_010

?_012:  mov     edx, 19
        lea     rsi, [rel ?_036]
        mov     edi, ebp
        call    ?_027
?_013:  mov     edx, 8192
        mov     rsi, r13
        mov     edi, ebx
        call    ?_028
        mov     edx, eax
        test    eax, eax
        jle     ?_014
        mov     rsi, r13
        mov     edi, ebp
        call    ?_027
        test    eax, eax
        jns     ?_013
        jmp     ?_015

?_014:  mov     edi, ebp
        mov     esi, 2
        call    ?_022
        mov     edi, ebp
        call    ?_025
        jmp     ?_016

?_015:  mov     r12d, 1
?_016:  add     rsp, 8224
        mov     eax, r12d
        pop     rbx
        pop     rbp
        pop     r12
        pop     r13
        pop     r14
        call    ?_017

?_017:
        add     r9, 3
?_018:  add     r9, 3
?_019:  add     r9, 4
?_020:  add     r9, 1
?_021:  add     r9, 1
?_022:  add     r9, 5
?_023:  add     r9, 2
?_024:  add     r9, 38
?_025:  add     r9, 1
?_026:  add     r9, 1
?_027:  add     r9, 1
?_028:  mov     r10, rcx
        mov     rax, r9
        xor     r9, r9
        syscall
        ret


?_029:
        push    r13
        mov     r13, rsi
        mov     esi, 1
        push    r12
        push    rbp
        mov     rbp, rdi
        mov     edi, 2
        sub     rsp, 16
        mov     dword [rsp+0CH], edx
        mov     edx, 6
        call    ?_024
        mov     r8d, dword [rsp+0CH]
        test    eax, eax
        mov     r12d, eax
        jns     ?_031
?_030:  mov     edi, 1
        call    ?_017
        jmp     ?_032

?_031:  mov     rcx, r13
        mov     edx, 2
        mov     esi, 1
        mov     edi, eax
        call    ?_019
        test    eax, eax
        jnz     ?_030
        mov     edx, 16
        mov     rsi, rbp
        mov     edi, r12d
        call    ?_021
        test    eax, eax
        jnz     ?_030
        mov     esi, 10
        mov     edi, r12d
        call    ?_020
        test    eax, eax
        jnz     ?_030
?_032:  add     rsp, 16
        mov     eax, r12d
        pop     rbp
        pop     r12
        pop     r13
        ret

?_035:
        db "HTTP/1.1 404 Not Found"
        db 0DH, 0AH, 0DH, 0AH
        db "404 Not Found", 0

?_036:
        db "HTTP/1.1 200 OK"
        db 0DH, 0AH, 0DH, 0AH, 0

filesize      equ     $ - $$
