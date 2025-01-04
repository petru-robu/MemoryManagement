.data   
    op_no: .space 4
    op: .space 4
    elem: .space 4
    desc: .space 4
    size: .space 4
    nr: .space 4
    
    block_size: .long 8
    
    formatStringScanfPath: .asciz "%127s"
    formatStringScanf: .asciz "%ld"
    formatStringElem: .asciz "%ld "
    formatStringPrintf: .asciz "%ld\n"
    formatStringPair: .asciz "((%ld, %ld), (%ld, %ld))\n"
    formatStringFile: .asciz "%ld: ((%ld, %ld), (%ld, %ld))\n"
    newLine: .asciz "\n"
    formatStr:  .asciz "%s\n"
    formatLong: .asciz "%ld\n"                
    formatConcreteFile: .asciz "File name: %s\nSize in kb: %ld\nFile Descriptor: %ld\n\n"
    
    dirname:    .space 128

    dotStr:     .asciz "."               
    dotDotStr:  .asciz ".."              
    emptyStr: .asciz ""
    concatStr: .asciz "/home/petru/files/"    
    
    buffer:    .space 4096
    buffstat: .space 64

    n: .long 1024
    matrix_size: .long 1048576
    matrix: .space 4194304

    
    /*n: .long 200
    matrix_size: .long 40000
    matrix: .space 160000*/

.text

/*helpers*/
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

/*print_row (row_idx)*/
print_row:
    pushl %ebp
    movl %esp, %ebp
    pushl %ebx

    movl 8(%ebp), %eax
    movl n, %ebx
    xor %edx, %edx
    mull %ebx

    xor %ecx, %ecx
    print_row_loop:
        cmp n, %ecx
        je ret_print_row

        movl (%edi, %eax, 4), %ebx

        pusha
        pushl %ebx
        pushl $formatStringElem
        call printf
        add $8, %esp
        popa

        inc %ecx
        inc %eax
        jmp print_row_loop

    ret_print_row:
        pushl $0
        call fflush
        add $4, %esp

        pushl $newLine
        call printf
        add $4, %esp

        popl %ebx
        popl %ebp
        ret

print_matrix:
    pushl %ebp
    movl %esp, %ebp
    
    xor %ecx, %ecx

    print_matrix_row_loop:
        cmp n, %ecx
        je ret_print_matrix

        pushl %ecx
        call print_row
        popl %ecx

        inc %ecx
        jmp print_matrix_row_loop

    ret_print_matrix:
        popl %ebp
        ret

/*read_row(row_idx)*/
read_row:
    pushl %ebp
    movl %esp, %ebp
    pushl %ebx

    movl 8(%ebp), %eax
    movl n, %ebx
    xor %edx, %edx
    mull %ebx

    xor %ecx, %ecx
    read_row_loop:
        cmp n, %ecx
        je ret_read_row

        pusha
        pushl $elem
        pushl $formatStringScanf
        call scanf
        add $8, %esp
        popa

        movl elem, %ebx
        movl %ebx, (%edi, %eax, 4)

        inc %ecx
        inc %eax
        jmp read_row_loop

    ret_read_row:
        popl %ebx
        popl %ebp
        ret


read_matrix:
    pushl %ebp
    movl %esp, %ebp
    xor %ecx, %ecx

    read_matrix_loop:
        cmp n, %ecx
        je ret_read_matrix

        pushl %ecx
        call read_row
        popl %ecx

        inc %ecx
        jmp read_matrix_loop

    ret_read_matrix:
        popl %ebp
        ret


/*desc_end_pos(lineidx, start) ->end*/
DESC_END_POS_ON_LINE:
    pushl %ebp
    movl %esp, %ebp
    pushl %ebx

    movl 8(%ebp), %eax
    movl n, %ebx
    xor %edx, %edx
    mull %ebx

    movl 12(%ebp), %ecx
    addl %ecx, %eax

    movl (%edi, %eax, 4), %ebx

    desc_end_pos_loop:
        cmp n, %ecx
        jge ret_desc_end_pos

        movl (%edi, %eax, 4), %edx
        cmp %edx, %ebx
        jne ret_desc_end_pos

        inc %ecx
        inc %eax
        jmp desc_end_pos_loop

    ret_desc_end_pos:
        dec %ecx
        movl %ecx, %eax
        popl %ebx
        popl %ebp
        ret


