.global openFile
.global closeFile
.global readCSV
.global atoi
.global itoa
.global bubbleSort
.global convert_array_to_ascii
.global _start

.data

encabezado:
    .asciz "Universidad de San Carlos de Guatemala\nFacultad de Ingeniería\nEscuela de Ciencias y Sistemas\nArquitectura de Computadores y Ensambladores 1\nSección A\nIrving Fernando Alvarado Asensio\n202200349\n\nPreisone Enter para continuar..."
    lenEncabezado = .- encabezado

menuPrincipal:
    .asciz "\n\nMenu Principal\n1. Ingreso lista de numeros\n2. Ordenamiento de burbuja\n3. Quick Sort\n4. Insertion Sort\n5. Merge Sort\n6. Salir\n\nIngrese una opcion: "
    lenMenuPrincipal = .- menuPrincipal

tipoIngreso:
    .asciz "\n\nTipo de Ingreso\n1. Ingreso por teclado\n2. Ingreso por archivo CSV\n\nIngrese una opcion: "
    lenTipoIngreso = .- tipoIngreso

tipoOrdenamiento:
    .asciz "\n\nTipo de Ordenamiento\n1. Ordenamiento Ascendente\n2. Ordenamiento Descendente\n\nIngrese una opcion: "
    lenTipoOrdenamiento = .- tipoOrdenamiento

mensajeOriginal:
    .asciz "Arreglo Original: "
    lenMensajeOriginal = .- mensajeOriginal

salto:
    .asciz "\n"
    lenSalto = .- salto

espacio:
    .asciz " "
    lenEspacio = .- espacio

clear_screen:
    .asciz "\x1B[2J\x1B[H"
    lenClear = .- clear_screen

msgFilename:
    .asciz "Ingrese el nombre del archivo: "
    lenMsgFilename = .- msgFilename

errorOpenFile:
    .asciz "Error al abrir el archivo\n"
    lenErrOpenFile = .- errorOpenFile

readSuccess:
    .asciz "El Archivo Se Ha Leido Correctamente\n"
    lenReadSuccess = .- readSuccess

entradaManual:
    .asciz "Ingrese los numeros separados por comas: "
    lenEntradaManual = .- entradaManual

archivoCSV:
    .asciz "archivo.csv"
    lenArchivoCSV = .- archivoCSV

reporteNombre:
    .asciz "reporte.txt"
    lenReporteNombre = .- reporteNombre

mensajePaso:
    .asciz "Paso "
    lenMensajePaso = .- mensajePaso

dosPuntos:
    .asciz ": "
    lenDosPuntos = .- dosPuntos

arregloOrdenado:
    .asciz "Arreglo Ordenado: "
    lenArregloOrdenado = .- arregloOrdenado

ordenBurbuja:
    .asciz "Ordenamiento de Burbuja  \n"
    lenOrdenBurbuja = .- ordenBurbuja

noImplementado:
    .asciz "Opción no implementada\n"
    lenNoImplementado = .- noImplementado

ordenAscendente:
    .asciz "Orden Ascendente\n"
    lenOrdenAscendente = .- ordenAscendente

ordenDescendente:
    .asciz "Orden Descendente\n"
    lenOrdenDescendente = .- ordenDescendente

ordenInsertion:
    .asciz "Ordenamiento de Insercion\n"
    lenOrdenInsertion = .- ordenInsertion

titulo:
    .space 50
    lenTitulo = .- titulo                                         


.bss
opcion:
    .space 2

filename:
    .zero 50

count:
    .zero 8

cadena:
    .space 50

num:
    .space 4

buffer:
    .space 512

character:
    .byte 0

fileDescriptor:
    .space 8


array:
    .space 512

arrayCopia:
    .space 512

length:
    .space 4

.text

// Macro para imprimir strings
.macro print reg, len
    MOV x0, 1
    LDR x1, =\reg
    MOV x2, \len
    MOV x8, 64
    SVC 0
.endm

// Macro para leer datos del usuario
.macro read stdin, buffer, len
    MOV x0, \stdin
    LDR x1, =\buffer
    MOV x2, \len
    MOV x8, 63
    SVC 0
.endm

