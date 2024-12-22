;--------------------------------------------------------------------------
; Файл: mylib.asm
;--------------------------------------------------------------------------
; Сборка (под Linux x86_64):
;   nasm -f elf64 mylib.asm -o mylib.o
;   ld -shared mylib.o -o libmylib.so
;
; Экспортируемые функции (через System V AMD64 ABI):
;   1) return_42() -> int
;   2) create_file(const char* filename) -> void
;   3) write_file(const char* filename, const char* data, size_t length) -> void
;   4) read_file(const char* filename) -> const char*
;
; Для краткости не обрабатываем ошибки и не занимаемся
; динамическим выделением памяти.
;--------------------------------------------------------------------------

%define SYS_READ    0    ; sys_read
%define SYS_WRITE   1    ; sys_write
%define SYS_OPEN    2    ; sys_open
%define SYS_CLOSE   3    ; sys_close

; Флаги для open()
%define O_RDONLY    0    ; 0x0000
%define O_WRONLY    1    ; 0x0001
%define O_CREAT     64   ; 0x0040
%define O_TRUNC     512  ; 0x0200

; Режимы доступа (для creat/open):
; 0o644 = -rw-r--r--
; В десятичной: 420
; Но используем сразу восьмеричное представление
%define MODE_0644 0o644

section .bss
; Буфер на 4096 байт, куда будем читать файл:
read_buffer: resb 4096

section .text
default rel
global return_42
global create_file
global write_file
global read_file

;--------------------------------------------------------------------------
; int return_42()
;--------------------------------------------------------------------------
return_42:
    mov     eax, 42
    ret

;--------------------------------------------------------------------------
; void create_file(const char* filename)
;   rdi -> filename (C-строка)
;--------------------------------------------------------------------------
create_file:
    push    rbp
    mov     rbp, rsp

    ; open(filename, O_WRONLY|O_CREAT|O_TRUNC, 0644)
    mov     rax, SYS_OPEN
    ; rdi уже содержит filename
    mov     rsi, O_WRONLY + O_CREAT + O_TRUNC  ; = 1 + 64 + 512 = 577
    mov     rdx, MODE_0644
    syscall

    ; fd < 0 => ошибка, но в демо-коде не обрабатываем.
    ; Закрыть файл (если fd >= 0).
    cmp     rax, 0
    jl      .done
    mov     r8, rax

    mov     rax, SYS_CLOSE
    mov     rdi, r8
    syscall

.done:
    leave
    ret

;--------------------------------------------------------------------------
; void write_file(const char* filename, const char* data, size_t length)
;   rdi -> filename
;   rsi -> data
;   rdx -> length
;--------------------------------------------------------------------------
write_file:
    push    rbp
    mov     rbp, rsp

    ; Сохраним аргументы в локальные переменные (при желании)
    mov     [rbp - 8], rdi   ; filename
    mov     [rbp - 16], rsi  ; data
    mov     [rbp - 24], rdx  ; length

    ; open(filename, O_WRONLY|O_CREAT|O_TRUNC, 0644)
    mov     rax, SYS_OPEN
    mov     rdi, [rbp - 8]   ; filename
    mov     rsi, O_WRONLY + O_CREAT + O_TRUNC  ; 577
    mov     rdx, MODE_0644
    syscall

    cmp     rax, 0
    jl      .done
    mov     r8, rax          ; fd

    ; write(fd, data, length)
    mov     rax, SYS_WRITE
    mov     rdi, r8
    mov     rsi, [rbp - 16]  ; data
    mov     rdx, [rbp - 24]  ; length
    syscall

    ; close(fd)
    mov     rax, SYS_CLOSE
    mov     rdi, r8
    syscall

.done:
    leave
    ret

;--------------------------------------------------------------------------
; const char* read_file(const char* filename)
;   rdi -> filename
;
; Возвращаем указатель на статический буфер read_buffer,
; в который считали содержимое файла (макс. 4096 байт).
;--------------------------------------------------------------------------
read_file:
    push    rbp
    mov     rbp, rsp

    ; open(filename, O_RDONLY)
    mov     rax, SYS_OPEN
    ; rdi уже содержит filename
    mov     rsi, O_RDONLY
    mov     rdx, 0
    syscall

    cmp     rax, 0
    jl      .error
    mov     r8, rax  ; fd

    ; read(fd, read_buffer, 4096)
    mov     rax, SYS_READ
    mov     rdi, r8
    lea     rsi, [rel read_buffer]   ; rsi <- адрес read_buffer
    mov     rdx, 4096
    syscall

    ; rax = кол-во прочитанных байт
    ; Допишем ноль-терминатор в read_buffer[rax]
    mov     r9, rax
    lea     rbx, [rel read_buffer]    ; rbx = адрес начала буфера
    add     rbx, r9                   ; rbx = rbx + r9
    mov     byte [rbx], 0             ; записываем 0 по адресу (read_buffer + rax)

    ; close(fd)
    mov     rax, SYS_CLOSE
    mov     rdi, r8
    syscall

    ; Возвращаем адрес read_buffer в rax
    lea     rax, [rel read_buffer]
    jmp     .done

.error:
    ; Если ошибка, вернём NULL (0)
    xor     rax, rax

.done:
    leave
    ret