/*print_memory_intervals_row(rowidx)*/
PRINT_MEMORY_INTERVALS_ROW:
    pushl %ebp
    movl %esp, %ebp
    pushl %ebx

    movl 8(%ebp), %eax
    movl n, %ebx
    xor %edx, %edx
    mull %ebx

    sub $8, %esp

    xor %ecx, %ecx
    print_memory_intervals_loop:
        cmp n, %ecx
        jge print_memory_intervals_row_ret

        movl (%edi, %eax, 4), %ebx
        cmp $0, %ebx
        je print_memory_intervals_continue

        pushl %eax
        pushl %ecx
        pushl 8(%ebp)
        call DESC_END_POS_ON_LINE
        movl %eax, -4(%ebp)
        add $4, %esp
        popl %ecx
        popl %eax

        /*print*/
        pushl %eax
        pushl %ecx
        pushl -4(%ebp)
        pushl 8(%ebp)
        pushl %ecx
        pushl 8(%ebp)
        pushl %ebx
        pushl $formatStringFile
        call printf
        add $24, %esp
        popl %ecx
        popl %eax

        addl -4(%ebp), %eax
        subl %ecx, %eax
        inc %eax

        movl -4(%ebp), %ecx
        inc %ecx
    
        jmp print_memory_intervals_loop

    print_memory_intervals_continue:
        inc %ecx
        inc %eax
        jmp print_memory_intervals_loop


    print_memory_intervals_row_ret:
        popl %ebx
        popl %ebp
        addl $8, %esp
        ret


PRINT_MEMORY_INTERVALS:
    pushl %ebp
    movl %esp, %ebp 

    xor %ecx, %ecx
    loop_print_memory_intervals:
        cmp n, %ecx
        je print_memory_intervals_ret

        pushl %ecx
        call PRINT_MEMORY_INTERVALS_ROW
        popl %ecx

        inc %ecx
        jmp loop_print_memory_intervals

    print_memory_intervals_ret:
        popl %ebp
        ret

/*check_continous_space(i, j) -> maximum no. of blocks starting at (i,j)*/ 
CHECK_CONTINOUS_SPACE:
    pushl %ebp
    movl %esp, %ebp
    pushl %ebx

    movl 8(%ebp), %eax
    movl n, %ebx
    xor %edx, %edx
    mull %ebx

    movl 12(%ebp), %ecx
    addl %ecx, %eax

    check_continous_space_loop:
        cmp n, %ecx
        je check_continous_space_ret

        movl (%edi, %eax, 4), %ebx
        cmp $0, %ebx
        jne check_continous_space_ret

        inc %ecx
        inc %eax
        jmp check_continous_space_loop
        
    check_continous_space_ret:
        movl 12(%ebp), %eax
        subl %eax, %ecx
        movl %ecx, %eax

        popl %ebx
        popl %ebp
        ret

/*can_fit_on_line(line_idx, no_of_blocks) -> starting_pos*/
CAN_FIT_ON_LINE:
    pushl %ebp
    movl %esp, %ebp
    pushl %ebx

    movl 8(%ebp), %eax
    movl n, %ebx
    xor %edx, %edx
    mull %ebx

    xor %ecx, %ecx

    can_fit_on_line_loop:
        cmp n, %ecx
        jge can_fit_on_line_ret

        movl (%edi, %eax, 4), %ebx

        cmp $0, %ebx
        je can_fit_on_line_check_pos

        inc %ecx
        inc %eax
        jmp can_fit_on_line_loop

    can_fit_on_line_check_pos:
        pushl %eax
        pushl %ecx
        pushl 8(%ebp)
        call CHECK_CONTINOUS_SPACE
        addl $4, %esp
        popl %ecx
        movl %eax, %ebx
        popl %eax

        cmp 12(%ebp), %ebx
        jge can_fit_on_line_ret

        inc %ecx
        inc %eax
        jmp can_fit_on_line_loop

    can_fit_on_line_ret:
        movl %ecx, %eax
        popl %ebx
        popl %ebp
        ret

