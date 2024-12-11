.data
    op_no: .space 4
    op: .space 4
    n: .space 4
    desc: .space 4
    size: .space 4
    block_size: .long 8

    formatStringScanf: .asciz "%ld"
    formatStringPrintf: .asciz "%ld\n"
    formatStringFile: .asciz "%ld: (%ld, %ld)\n"
    formatStringIntv: .asciz "(%ld, %ld)\n"
    formatStringMemElem: .asciz "%ld "
    newLine: .asciz "\n"

    max_size: .long 1024
    mem: .space 4096
.text

/*helpers*/
/*(id, left, right)*/
printFile: 
    pushl %ebp
    movl %esp, %ebp
    pushl 16(%ebp)
    pushl 12(%ebp)
    pushl 8(%ebp)
    pushl $formatStringFile
    call printf
    add $16, %esp
    popl %ebp
    ret

/*left right */
printIntv:
    pushl %ebp
    movl %esp, %ebp
    pushl 8(%ebp)
    pushl 12(%ebp)
    pushl $formatStringIntv
    call printf
    add $12, %esp
    popl %ebp
    ret


/*returns no of blocks for the size given as parameter*/
SIZE_TO_BLOCKS:
    pushl %ebp
    movl %esp, %ebp

    movl 8(%ebp), %eax
    movl block_size, %ecx
    movl $0, %edx
    div %ecx
    
    cmp $0, %edx
    je ret_size_to_blocks
    inc %eax

    ret_size_to_blocks: 
        /*returns %eax*/
        popl %ebp   
        ret

PRINT_MEMORY:
    pushl %ebp
    movl %esp, %ebp

    xor %ecx, %ecx
    loop_print_memory:
        cmpl max_size, %ecx
        je ret_print_memory

        pushl %ecx
        pushl (%edi, %ecx, 4)
        pushl $formatStringMemElem
        call printf
        add $8, %esp
        popl %ecx

        inc %ecx
        jmp loop_print_memory

    ret_print_memory:
        popl %ebp   
        ret

/*return (start, end) from (start, no_blocks)*/
CONVERT_IDX_BNUM:
    pushl %ebp
    movl %esp, %ebp

    movl 8(%ebp), %eax
    movl 8(%ebp), %ebx
    addl 12(%ebp), %ebx
    sub $1, %ebx

    popl %ebp   
    ret

PRINT_MEMORY_INTERVALS:
    pushl %ebp
    movl %esp, %ebp

    movl $0, %ecx

    loop_print_memory_intervals:
        cmp max_size, %ecx
        jge ret_print_memory_intervals

        movl (%edi, %ecx, 4), %edx
        cmp $0, %edx
        jne new_memory_seq

        inc %ecx
        jmp loop_print_memory_intervals

    new_memory_seq:
        pushl %ecx
        pushl %edx
        call GET_FILE
        popl %edx
        popl %ecx

        pushl %ecx
        pushl %ebx
        pushl %eax
        pushl %edx
        call printFile
        popl %edx
        popl %eax
        popl %ebx
        popl %ecx

        movl %ebx, %ecx
        inc %ecx
        jmp loop_print_memory_intervals
        
    ret_print_memory_intervals:
        /*pushl $newLine
        call printf
        add $4, %esp*/

        popl %ebp
        ret

/*returns the max number of free blocks starting at an idx (idx)*/
LONGEST_MEM_SEQ:
    pushl %ebp
    movl %esp, %ebp

    movl 8(%ebp), %ecx

    loop_longest_mem_seq:
        cmp max_size, %ecx
        je return_longest_mem_seq

        cmp $0, (%edi, %ecx, 4)
        jne return_longest_mem_seq
        
        inc %ecx
        jmp loop_longest_mem_seq

    return_longest_mem_seq:
        movl 8(%ebp), %eax
        sub %eax, %ecx
        movl %ecx, %eax

        popl %ebp
        ret

/*fills the memory seq with desc (start, end, desc)*/
FILL_MEM_SEQ:
    pushl %ebp
    movl %esp, %ebp

    movl 8(%ebp), %ecx
    movl 12(%ebp), %edx
    add $1, %edx

    loop_fill_mem_seq:
        cmp %ecx, %edx
        je return_fill_mem_seq

        movl 16(%ebp), %eax
        movl %eax, (%edi, %ecx, 4)

        inc %ecx
        jmp loop_fill_mem_seq


    return_fill_mem_seq:
        popl %ebp
        ret

/*given file descriptor return (start, end) in memory*/
GET_FILE: 
    pushl %ebp
    movl %esp, %ebp

    movl $0, %ecx
    loop_get_file:
        cmp max_size, %ecx
        je ret_get_file_not_found
        
        movl (%edi, %ecx, 4), %edx
        cmp 8(%ebp), %edx
        je get_file_found

        inc %ecx
        jmp loop_get_file

    get_file_found:
        mov %ecx, %eax
        loop_find_continous_sequence:
            cmp max_size, %ecx
            je get_file_end_seq

            movl (%edi, %ecx, 4), %edx
            cmp 8(%ebp), %edx
            jne get_file_end_seq

            inc %ecx
            jmp loop_find_continous_sequence

        get_file_end_seq:
            dec %ecx
            movl %ecx, %ebx
            popl %ebp
            ret

    ret_get_file_not_found:
        movl $0, %eax
        movl $0, %ebx
        popl %ebp
        ret

