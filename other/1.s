.data
    dir_path:      .asciz "/home/petru/text-files"                    # Directory path (current directory)
    buffer:        .space 1024                   # Buffer for directory entries
    formatPrintf:  .asciz "%s\n"                 # Format string for printf

.text

.global main
main:
    # Open the directory (syscall: open)
    movl $5, %eax                                # Syscall number for open
    leal dir_path, %ebx                          # Pointer to the directory path
    movl $0, %ecx                                # O_RDONLY (read-only)
    int $0x80                                    # Perform the syscall
    cmpl $0, %eax                                # Check if open succeeded
    jl error                                     # Jump to error if open failed
    movl %eax, %ebx                              # Store the directory file descriptor in %ebx

    # Perform the getdents syscall
    movl $141, %eax                              # Syscall number for getdents
    leal buffer, %ecx                            # Pointer to buffer
    movl $1024, %edx                             # Size of buffer
    int $0x80                                    # Perform the syscall
    cmpl $0, %eax                                # Check if getdents succeeded
    jle error                                    # Jump to error if getdents failed or no entries
    movl %eax, %edi                              # %edi = number of bytes read
    leal buffer, %esi                            # %esi = start of buffer
print_entries:
    # Check if we've processed all directory entries or exceeded buffer length
    cmp %esi, buffer+1024                        # If %esi >= buffer + 1024, done
    jge done                                     # If we're done, exit the loop

    # Load the directory entry length d_reclen at offset 4 in the current entry
    movw 4(%esi), %cx                            # Load d_reclen (2 bytes at offset 4)
    addl $8, %esi                                 # Skip d_ino (4 bytes) and d_off (4 bytes)
    movl %esi, %edx                              # Now %edx points to d_name (filename)
    call print_filename                          # Print the filename
    addl %ecx, %esi                              # Advance the pointer by d_reclen
    jmp print_entries                            # Process the next entry

done:
    # Close the directory (syscall: close)
    movl $6, %eax                                # Syscall number for close
    movl %ebx, %ebx                              # File descriptor to close
    int $0x80                                    # Perform the syscall

    # Exit program
    movl $1, %eax                                # Syscall number for exit
    xorl %ebx, %ebx                              # Exit code 0
    int $0x80                                    # Perform the syscall

print_filename:
    pushl %edx                                   # Push d_name address onto the stack
    pushl $formatPrintf                          # Push the format string onto the stack
    call printf                                  # Call printf
    addl $8, %esp                                # Clean up the stack (2 arguments)
    ret                                          # Return to caller

error:
    movl $1, %eax                                # Syscall number for exit
    movl $1, %ebx                                # Exit code 1
    int $0x80                                    # Perform the syscall