/*fill_space(desc, line_idx, start_idx, no_of_blocks)*/
FILL_SPACE:
    pushl %ebp
    movl %esp, %ebp
    pushl %ebx

    movl 12(%ebp), %eax
    movl n, %ebx
    xor %edx, %edx
    mull %ebx

    addl 16(%ebp), %eax
    movl 8(%ebp), %ebx

    xor %ecx, %ecx
    
    fill_space_loop:
        cmp 20(%ebp), %ecx
        je fill_space_ret

        movl %ebx, (%edi, %eax, 4)

        inc %eax
        inc %ecx
        jmp fill_space_loop


    fill_space_ret:
        popl %ebx
        popl %ebp
        ret


/*add_file(desc, no_of_blocks)*/
ADD_FILE:
    pushl %ebp
    movl %esp, %ebp
    
    xor %ecx, %ecx
    add_file_loop:
        cmp n, %ecx
        je add_file_ret

        pushl 12(%ebp)
        pushl %ecx
        call CAN_FIT_ON_LINE
        popl %ecx
        add $4, %esp

        cmp n, %eax
        jl add_file_found_avail

        inc %ecx
        jmp add_file_loop

    add_file_found_avail:
        pushl 12(%ebp)
        pushl %eax
        pushl %ecx
        pushl 8(%ebp)
        call FILL_SPACE
        addl $16, %esp

        jmp add_file_ret

    add_file_ret:
        popl %ebp
        ret

ADD_PROC:
    pushl %ebp
    movl %esp, %ebp

    pushl $nr
    pushl $formatStringScanf
    call scanf
    add $8, %esp

    xorl %ecx, %ecx

    add_proc_loop:
        cmp nr, %ecx
        je add_proc_ret

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

        movl size, %eax
        cmp $8, %eax
        jbe continue_adding_files
        
        cmp $8193, %eax
        jge can_not_add_file

        pushl %ecx
        pushl size
        call SIZE_TO_BLOCKS
        add $4, %esp
        popl %ecx

        movl %eax, size

        pushl %ecx
        pushl size
        pushl desc
        call ADD_FILE
        add $8, %esp
        popl %ecx

        pusha

        pushl desc
        call GET_FILE
        add $4, %esp

        pushl %ebx
        pushl %ecx
        pushl %eax
        pushl %ecx
        pushl desc
        pushl $formatStringFile
        call printf
        add $8, %esp
        popl %ecx
        popl %eax
        popl %ecx
        popl %ebx
        
        popa

    continue_adding_files:
        inc %ecx
        jmp add_proc_loop

    can_not_add_file:
        pusha
        pushl $0
        pushl $0
        pushl $0
        pushl $0
        pushl desc
        pushl $formatStringFile
        call printf
        add $24, %esp
        popa

        inc %ecx
        jmp add_proc_loop

    add_proc_ret:
        /*call PRINT_MEMORY_INTERVALS*/
        popl %ebp
        ret

/*SEARCH_FILE_ON_LINE(lineidx, desc) -> start_pos, end_pos*/
SEARCH_FILE_ON_LINE:
    pushl %ebp
    movl %esp, %ebp

    sub $4, %esp

    movl 8(%ebp), %eax
    movl n, %ebx
    xorl %edx, %edx
    mull %ebx
    
    xor %ecx, %ecx

    search_file_on_line_loop:
        cmp n, %ecx
        je search_file_on_line_not_found

        movl (%edi, %eax, 4), %ebx
        cmp 12(%ebp), %ebx
        je search_file_on_line_found

        inc %ecx
        inc %eax
        jmp search_file_on_line_loop

    search_file_on_line_found:
        movl %ecx, -4(%ebp)
        
        loop_find_continous_sequence:
            cmp n, %ecx
            je end_file_sequence

            movl (%edi, %eax, 4), %ebx

            cmp 12(%ebp), %ebx
            jne end_file_sequence

            inc %ecx
            inc %eax
            jmp loop_find_continous_sequence

        end_file_sequence:
            dec %ecx
            movl %ecx, %ebx
            movl -4(%ebp), %eax

            addl $4, %esp
            popl %ebp
            ret

    search_file_on_line_not_found:
        movl $0, %eax
        movl $0, %ebx

        addl $4, %esp
        popl %ebp
        ret


