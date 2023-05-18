;DUDAS DE MOMENTO:
;->Rotacion
;Como depurar o ejecutar con llamadas al sistema

GLOBAL main


section .data
    archVictima DD "archivoV.txt", 0
    tama_buffer EQU 50
    key DD 3


section .bss
    fd resw 1
    buffer resb tama_buffer


section .text 


    main:

        ;Inicialmente abrimos el archivo
        mov eax, 5;sys_open
        mov ebx, archVictima
        mov ecx, 2
        mov edx, 777
        int 0x80

        ;Revisando si se pudo abrir el archivo
        cmp eax, -1
        jl error_open

        error_open:
            jmp ext




        mov [fd], eax   ;Guardar identificador de archivo
        ;Leer el contenido del archivo
        mov eax, 3
        mov ebx, [fd]
        mov ecx, buffer
        mov edx, tama_buffer
        int 0x80        ;Leemos contenido del archivo


        ;Cifrar contenido
    cifrar_loop:
        mov eax, 3
        mov ebx, [fd]
        mov ecx, buffer
        mov edx, 1
        int 0x80        ;Leemos contenido del archivo

        cmp eax, 0
        je fin_cifrar


        ;Rotacion del caracter
        ;Falta

        movzx ebx, byte[buffer]
        add ebx, key;rotacion 3 veces de momento
        movzx eax, byte[buffer]
        ror eax, ebx;->al, bl PREGUNTAR

        mov eax,4
        mov ebx, eax
        mov ecx, buffer
        mov edx, 1
        int 0x80

        jmp cifrar_loop




        mov eax, 1  ;Fin del programa
        int 0x80


    print:
        mov eax, 4              ;Identificador de la llamada al sistema ESCRITURA
        mov ebx, 1              ;Descriptor de archivo para la salida estándar
        mov ecx, buffer         ;Apuntador al mensaje (dirección de memoria)
        mov edx, tama_buffer   ;Tamaño del mensaje
        int 0x80                ;Llamada al sistema
        ret


    ;Cerrar el archivo
    mov eax, 6
    mov ebx, [fd]
    int 0x80


    fin_cifrar:



ext:
    mov eax, 1
    int 0x80