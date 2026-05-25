section .bss
    ; --- Reserve 60 bytes for saving the previous termios state and the modified one
    termios_orig    resb 60
    termios_raw     resb 60

    ; --- One byte buffer for inputs
    input_buf       resb 1

section .text
global _start

_start:
    call raw_mode_enter
    call loop
    call raw_mode_exit
    call exit

raw_mode_enter:
    ; --- First read the current termios state using ioctl (syscall 16)
    ; https://www.man7.org/linux/man-pages/man2/ioctl.2.html
    mov rax, 16
    mov rdi, 0
    mov rsi, 0x5401
    lea rdx, [termios_orig]
    syscall

    ; --- Copy from origin to the buffer for the modified state
    lea rsi, [termios_orig]
    lea rdi, [termios_raw]
    mov rcx, 60
    rep movsb

    ; --- Disable ISIG, ICANON and ECHO in c_lflag and IXOFF in c_iflag
    ; https://www.man7.org/linux/man-pages/man3/termios.3.html
    and dword [termios_raw + 12], ~0x0B
    and dword [termios_raw + 0], ~0x400

    ; --- Set the modified state by calling ioctl again
    mov rax, 16
    mov rdi, 0
    mov rsi, 0x5402
    lea rdx, [termios_raw]
    syscall

    ret

raw_mode_exit:
    ; --- Load the saved initial termios state again
    mov rax, 16
    mov rdi, 0
    mov rsi, 0x5402
    lea rdx, [termios_orig]
    syscall

    ret

exit:
    ; --- Set exit code 0 (by XORing) and call exit (syscall 60)
    mov rax, 60
    xor rdi, rdi
    syscall

loop:
    ; --- Read one byte from stdin (syscall 0)
    ; https://www.man7.org/linux/man-pages/man2/read.2.html
    mov rax, 0
    mov rdi, 0
    mov rsi, input_buf
    mov rdx, 1
    syscall

    ; --- Check for Ctrl + Q (0x11 ascii) for exit
    mov al, [input_buf]
    cmp al, 0x11
    je .exit

    ; --- Print everything else for now (syscall 1 -> write)
    mov rax, 1
    mov rdi, 1
    mov rsi, input_buf
    mov rdx, 1
    syscall

    jmp loop 

    .exit:
        ret
