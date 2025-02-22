; - code disassembled from C executable with `objconv -fnasm httpd temp.asm`
; - tweaked by prepending _start to _001 and removing the exit call
; - tiny elf header see http://muppetlabs.com/~breadbox/software/tiny/teensy.html

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

?_001:
        push    r14
        push    r13
        push    r12
        mov     r12, rsi
        push    rbp
        push    rbx
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

?_003:  mov     edx, eax
        xchg    dl, dh
        test    ax, ax
        jnz     ?_007
?_004:  mov     rbx, qword [r12]
        mov     edx, 7
        mov     edi, 1
        lea     rsi, [rel ?_033]
        call    ?_027
        mov     rdx, rbx
?_005:  cmp     byte [rdx], 0
        jz      ?_006
        inc     rdx
        jmp     ?_005

?_006:  sub     edx, ebx
        mov     rsi, rbx
        mov     edi, 1
        call    ?_027
        mov     edx, 11
        mov     edi, 1
        lea     rsi, [rel ?_034]
        call    ?_027
        mov     edi, 1
        call    ?_018
        xor     edx, edx
?_007:  mov     word [rsp+12H], dx
        xor     eax, eax
        xor     ecx, ecx
        lea     rsi, [rsp+0CH]
        lea     rdi, [rsp+10H]
        mov     edx, 4
        mov     qword [rsp+14H], rax
        mov     dword [rsp+0CH], 1
        mov     dword [rsp+1CH], ecx

        mov     word [rsp+10H], 2
        call    ?_029
        mov     r13d, eax
?_008:  xor     ecx, ecx
        xor     esi, esi
        or      edi, 0FFFFFFFFH
        mov     edx, 1
        call    ?_017
        test    eax, eax
        jg      ?_008
        xor     edx, edx
        xor     esi, esi
        mov     edi, r13d
        call    ?_023
        mov     ebx, eax
        test    eax, eax
        js      ?_015
        xor     eax, eax
        call    ?_019
        mov     ebp, eax
        test    eax, eax
        jne     ?_015
        mov     r13, qword [r12+10H]
        lea     r12, [rsp+20H]
?_009:  mov     edx, 8192
        mov     rsi, r12
        mov     edi, ebx
        call    ?_028
        mov     r14d, eax
        test    eax, eax
        jle     ?_010
        mov     edx, r14d
        mov     rsi, r12
        mov     edi, 1
        call    ?_027
        lea     edx, [r14-3H]
        movsxd  rdx, edx
        add     rdx, r12
        cmp     r14d, 2
        jg      ?_011
?_010:  mov     rdi, r13
        xor     esi, esi
        call    ?_026
        mov     r13d, eax
        test    eax, eax
        jns     ?_012
        mov     edx, 39
        lea     rsi, [rel ?_035]
        mov     edi, ebx
        call    ?_027
        jmp     ?_014

?_011:  cmp     byte [rdx], 10
        jnz     ?_009
        cmp     byte [rdx+1H], 13
        jnz     ?_009
        cmp     byte [rdx+2H], 10
        jnz     ?_009
        jmp     ?_010

?_012:  mov     edx, 19
        lea     rsi, [rel ?_036]
        mov     edi, ebx
        call    ?_027
?_013:  mov     edx, 8192
        mov     rsi, r12
        mov     edi, r13d
        call    ?_028
        mov     edx, eax
        test    eax, eax
        jle     ?_016
        mov     rsi, r12
        mov     edi, ebx
        call    ?_027
        test    eax, eax
        jns     ?_013
?_014:  mov     ebp, 1
        jmp     ?_016

?_015:  mov     edi, ebx
        call    ?_025
        jmp     ?_008

?_016:
        add     rsp, 8224
        mov     eax, ebp
        pop     rbx
        pop     rbp
        pop     r12
        pop     r13
        pop     r14
        ret

?_017:
        add     r9, 1
?_018:  add     r9, 3
?_019:  add     r9, 3
?_020:  add     r9, 4
?_021:  add     r9, 1
?_022:  add     r9, 6
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
        push    r12
        mov     r12, rsi
        mov     esi, 1
        push    rbp
        mov     rbp, rdi
        mov     edi, 2
        push    rbx
        sub     rsp, 16
        mov     dword [rsp+0CH], edx
        mov     edx, 6
        call    ?_024
        mov     r8d, dword [rsp+0CH]
        test    eax, eax
        mov     ebx, eax
        jns     ?_031
?_030:  mov     edi, 1
        call    ?_018
        jmp     ?_032

?_031:  mov     rcx, r12
        mov     edx, 2
        mov     esi, 1
        mov     edi, eax
        call    ?_020
        test    eax, eax
        jnz     ?_030
        mov     edx, 16
        mov     rsi, rbp
        mov     edi, ebx
        call    ?_022
        test    eax, eax
        jnz     ?_030
        mov     esi, 10
        mov     edi, ebx
        call    ?_021
        test    eax, eax
        jnz     ?_030
?_032:  add     rsp, 16
        mov     eax, ebx
        pop     rbx
        pop     rbp
        pop     r12
        ret

?_035:
        db "HTTP/1.1 404 Not Found"
        db 0DH, 0AH, 0DH, 0AH
        db "404 Not Found"

?_036:
        db "HTTP/1.1 200 OK"
        db 0DH, 0AH, 0DH, 0AH

filesize      equ     $ - $$