array_copia_to_ascii:
    STP x29, x30, [SP, -16]!     // Guardar FP y LR
    MOV x29, SP
    STP x7, x15, [SP, -16]!      // Guardar registros adicionales

    LDR x9, =count
    LDR x9, [x9]                 // length => cantidad de números leídos del CSV
    MOV x7, 0
    LDR x15, =arrayCopia         // Dirección del array copia

    loop_array_to_ascii:
        LDRH w0, [x15], 2            // Carga un número del array
        LDR x1, =num                 // Dirección del buffer para almacenar el ASCII
        STP x29, x30, [SP, -16]!     // Guardar FP y LR
        BL itoa                      // Convierte el número a ASCII
        LDP x29, x30, [SP], 16       // Restaurar FP y LR

        // Escribir en el buffer
        LDR x0, =num
        LDRB w0, [x0]
        STRB w0, [x1, x7]            // Almacenar el byte convertido en el buffer

        ADD x7, x7, 1
        CMP x9, x7                   // Compara si hemos procesado todos los números
        BNE loop_array_to_ascii      // Si no, vuelve al loop

        LDP x7, x15, [SP], 16        // Restaurar registros adicionales
        LDP x29, x30, [SP], 16       // Restaurar FP y LR
        RET




escribirReporte:
    // Abrir el archivo para escribir (O_WRONLY | O_CREAT | O_APPEND)
    MOV x0, -100      // sys_open
    LDR x1, =reporteNombre
    MOV x2, 1089      // O_WRONLY | O_CREAT | O_APPEND => 101 | 64 (octal) = 1089 (decimal)
    MOV x3, 0644      // Mode
    MOV x8, 56        // sys_open
    SVC 0

    // Guardar el file descriptor en x9
    MOV x9, x0
    
    // Escribir el encabezado
    MOV x0, x9
    LDR x1, =encabezado
    MOV x2, 196        // Longitud del encabezado
    MOV x8, 64         // sys_write
    SVC 0
    
    // Escribir el título del ordenamiento
    MOV x0, x9
    LDR x1, =titulo
    MOV x2, 26        // Longitud del título
    MOV x8, 64        // sys_write
    SVC 0

    // Cerrar el archivo
    MOV x0, x9
    MOV x8, 57
    SVC 0


    RET


copiarArray:
    LDR x0, =array       // Dirección del arreglo original
    LDR x1, =arrayCopia  // Dirección del arreglo de copia
    LDR x2, =count
    LDR x2, [x2]         // Número de elementos en el arreglo

    MOV x3, 0            // Índice

copiar_loop:
    LDRH w4, [x0, x3, LSL 1]
    STRH w4, [x1, x3, LSL 1]
    ADD x3, x3, 1
    CMP x3, x2
    BNE copiar_loop

    RET




openFile:
    // param: x1 -> filename
    MOV x0, -100
    MOV x2, 0
    MOV x8, 56
    SVC 0

    CMP x0, 0
    BLE op_f_error
    LDR x9, =fileDescriptor
    STR x0, [x9]
    B op_f_end

    op_f_error:
        print errorOpenFile, lenErrOpenFile
        read 0, opcion, 1

    op_f_end:
        RET

closeFile:
    LDR x0, =fileDescriptor
    LDR x0, [x0]
    MOV x8, 57
    SVC 0
    RET

readCSV:
    // code para leer numero y convertir
    LDR x10, =num    // Buffer para almacenar el numero
    LDR x11, =fileDescriptor
    LDR x11, [x11]

    rd_num:
        read x11, character, 1
        LDR x4, =character
        LDRB w3, [x4]
        CMP w3, 44
        BEQ rd_cv_num

        MOV x20, x0
        CBZ x0, rd_cv_num

        STRB w3, [x10], 1
        B rd_num

    rd_cv_num:
        LDR x5, =num
        LDR x8, =num
        LDR x12, =array

        STP x29, x30, [SP, -16]!

        BL atoi

        LDP x29, x30, [SP], 16

        LDR x12, =num
        MOV w13, 0
        MOV x14, 0

        cls_num:
            STRB w13, [x12], 1
            ADD x14, x14, 1
            CMP x14, 3
            BNE cls_num
            LDR x10, =num
            CBNZ x20, rd_num

    rd_end:
        print salto, lenSalto
        print readSuccess, lenReadSuccess
        RET

