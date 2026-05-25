section .bss
    ; --- Reserve 60 bytes for saving the previous termios state and the modified one
    termios_orig    resb 60
    termios_raw     resb 60

section .text
global _start

_start:
    call raw_mode_enter
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

    ; --- Unset ICANON and ECHO flags
    ; https://www.man7.org/linux/man-pages/man3/termios.3.html
    and dword [termios_raw + 12], ~0x0A

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
    ; --- Set exit code 0 (by XORing) and call exit syscall
    mov rax, 60
    xor rdi, rdi
    syscall
