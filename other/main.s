.data
    dir_path: .asciz "/home/petru/text-files/"
    formatPrintf: .asciz "%ld\n"
    buffer: .space 1024
.text

process_file:
    pushl %ebp
    movl %esp, %ebp

    pusha
    pushl 8(%ebp)
    pushl $formatPrintf
    call printf
    add $8, %esp
    popa

    ret_process_file:
        popl %ebp
        ret

.global main
main:
    movl $5, %eax
    movl $dir_path, %ebx
    movl $0, %ecx
    int $0x80

    movl %eax, %ebx

    movl $141, %eax
    movl $buffer, %ecx
    movl $1024, %edx
    int $0x80

    lea buffer, %esi
    movl %esi, %edi
    addl %eax, %edi

entries:
    cmpl %edi, %esi
    jge exit

    movl 4(%esi), %ecx
    addl $8, %esi

    pushl %esi
    call process_file
    addl $4, %esp

    addl %ecx, %esi
    jmp entries
  

exit:
    movl $1, %eax
    xorl %ebx, %ebx
    int $0x80