/*GET_FILE(desc) -> line, start_pos, size*/
GET_FILE:
    pushl %ebp
    movl %esp, %ebp

    xor %ecx, %ecx
    get_file_loop:
        cmp n, %ecx
        je get_file_ret

        pushl 8(%ebp)
        pushl %ecx
        call SEARCH_FILE_ON_LINE
        popl %ecx
        addl $4, %esp

        cmp %eax, %ebx
        jne found_file

        inc %ecx
        jmp get_file_loop

    found_file:
        popl %ebp
        ret

    get_file_ret:
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

    cmp %eax, %ebx
    je file_not_found_in_matrix

    pushl %ebx
    pushl %ecx
    pushl %eax
    pushl %ecx
    pushl $formatStringPair
    call printf
    add $4, %esp
    popl %ecx
    popl %eax
    popl %ecx
    popl %ebx

    jmp get_proc_ret

    file_not_found_in_matrix:
        xor %ecx, %ecx
        pushl %ebx
        pushl %ecx
        pushl %eax
        pushl %ecx
        pushl $formatStringPair
        call printf
        add $4, %esp
        popl %ecx
        popl %eax
        popl %ecx
        popl %ebx

    get_proc_ret:
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

    /*fill_space(desc, line_idx, start_idx, no_of_blocks)*/

    movl %ebx, %edx
    subl %eax, %edx
    inc %edx

    pushl %edx
    pushl %eax
    pushl %ecx
    pushl $0
    call FILL_SPACE
    add $16, %esp

    del_proc_ret:
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

/*returns the last non-zero element position*/
LAST_NON_ZERO_ELEMENT:
    pushl %ebp
    movl %esp, %ebp

    movl matrix_size, %ecx

    last_non_zero_loop:
        cmp $0, %ecx
        je ret_last_non_zero

        movl (%edi, %ecx, 4), %eax
        cmp $0, %eax
        jne ret_last_non_zero

        dec %ecx
        jmp last_non_zero_loop

    ret_last_non_zero:
        movl %ecx, %eax
        popl %ebp
        ret

STANDARD_DEFRAG:
    pushl %ebp
    movl %esp, %ebp

    call LAST_NON_ZERO_ELEMENT
    addl $2, %eax
    movl %eax, %edx
    xor %ecx, %ecx

    loop_standard_defrag:
        cmp %edx, %ecx
        jge ret_standard_defrag

        movl (%edi, %ecx, 4), %eax
        cmp $0, %eax
        je free_space_std_defrag  

        inc %ecx
        jmp loop_standard_defrag

    free_space_std_defrag:
        pushl %edx
        pushl %ecx
        call REMOVE_ELEMENT_ARRAY
        popl %ecx
        popl %edx

        dec %edx

        jmp loop_standard_defrag

    ret_standard_defrag:
        popl %ebp
        ret

/*insert_at_pos(position)*/
INSERT_AT_POS:
    pushl %ebp
    movl %esp, %ebp

    movl matrix_size, %ecx
    movl 8(%ebp), %edx
    insert_at_pos_loop:
        cmp %edx, %ecx
        je insert_at_pos_ret

        dec %ecx
        movl (%edi, %ecx, 4), %eax
        inc %ecx
        movl %eax, (%edi, %ecx, 4)

        dec %ecx
        jmp insert_at_pos_loop

    insert_at_pos_ret:
        movl 8(%ebp), %eax
        movl $0, (%edi, %eax, 4)
        popl %ebp
        ret