atoi:
    // params: x5, x8 => buffer address, x12 => result address
    SUB x5, x5, 1
    a_c_digits:
        LDRB w7, [x8], 1
        CBZ w7, a_c_convert
        CMP w7, 10
        BEQ a_c_convert
        B a_c_digits

    a_c_convert:
        SUB x8, x8, 2
        MOV x4, 1
        MOV x9, 0

        a_c_loop:
            LDRB w7, [x8], -1
            CMP w7, 45
            BEQ a_c_negative

            SUB w7, w7, 48
            MUL w7, w7, w4
            ADD w9, w9, w7

            MOV w6, 10
            MUL w4, w4, w6

            CMP x8, x5
            BNE a_c_loop
            B a_c_end

        a_c_negative:
            NEG w9, w9

        a_c_end:
            LDR x13, =count
            LDR x13, [x13] // saltos
            MOV x14, 2
            MUL x14, x13, x14

            STRH w9, [x12, x14] // usando 16 bits

            ADD x13, x13, 1
            LDR x12, =count
            STR x13, [x12]

            RET

calcular_longitud:
    LDR x1, =cadena
    MOV x2, 0      // Inicializa el contador

contar_loop:
    LDRB w3, [x1, x2]
    CMP w3, 0      // Verifica el fin de la cadena
    BEQ fin_contar
    ADD x2, x2, 1
    B contar_loop

fin_contar:
    LDR x4, =length
    STR x2, [x4]
    RET


itoa:
    // Prologo: Guardar los registros que vamos a usar y que necesitan ser preservados
    STP x29, x30, [SP, -16]!     // Guardar Frame Pointer y Link Register
    STP x19, x20, [SP, -16]!     // Guardar registros x19 y x20 (si se utilizan)

    // Establecer el Frame Pointer
    MOV x29, SP

    // params: x0 => number, x1 => buffer address
    MOV x10, 0          // contador de digitos a imprimir
    MOV x12, 0          // flag para indicar si hay signo menos
    MOV w2, 10000       // Base 10
    CMP w0, 0           // Numero a convertir
    BGT i_convertirAscii
    CBZ w0, i_zero

    B i_negative

    i_zero:
        ADD x10, x10, 1
        MOV w5, 48
        STRB w5, [x1], 1
        B i_endConversion

    i_negative:
        MOV x12, 1
        MOV w5, 45
        STRB w5, [x1], 1
        NEG w0, w0

    i_convertirAscii:
        CBZ w2, i_endConversion
        UDIV w3, w0, w2
        CBZ w3, i_reduceBase

        MOV w5, w3
        ADD w5, w5, 48
        STRB w5, [x1], 1
        ADD x10, x10, 1

        MUL w3, w3, w2
        SUB w0, w0, w3

        CMP w2, 1
        BLE i_endConversion

    i_reduceBase:
        MOV w6, 10
        UDIV w2, w2, w6

        CBNZ w10, i_addZero
        B i_convertirAscii

    i_addZero:
        CBNZ w3, i_convertirAscii
        ADD x10, x10, 1
        MOV w5, 48
        STRB w5, [x1], 1
        B i_convertirAscii

    i_endConversion:
    ADD x10, x10, x12
    print num, x10  // Asume que 'print' es una subrutina válida

    // Epílogo: Restaurar los registros desde la pila
    LDP x19, x20, [SP], 16       // Restaurar registros x19 y x20
    LDP x29, x30, [SP], 16       // Restaurar Frame Pointer y Link Register
    RET                           // Retorna al llamador
    
 convert_array_to_ascii:          
    STP x29, x30, [SP, -16]!     
    STP x7, x15, [SP, -16]!      

    LDR x11, =count
    LDR x11, [x11]                 
    MOV x7, 0
    LDR x15, =array        

    loop_array:
        LDRH w0, [x15], 2            
        LDR x1, =num                 
        STP x29, x30, [SP, -16]!     
        BL itoa                      
        LDP x29, x30, [SP], 16       

        print espacio, lenEspacio     

        ADD x7, x7, 1
        CMP x11, x7                   
        BNE loop_array               

        print salto, lenSalto         

        LDP x7, x15, [SP], 16        
        LDP x29, x30, [SP], 16       
        RET                          