/*adds file with desc and block_no (block_no, desc)*/
ADD_FILE:
    pushl %ebp
    movl %esp, %ebp

    movl $0, %ecx

    loop_add_file:
        cmp max_size, %ecx
        jge add_file_failed_return

        cmp $0, (%edi, %ecx, 4)
        je add_file_try_pos

        inc %ecx
        jmp loop_add_file

    add_file_try_pos:
        pushl %ecx
        call LONGEST_MEM_SEQ
        popl %ecx

        cmp 8(%ebp), %eax
        jge add_file_and_return

        addl %eax, %ecx
        inc %ecx
        jmp loop_add_file

        add_file_and_return:
            pushl 8(%ebp)
            pushl %ecx
            call CONVERT_IDX_BNUM
            popl %ecx
            add $4, %esp

            pushl 12(%ebp)
            pushl %ebx
            pushl %eax
            call FILL_MEM_SEQ
            add $12, %esp

            mov $1, %eax
            popl %ebp
            ret

    add_file_failed_return:
        mov $0, %eax
        popl %ebp
        ret

ADD_PROC:
    pushl %ebp
    movl %esp, %ebp

    pushl $n
    pushl $formatStringScanf
    call scanf
    add $8, %esp

    xorl %ecx, %ecx

    add_proc_loop:
        cmp n, %ecx
        je return_proc_loop

        pushl %ecx
        pushl $desc
        pushl $formatStringScanf
        call scanf
        add $8, %esp
        popl %ecx

        pushl %ecx
        pushl $size
        pushl $formatStringScanf
        call scanf
        add $8, %esp
        popl %ecx

        pushl %ecx
        pushl size
        call SIZE_TO_BLOCKS
        add $4, %esp
        popl %ecx

        movl %eax, size

        pushl %ecx
        pushl desc
        pushl size
        call ADD_FILE
        add $8, %esp
        popl %ecx

        inc %ecx
        jmp add_proc_loop


    return_proc_loop:
        call PRINT_MEMORY_INTERVALS
        popl %ebp
        ret

GET_PROC:
    pushl %ebp
    movl %esp, %ebp

    pushl $desc
    pushl $formatStringScanf
    call scanf
    add $8, %esp

    pushl desc
    call GET_FILE
    add $4, %esp
    
    pushl %eax
    pushl %ebx
    call printIntv
    add $8, %esp

    /*pushl $newLine
    call printf
    add $4, %esp*/

    popl %ebp
    ret

DEL_PROC:
    pushl %ebp
    movl %esp, %ebp

    pushl $desc
    pushl $formatStringScanf
    call scanf
    add $8, %esp

    pushl desc
    call GET_FILE
    add $4, %esp

    pushl $0
    pushl %ebx
    pushl %eax
    call FILL_MEM_SEQ
    add $12, %esp

    call PRINT_MEMORY_INTERVALS
    popl %ebp
    ret

/*removes the element at a given index; (index,top)*/
REMOVE_ELEMENT_ARRAY:
    pushl %ebp
    movl %esp, %ebp

    movl 8(%ebp), %ecx
    movl 12(%ebp), %edx
    dec %edx

    loop_remove_element_array:
        cmp %ecx, %edx
        je ret_remove_element_array

        inc %ecx
        movl (%edi, %ecx, 4), %eax
        dec %ecx
        movl %eax, (%edi, %ecx, 4)

        inc %ecx
        jmp loop_remove_element_array

    ret_remove_element_array:
        movl $0, (%edi, %ecx, 4)
        popl %ebp
        ret


DEFRAG_PROC:
    pushl %ebp
    movl %esp, %ebp

    movl $0, %ecx
    movl max_size, %edx

    loop_defrag_proc:
        cmp %edx, %ecx
        jge ret_defrag_proc

        movl (%edi, %ecx, 4), %eax
        cmp $0, %eax
        je free_space_defrag_proc   

        inc %ecx
        jmp loop_defrag_proc

    free_space_defrag_proc:
        pushl %edx
        pushl %ecx
        call REMOVE_ELEMENT_ARRAY
        popl %ecx
        popl %edx

        dec %edx

        jmp loop_defrag_proc

    ret_defrag_proc:
        call PRINT_MEMORY_INTERVALS
        popl %ebp
        ret

.global main
main:
    lea mem, %edi

    pushl $op_no
    pushl $formatStringScanf
    call scanf
    add $8, %esp


    xor %ecx, %ecx
    loop_operations:
        cmp op_no, %ecx
        jge exit

        pushl %ecx
        pushl $op
        push $formatStringScanf
        call scanf
        add $8, %esp
        popl %ecx

        cmp $1, op
        je case_add_proc
        
        cmp $2, op
        je case_get_proc

        cmp $3, op
        je case_delete_proc

        cmp $4, op
        je case_defrag_proc

        inc %ecx
        jmp loop_operations

    case_add_proc:
        pushl %ecx
        call ADD_PROC
        popl %ecx
        inc %ecx
        jmp loop_operations
    
    case_get_proc:
        pushl %ecx
        call GET_PROC
        popl %ecx
        inc %ecx
        jmp loop_operations

    case_delete_proc:
        pushl %ecx
        call DEL_PROC
        popl %ecx
        inc %ecx
        jmp loop_operations

    case_defrag_proc:
        pushl %ecx
        call DEFRAG_PROC
        popl %ecx
        inc %ecx
        jmp loop_operations

exit:
    mov $1, %eax
    xor %ebx,%ebx
    int $0x80