/*insert at pos(position, k)*/
INSERT_AT_POS_KTIMES:
    pushl %ebp
    movl %esp, %ebp

    movl 12(%ebp), %ecx

    insert_at_pos_ktimes_loop:
        cmp $0, %ecx
        je ret_insert_at_pos_ktimes

        pushl %ecx
        pushl 8(%ebp)
        call INSERT_AT_POS
        add $4, %esp
        popl %ecx

        dec %ecx
        jmp insert_at_pos_ktimes_loop

    ret_insert_at_pos_ktimes:
        popl %ebp
        ret

ALIGN_FILES_DEFRAG:
    pushl %ebp
    movl %esp, %ebp

    subl $4, %esp

    movl n, %ecx
    movl matrix_size, %edx
    subl n, %edx

    align_files_defrag_loop:
        cmp %edx, %ecx
        je ret_align_files_defrag
        
        movl (%edi, %ecx, 4), %eax
        dec %ecx
        movl (%edi, %ecx, 4), %ebx
        inc %ecx

        cmp %eax, %ebx
        je equal_values

        addl n, %ecx
        jmp align_files_defrag_loop

    equal_values:
        cmp $0, %eax
        je continue_align_files

        movl %eax, -4(%ebp)
        movl %ecx, %ebx
        dec %ebx

        equal_values_loop:
            movl (%edi, %ebx, 4), %eax
            cmp -4(%ebp), %eax
            jne equal_values_seq_end

            dec %ebx
            jmp equal_values_loop

        equal_values_seq_end:
            movl %ecx, %eax
            subl %ebx, %eax
            dec %eax
            inc %ebx

            pusha
            pushl %eax
            pushl %ebx
            call INSERT_AT_POS_KTIMES
            addl $8, %esp
            popa
            
        addl n, %ecx
        jmp align_files_defrag_loop

        
    continue_align_files:
        addl n, %ecx
        jmp align_files_defrag_loop

    ret_align_files_defrag:
        addl $4, %esp
        popl %ebp
        ret

DEFRAG_PROC:
    pushl %ebp
    movl %esp, %ebp

    call STANDARD_DEFRAG
    call ALIGN_FILES_DEFRAG
    call PRINT_MEMORY_INTERVALS

    defrag_proc_ret:
        popl %ebp
        ret