copiarCadena:
    //X1 direccion destino X2 direccion origen
    LDRB w3, [x2], #1                           // Cargar un byte de ordenBurbuja en w3
    STRB w3, [x1], #1                           // Almacenar el byte en titulo
    CMP w3, #0                                  // Comprobar si es el fin de la cadena (null terminator)
    BNE copiarCadena

    RET   


bubbleSort:
    SUB SP, SP, #16        // Ajustar el stack para guardar LR
    STR LR, [SP, #0]
    BL copiarArray
    print mensajeOriginal, lenMensajeOriginal
    BL convert_array_to_ascii
    MOV x20, 0
    LDR x17, =count
    LDR x17, [x17]           // length => cantidad de números leídos del CSV

    MOV x21, 0              // índice i - algoritmo de burbuja
    SUB x17, x17, 1          // length - 1

    bs_loop1:
        MOV x9, 0          // índice j - algoritmo de burbuja
        SUB x22, x17, x21  // length - 1 - i

    bs_loop2:
        LDR x26, =array
        LDRH w24, [x26, x9, LSL 1] // array[j]
        ADD x9, x9, 1
        LDRH w18, [x26, x9, LSL 1] // array[j + 1]

        //Comparamos con un caracter 1, no el numero sino el caracter entre comillas simples
        CMP w16, '1'
        BEQ bs_ascendente
        CMP w16, '2'
        BEQ bs_descendente

    bs_ascendente:
        CMP w24, w18
        BLT bs_cont_loop2  // Para orden ascendente
        STRH w24, [x26, x9, LSL 1]
        SUB x9, x9, 1
        STRH w18, [x26, x9, LSL 1]
        ADD x9, x9, 1
        B bs_cont_loop2

    bs_descendente:
        CMP w24, w18
        BGT bs_cont_loop2  // Para orden descendente
        STRH w24, [x26, x9, LSL 1]
        SUB x9, x9, 1
        STRH w18, [x26, x9, LSL 1]
        ADD x9, x9, 1
        B bs_cont_loop2
        

    bs_cont_loop2:
        CMP x9, x22
        BNE bs_loop2
        print mensajePaso, lenMensajePaso
        ADD x20, x20, 1
        LDR x1, =num
        MOV x0, x20
        BL itoa
        // Imprimir el paso actual
        print dosPuntos, lenDosPuntos

        BL convert_array_to_ascii

        ADD x21, x21, 1
        CMP x21, x17
        BNE bs_loop1

    // recorrer array y convertir a ascii al final de la ordenación completa
    print arregloOrdenado, lenArregloOrdenado
    BL convert_array_to_ascii

    //ALmacenamos en titulo "ordenamiiento de burbuja"
    LDR x1, =titulo
    LDR x2, =ordenBurbuja
    BL copiarCadena

    BL escribirReporte

    LDR LR, [SP, #0]       // Restaurar LR
    ADD SP, SP, #16        // Ajustar el stack de vuelta

    B menu





end:
    MOV x0, 0
    MOV x8, 93
    SVC 0

clear_array:
    LDR x12, =array   // Cargar la dirección del array en x12
    MOV x9, 256       // Cantidad de elementos en el array

    MOV x10, 0        // Inicializar el índice

clear_loop2:
    STRH wzr, [x12, x10, LSL 1]   // Establecer el valor a 0
    ADD x10, x10, 1
    CMP x10, x9
    BNE clear_loop2

    RET


metodoCSV:
    SUB SP, SP, #16        // Ajustar el stack para guardar LR
    STR LR, [SP, #0]  
    BL clear_array

    // Resetear count a 0
    MOV x10, 0
    LDR x11, =count
    STR x10, [x11]

    // Guardar LR en la pila

    // Mensaje para ingresar el nombre del archivo
    print msgFilename, lenMsgFilename
    read 0, filename, 50
    
    // Agregar carácter nulo al final del nombre del archivo
     LDR x0, =filename
     loop:
         LDRB w1, [x0], 1
         CMP w1, 10
         BEQ endLoop
         B loop

         endLoop:
             MOV w1, 0
             STRB w1, [x0, -1]!

    // función para abrir el archivo
    LDR x1, =filename
    BL openFile 
    
    // procedimiento para leer los números del archivo
    BL readCSV

    // función para cerrar el archivo
    BL closeFile 

    // Restaurar LR desde la pila
    LDR LR, [SP, #0]       // Restaurar LR
    ADD SP, SP, #16        // Ajustar el stack de vuelta

    B menu


clear_input_buffer:
    MOV x0, 0          // File descriptor: stdin (0)
    MOV x1, sp         // Address to store character
    MOV x2, 1          // Number of bytes to read
    MOV x8, 63         // Syscall number for read
clear_loop:
    SVC 0              // Call kernel
    CMP x0, 1          // If no more characters to read, return
    BEQ clear_exit
    B clear_loop       // Keep reading
clear_exit:
    RET

escribirCSV:
    //stack frame
    SUB SP, SP, #16        // Ajustar el stack para guardar LR
    STR LR, [SP, #0] 

    // Abrir el archivo para escribir
    MOV x0, -100      // sys_open
    LDR x1, =archivoCSV
    MOV x2, 101       // O_WRONLY | O_CREAT
    MOV x3, 0777      // Mode
    MOV x8, 56        // sys_open
    SVC 0

    MOV x9, x0        // Guardar file descriptor en x9
    
    // Calcular la longitud de la cadena ingresada
    BL calcular_longitud
    LDR x4, =length
    LDR x2, [x4]      // Longitud calculada

    // Escribir los números en el archivo
    MOV x0, x9
    LDR x1, =cadena
    MOV x8, 64        // sys_write
    SVC 0

    // Cerrar el archivo
    MOV x0, x9
    MOV x8, 57
    SVC 0

    LDR LR, [SP, #0]       // Restaurar LR
    ADD SP, SP, #16  

    RET


metodoTeclado:
    // Pedir la entrada del usuario
    print entradaManual, lenEntradaManual
    read 0, cadena, 50
    BL clear_input_buffer

    // Escribir la entrada del usuario en un archivo CSV
    BL escribirCSV

    // Resetear count a 0
    MOV x10, 0
    LDR x11, =count
    STR x10, [x11]

    // Guardar LR en la pila
    SUB SP, SP, #16        // Ajustar el stack para guardar LR
    STR LR, [SP, #0]       // Guardar LR

    // Usar el nombre fijo del archivo CSV
    LDR x1, =archivoCSV
    BL openFile 
    
    // Procedimiento para leer los números del archivo
    BL readCSV

    // Función para cerrar el archivo
    BL closeFile 

    // Restaurar LR desde la pila
    LDR LR, [SP, #0]       // Restaurar LR
    ADD SP, SP, #16        // Ajustar el stack de vuelta

    B menu

insertionSort:
    STP x29, x30, [SP, -16]!    // Guardar FP y LR
    MOV x29, SP
    STP x19, x20, [SP, -16]!    // Guardar registros adicionales

    LDR x17, =count
    LDR x17, [x17]              // length => cantidad de números leídos del CSV

    MOV x21, 1                  // i = 1

insertion_outer_loop:
    CMP x21, x17
    BGE insertion_done

    LDR x9, =array
    ADD x22, x9, x21, LSL 1
    LDRH w26, [x22]             // key = array[i]

    MOV x24, x21                // j = i

insertion_inner_loop:
    SUB x24, x24, 1
    CMP x24, 0
    BLT insertion_inner_done

    ADD x18, x9, x24, LSL 1
    LDRH w4, [x18]

    CMP w16, '1'
    BEQ insertion_ascendente
    CMP w16, '2'
    BEQ insertion_descendente
    print noImplementado, lenNoImplementado

insertion_ascendente:
    CMP w4, w26
    BLE insertion_inner_done   // Para orden ascendente
    B insertion_swap

insertion_descendente:
    CMP w4, w26
    BGE insertion_inner_done   // Para orden descendente

insertion_swap:
    ADD x8, x18, 2
    STRH w4, [x8]               // array[j+1] = array[j]
    B insertion_inner_loop

insertion_inner_done:
    ADD x24, x24, 1
    ADD x8, x9, x24, LSL 1
    STRH w26, [x8]              // array[j+1] = key

    // Incrementar i
    ADD x21, x21, 1

    // Imprimir el estado del arreglo después de cada paso
    print mensajePaso, lenMensajePaso
    LDR x1, =num
    MOV x0, x21
    SUB x0, x0, 1
    BL itoa
    // Imprimir el paso actual
    print dosPuntos, lenDosPuntos
    BL convert_array_to_ascii

    B insertion_outer_loop

insertion_done:
    //Agregamos el titulo al reporte
    LDR x1, =titulo
    LDR x2, =ordenInsertion
    BL copiarCadena

    //Escribimos el reporte
    BL escribirReporte

    LDP x19, x20, [SP], 16      // Restaurar registros adicionales
    LDP x29, x30, [SP], 16      // Restaurar FP y LR
    RET



// Etiqueta de inicio del programa
_start:
    // Limpiar salida de la terminal
    print clear_screen, lenClear

    // Imprimir encabezado
    print encabezado, lenEncabezado

    // Esperamos el enter
    read 0, opcion, 1
    BL clear_input_buffer

    // Entramos al bucle infinito del menú
    menu:
        print menuPrincipal, lenMenuPrincipal

        // Leemos la opción
        read 0, opcion, 1
        BL clear_input_buffer

        // Cargar la dirección de opcion en x1
        LDR x1, =opcion
        LDRB w0, [x1] // Cargar el valor de opcion en w0

        // Verificamos la opción
        CMP w0, '1' // Ingreso lista de números, mostramos el menú de ingreso
        BEQ seleccion_ingreso
        CMP w0, '2' // Ordenamiento de burbuja
        BEQ tipoOrdenamientoBubble
        CMP w0, '3' // Quick Sort
        BEQ noImplementadoOPC
        CMP w0, '4' // Insertion Sort
        BEQ metodoInsertionSort
        CMP w0, '5' // Merge Sort
        BEQ noImplementadoOPC
        CMP w0, '6' // End
        BEQ end
        B menu

    
    metodoInsertionSort:
        // Imprimir el estado inicial del array
        print tipoOrdenamiento, lenTipoOrdenamiento
        read 0, opcion, 1
        BL clear_input_buffer

        LDR x1, =opcion
        LDRB w0, [x1]

        //Movemos a w16 el valor de w0
        mov w16, w0

        BL copiarArray
        print mensajeOriginal, lenMensajeOriginal
        BL convert_array_to_ascii

        // Llamar a insertionSort
        BL insertionSort

        // Imprimir el estado final del array
        print arregloOrdenado, lenArregloOrdenado
        BL convert_array_to_ascii

        B menu

    noImplementadoOPC:
        print noImplementado, lenNoImplementado
        B menu
    

    seleccion_ingreso:
        print tipoIngreso, lenTipoIngreso

        // Consumimos el enter
        read 0, opcion, 1
        BL clear_input_buffer

        // Cargar la dirección de opcion en x1
        LDR x1, =opcion
        LDRB w0, [x1] // Cargar el valor de opcion en w0

        // 1 Ingreso por teclado, 2 Ingreso por archivo CSV
        CMP w0, '1'
        BEQ metodoTeclado
        CMP w0, '2'
        BEQ metodoCSV
        B seleccion_ingreso

    tipoOrdenamientoBubble:
        print tipoOrdenamiento, lenTipoOrdenamiento
        read 0, opcion, 1
        BL clear_input_buffer

        // Cargar la dirección de opcion en x1
        LDR x1, =opcion
        LDRB w0, [x1] // Cargar el valor de opcion en w0


        // 1 Ordenamiento Ascendente, 2 Ordenamiento Descendente
        CMP w0, '1'
        BEQ bubbleSortASC
        CMP w0, '2'
        BEQ bubbleSortDESC
        B tipoOrdenamientoBubble
    
    bubbleSortASC:
        mov w16, w0
        B bubbleSort

    bubbleSortDESC:
        mov w16, w0
        B bubbleSort