CONCRETE_PROC:
    pushl %ebp
    movl %esp, %ebp
    
    pusha
    pushl $dirname
    pushl $formatStringScanfPath
    call scanf
    addl $8, %esp
    popa

    /*get fd for directory */
    movl $5, %eax
    movl $dirname, %ebx          
    xorl %ecx, %ecx              
    int $0x80                    

    movl %eax, %ebx 

    /*
    pusha
    pushl %ebx
    pushl $formatLong           
    call printf
    addl $8, %esp
    popa*/

    /* get_dir */
    movl $141, %eax
    movl %ebx, %ebx
    movl $buffer, %ecx
    movl $4096, %edx
    int $0x80

    movl %eax, %esi             
    movl $buffer, %edi

    /* print buffer size 
    pusha
    pushl %esi
    pushl $formatLong           
    call printf
    addl $8, %esp
    popa*/
    
    parse_entries:
        cmp $0, %esi
        jbe concrete_proc_ret

        movzwl 8(%edi), %eax

        lea 10(%edi), %ecx
        
        /*skip if filename is .*/
        pushl %eax

        pushl $dotStr               
        pushl %ecx                   
        call strcmp                  
        popl %ecx
        addl $4, %esp                
        
        movl %eax, %ebx
        popl %eax

        cmp $0, %ebx
        je next_file_in_struct

        /* skip if filename is .. */
        pushl %eax

        pushl $dotDotStr               
        pushl %ecx                   
        call strcmp                  
        popl %ecx
        addl $4, %esp                
        
        movl %eax, %ebx
        popl %eax

        cmp $0, %ebx
        je next_file_in_struct

        /*process file*/
        /*print file name
        pushl %eax
        pushl %ecx
        pushl $formatStr        
        call printf
        addl $4, %esp
        popl %ecx
        popl %eax*/

        /*clear concatStr*/
        pushl %eax
        pushl %ecx
        pushl $dirname
        pushl $concatStr
        call strcpy
        addl $8, %esp
        popl %ecx
        popl %eax

        /*strcat with filename*/
        pushl %eax
        pushl %ecx 
        pushl $concatStr
        call strcat
        addl $4, %esp
        popl %ecx
        popl %eax

        /*print absolute file path
        pushl %eax
        pushl %ecx
        pushl $concatStr
        pushl $formatStr        
        call printf
        addl $8, %esp
        popl %ecx
        popl %eax*/

        
        /*get fd*/
        pushl %eax
        pushl %ecx
        movl $5, %eax
        movl $concatStr, %ebx
        xorl %ecx, %ecx
        int $0x80

        movl %eax, %ebx

        popl %ecx
        popl %eax

    
        /*print fd
        pushl %eax
        pushl %ecx
        pushl %ebx
        pushl $formatLong           
        call printf
        addl $8, %esp
        popl %ecx
        popl %eax*/ 

        /*fstat*/
        pushl %eax
        pushl %ecx

        movl $108, %eax
        movl %ebx, %ebx
        leal buffstat, %ecx
        int $0x80

        popl %ecx
        popl %eax

        /*put size in edx*/
        pushl %edi
        movl $buffstat, %edi
        movl 20(%edi), %edx
        popl %edi

        /*print size in bytes
        pushl %eax
        pushl %ecx

        pushl %edx
        pushl $formatLong           
        call printf
        addl $4, %esp
        popl %edx

        popl %ecx
        popl %eax */


        /*transform in kb */
        pushl %eax
        pushl %ecx
        pushl %ebx
        
        movl %edx, %eax
        movl $1024, %ebx
        xorl %edx, %edx
        div %ebx

        movl %eax, %edx

        popl %ebx
        popl %ecx
        popl %eax

        /*print size in kb
        pushl %eax
        pushl %ecx
        pushl %edx
        pushl $formatLong           
        call printf
        addl $8, %esp
        popl %ecx
        popl %eax */

        /*calculate new fd*/
        pushl %eax
        pushl %ecx
        pushl %edx

        movl %ebx, %eax
        movl $255, %ebx
        xorl %edx, %edx
        div %ebx
        movl %edx, %ebx
        inc %ebx

        popl %edx
        popl %ecx
        popl %eax

        /*print new fd
        pushl %eax
        pushl %ecx
        pushl %ebx
        pushl $formatLong           
        call printf
        addl $8, %esp
        popl %ecx
        popl %eax*/

        pushl %eax
        pushl %ecx

        pushl %ebx
        pushl %edx
        pushl $concatStr
        pushl $formatConcreteFile
        call printf
        add $8, %esp
        popl %edx
        popl %ebx

        popl %ecx
        popl %eax

        /*transform in blocks */
        pushl %eax
        pushl %ecx
        pushl %ebx
        
        movl %edx, %eax
        movl $8, %ebx
        xorl %edx, %edx
        div %ebx

        movl %eax, %edx

        popl %ebx
        popl %ecx
        popl %eax

        /*print size in blocks
        pushl %eax
        pushl %ecx
        pushl %ebx
        pushl %edx
        pushl $formatLong           
        call printf
        addl $4, %esp
        popl %edx
        popl %ebx
        popl %ecx
        popl %eax */

        /*add file*/
        pushl %eax
        pushl %ecx

        pushl %edx
        pushl %ebx
        call ADD_FILE
        popl %ebx
        popl %edx

        popl %ecx
        popl %eax

        jmp next_file_in_struct


    next_file_in_struct:
        subl %eax, %esi
        addl %eax, %edi
        
        jmp parse_entries


    concrete_proc_ret:
        call PRINT_MEMORY_INTERVALS
        popl %ebp
        ret


.global main
main:
    lea matrix, %edi

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

        cmp $5, op
        je case_concrete_proc

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

    case_concrete_proc:
        pushl %ecx
        call CONCRETE_PROC
        popl %ecx
        inc %ecx
        jmp loop_operations

exit:
    pushl $0
    call fflush
    add $4, %esp

    movl $1, %eax
    xor %ebx, %ebx
    int $0x80