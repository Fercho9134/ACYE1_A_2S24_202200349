.global int_to_Ascii
.global Ascii_to_int
.global Verificar_save_filname
.global import_datos
.global LeerCSV
.global Abrir_Archivo
.global Cerrar_Archivo
.global _start

.data
clear:   // etiquetas que marca la ubicación de la cadena en la memoria.
    .asciz "\x1B[2J\x1B[H"
    lenClear = . - clear
dosPuntos:
    .asciz ":"
    lenDosPuntos = .- dosPuntos
encabezado:
    .asciz "Universidad de San Carlos de Guatemala\nFacultad de Ingeniería\nEscuela de Ciencias y Sistemas\nArquitectura de Computadores y Ensambladores 1\nSección A\nIrving Fernando Alvarado Asensio\n202200349\n\nPreisone Enter para continuar..."
    lenEncabezado = .- encabezado
salto:
    .asciz "\n"
    lenSalto = .- salto

espacio:
    .asciz "\t"
    lenEspacio = .- espacio

espacio2:
    .asciz " "
    lenEspacio2 = .- espacio2

Dos_Puntos:
    .asciz ":"
    lenDos_Puntos = .- Dos_Puntos

Columns:
    .asciz " ABCDEFGHIJK"

filas:
    .asciz " 1 2 3 4 5 6 7 8 91011121314151617181920212223"

ComandoImportar:
    .asciz "IMPORTAR"

signoAdmiracion:
    .asciz "!"
    lenSignoAdmiracion = .- signoAdmiracion

ImportarComas:
    .asciz "SEPARADO POR TABULADOR"
ComandoGuardar:
    .asciz "GUARDAR"
ComandoEN:
    .asciz "EN"
Comando_Suma:
    .asciz "SUMA"

Comando_Resta:
    .asciz "RESTA"

Comando_Multiplicacion:
    .asciz "MULTIPLICACION"

Comando_Dividir:
    .asciz "DIVIDIR"

Comando_Potenciar:
    .asciz "POTENCIAR"

Comando_OLOGICO:
    .asciz "OLOGICO"

Comando_YLOGICO:
    .asciz "YLOGICO"

Comando_OXLOGICO:
    .asciz "OXLOGICO"

Comando_NOLOGICO:
    .asciz "NOLOGICO"

Comando_LLenar:
    .asciz "LLENAR"

Comando_Promedio:
    .asciz "PROMEDIO"

Comando_Minimo:
    .asciz "MINIMO"

Comando_Maximo:
    .asciz "MAXIMO"

mensajeErrorComando:
    .asciz "Error: Comando no reconocido."
    lenMensajeErrorComando = .- mensajeErrorComando

mensajeNoCeldasValidad:
    .asciz "Advertencia: No hay celdas válidas para calcular el promedio."
    lenMensajeNoCeldasValidad = .- mensajeNoCeldasValidad

mensajeIngresarValor: //Ingresar el valor para la celda [Letra][Numero]
    .asciz "Ingrese el valor para la celda"
    lenMensajeIngresarValor = .- mensajeIngresarValor

mensajeErrorRango:
    .asciz "La celda de inicio y la celda de fin deben estar en la misma fila o columna."
    lenMensajeErrorRango = .- mensajeErrorRango

mensajeValorNoValido:
    .asciz "Valor no valido. Intentelo nuevamente."
    lenMensajeValorNoValido = .- mensajeValorNoValido

errorExponenteNegativo:
    .asciz "El exponente debe ser un número entero positivo"
    lenErrorExponenteNegativo = .- errorExponenteNegativo



errorDivisionCero:
    .asciz "Error: División por cero"
    lenErrorDivisionCero = .- errorDivisionCero

errorImport:
    .asciz "Error en el comando de importacion\n"
    lenError = .- errorImport
errorSuma:
    .asciz "Error en el comando de suma"
    lenErrorSuma = .- errorSuma

errorAbrir_Archivo:
    .asciz "Error al abrir el archivo\n"
    lenErrAbrir_Archivo = .- errorAbrir_Archivo

getIndexMsg:
    .asciz "Ingrese la letra de la columna para el encabezado "
    lenGetIndexMsg = .- getIndexMsg

LeidoCorrectamente:
    .asciz "Se ha leido correctamente el archivo\n"
    lenLeidoCorrectamente = .- LeidoCorrectamente

errorCeldas:
    .asciz "Error: Celda fuera de rango"
    lenErrorCeldas = .- errorCeldas

errorDesbordamiento:
    .asciz "Valor excede el límite de 64 bits con signo"
    lenErrorDesbordamiento = .- errorDesbordamiento


.bss
Hoja_Calculo:
    .rept 11*23  // Aqui se guardan todos los datos del excel
    .hword 0
    .endr

val:
    .space 4

bufferComando:
    .zero 50

filename:
    .space 100

buffer:
    .zero 1024

Descriptor:
    .space 8

ListaIndices:
    .zero 6

num:
    .space 8

col_imp:
    .space 1

Caracter:
    .space 2

count:
    .zero 8
op1:
    .zero 2

op2:
    .zero 2
// a guardar celdas
celda: 
    .space 3
Num_f: 
    .space 2   

retorno:
    .space 8
    

.text
.macro print stdout, reg, len
    mov x0, \stdout
    ldr x1, =\reg
    mov x2, \len
    mov x8, 64
    svc 0
.endm

.macro printr stdout, reg, len
    mov x0, \stdout   // stdout es la salida estándar
    mov x1, \reg      // Cargar el registro
    mov x2, \len      // Cargar el tamaño a imprimir
    mov x8, 64        // Código de sistema para la llamada a imprimir
    svc 0             // Llamar al sistema
.endm

.macro Input stdin, reg, len
    mov x0, \stdin
    ldr x1, =\reg
    mov x2, \len
    mov x8, 63
    svc 0
.endm

.macro setPosicion Hoja_Calculo, i,j,nuevo_valor
    adr x0, \Hoja_Calculo

    mov x1, \j           
    mov x2, \i          
    mov x3, 11          // Número de columnas 11
    mul x1, x1, x3      // x1 = j * 11
    add x1, x1, x2      // x1 = j * 11 + i
    lsl x1, x1, 1       // Multiplica x1 por 2 para obtener el desplazamiento en bytes

    // Cargar el valor que deseas almacenar en la posición [i, j]
    //mov w4, \nuevo_valor // Reemplaza 'nuevo_valor' con el valor deseado

    // Almacenar el valor en la posición calculada
    strh \nuevo_valor, [x0, x1]   // Guardar el valor en la posición calculada
.endm




int_to_Ascii:
    // params: x0 => number, x1 => buffer address
    mov x10, 0  // contador de digitos a imprimir
    mov x12, 0  // flag para indicar si hay signo menos

    cbz x0, i_zero

    mov x2, 1
    defineBase:
        cmp x2, x0
        mov x5, 0
        bgt cont
        mov x5, 10
        mul x2, x2, x5
        b defineBase

    cont:
        cmp x0, 0  // Numero a convertir
        bgt i_convertirAscii
        b i_negative

    i_zero:
        add x10, x10, 1
        mov w5, 48
        strb w5, [x1], 1
        b i_endConversion

    i_negative:
        mov  x12, 1
        mov w5, 45
        strb w5, [x1], 1
        neg x0, x0

    i_convertirAscii:
        cbz x2, i_endConversion
        udiv x3, x0, x2
        cbz x3, i_reduceBase

        mov w5, w3
        add w5, w5, 48
        strb w5, [x1], 1
        add x10, x10, 1

        mul x3, x3, x2
        sub x0, x0, x3

        cmp x2, 1
        ble i_endConversion

        i_reduceBase:
            mov x6, 10
            udiv x2, x2, x6

            cbnz x10, i_addZero
            b i_convertirAscii

        i_addZero:
            cbnz x3, i_convertirAscii
            add x10, x10, 1
            mov w5, 48
            strb w5, [x1], 1
            b i_convertirAscii

    i_endConversion:
        add x10, x10, x12
        print 1, num, x10
        ret

Ascii_to_int:
    // params: x5, x8 => buffer address
    // return => w9
    sub x5, x5, 1
    a_c_digits:
        ldrb w7, [x8], 1
        cbz w7, a_c_convert
        cmp w7, 10 // salto de linea
        beq a_c_convert
        b a_c_digits

    a_c_convert:
        sub x8, x8, 2
        mov x4, 1
        mov x9, 0

        a_c_loop:
            ldrb w7, [x8], -1
            cmp w7, 45
            beq a_c_negative

            sub w7, w7, 48
            mul w7, w7, w4
            add w9, w9, w7

            mov w6, 10
            mul w4, w4, w6

            cmp x8, x5
            bne a_c_loop
            b a_c_end

        a_c_negative:
            neg w9, w9

        a_c_end:
            ret

Verificar_save_filname:
    ldr x0, =ComandoImportar  // direccion de comando importar
    ldr x1, =bufferComando

    imp_loop: // verificar comando
        ldrb w2, [x0], 1
        ldrb w3, [x1], 1

        cbz w2, imp_filename // si es 0 salta o null

        cmp w2, w3
        bne imp_error

        b imp_loop

        imp_error:
            //print 1, errorImport, lenError
            b Probar_otro

    imp_filename:
        ldr x0, =filename  // A guardar filname
        imp_file_loop:
            ldrb w2, [x1], 1 // comando ingresado

            cmp w2, 32 // espacio
            beq cont_imp_file

            strb w2, [x0], 1
            b imp_file_loop

        cont_imp_file:
            strb wzr, [x0]
            ldr x0, =ImportarComas // x0 = SEPARADO POR COMA
            cont_imp_loop:
                ldrb w2, [x0], 1
                ldrb w3, [x1], 1
                
                cbz w2, end_Verificar_save_filname
                b cont_imp_loop

                cmp w2, w3
                bne imp_error
    end_Verificar_save_filname:
        ret
    Probar_otro:
        b guardar    
import_datos:
    ldr x1, =filename
    stp x29, x30, [SP, -16]!
    bl Abrir_Archivo
    ldp x29, x30, [SP], 16

    ldr x25, =buffer
    mov x10, 0
    ldr x11, =Descriptor
    ldr x11, [x11] // x11 = valor (Descriptor)
    mov x17, 0 //contador de columnas
    ldr x15, =ListaIndices

    Input_head:
        Input x11, Caracter, 1
        ldr x4, =Caracter
        ldrb w2, [x4]

        cmp w2, 9 // tabulador
        beq getIndex

        cmp w2, 10  // salto linea
        beq getIndex

        strb w2, [x25], 1
        add x10, x10, 1
        b Input_head

        getIndex:
            print 1, getIndexMsg, lenGetIndexMsg
            print 1, buffer, x10
            print 1, Dos_Puntos, lenDos_Puntos
            print 1, espacio2, lenEspacio2

            ldr x4, =Caracter
            ldrb w7, [x4]

            Input 0, Caracter, 2 // Ponemos la letra de la columna

            ldr x4, =Caracter
            ldrb w2, [x4]
            sub w2, w2, 65
            
            strb w2, [x15], 1
            add x17, x17, 1

            cmp w7, 10   // salto de linea
            beq end_header

            ldr x25, =buffer
            mov x10, 0
            b Input_head

        end_header:
            stp x29, x30, [SP, -16]!
            bl LeerCSV
            ldp x29, x30, [SP], 16

            ret


            

LeerCSV: 
    ldr x10, =num
    ldr x11,  =Descriptor
    ldr x11, [x11]
    mov x21, 0  // contador de filas
    ldr x15, =ListaIndices // contador de columnas

    rd_num:
        Input x11, Caracter, 1
        ldr x4, =Caracter
        ldrb w3, [x4]
        cmp w3, 9 // tabulador
        beq rd_cv_num

        cmp w3, 10
        beq rd_cv_num

        mov x25, x0
        cbz x0, rd_cv_num

        strb w3, [x10], 1
        b rd_num

    rd_cv_num:
        ldr x5, =num
        ldr x8, =num

        stp x29, x30, [SP, -16]!

        bl Ascii_to_int

        ldp x29, x30, [SP], 16

        ldrb w16, [x15], 1 // obtener la columna

        ldr x20, =Hoja_Calculo
        mov x22, 11      // Este acomoda la cantidad de columnas A-K
        mul x22, x21, x22
        add x22, x16, x22
        strh w9, [x20, x22, LSL #1]

        ldr x12, =num
        mov w13, 0
        mov x14, 0
        
        ldr x20, =ListaIndices
        sub x20, x15, x20
        cmp x20, x17
        bne cls_num
        
        ldr x15, =ListaIndices
        add x21, x21, 1

        cls_num:
            strb w13, [x12], 1
            add x14, x14, 1
            cmp x14, 7
            bne cls_num
            ldr x10, =num
            cbnz x25, rd_num

    rd_end:
        print 1, salto, lenSalto
        print 1, LeidoCorrectamente, lenLeidoCorrectamente
        Input 0, Caracter, 2
        ret


Abrir_Archivo:
    // param: x1 = filename
    mov x0, -100
    mov x2, 0
    mov x8, 56
    svc 0

    cmp x0, 0
    ble op_f_error
    ldr x9, =Descriptor
    str x0, [x9]
    b op_f_end

    op_f_error:
        print 1, errorAbrir_Archivo, lenErrAbrir_Archivo
        Input 0, Caracter, 2
    
    op_f_end:
        ret

Cerrar_Archivo:
    ldr x0, =Descriptor
    ldr x0, [x0]
    mov x8, 57
    SVC 0
    ret

Imprimir_Hoja:
    ldr x4, =Hoja_Calculo    // cargar dirección de la matriz
    mov x9, 0  // index de slots
    mov x7, 0 // Contador de filas
    ldr x18, =Columns
    ldr x19, =val
    
    printColumns:  // Titulos de las columnas A-K
        ldrb w20, [x18], 1
        strb w20, [x19]

        print 1, val, 1
        print 1, espacio, lenEspacio
        add x7, x7, 1
        cmp x7, 12    // Caracteres de las columnas titulos A-K
        bne printColumns
        print 1, salto, lenSalto

    mov x7, 0      // contador
    ldr x18, =filas // x18 = direccion(1-23)
    ldr x19, =val  // valor recorrer  

    loop1:
        ldrh w20, [x18, x7]   // w20 = 2 bytes
        str w20, [x19]
        print 1, val, 2 
        print 1, espacio, lenEspacio

        mov x13, 0 // Contador de columnas
        loop2:
            mov x15, 0 
            ldrh w15, [x4, x9, LSL #1]   // cargar valor del slot de la matriz direccion(x4 + (x9 * 2))

            // Convertir dato del slot a ASCII
            mov x0, x15    // primer valor de la hoja de calculo
            ldr x1, =num   // 
            stp x29, x30, [SP, -16]!
            bl int_to_Ascii  // int_to_Ascii(x0,x1)
            ldp x29, x30, [SP], 16

            print 1, espacio, lenEspacio

            add x9, x9, 1 // incrementar index de slots
            add x13, x13, 1   // incrementar contador de columnas
            cmp x13, 11     //Columnas de 0s
            bne loop2

        print 1, salto, lenSalto

        add x7, x7, 2
        cmp x7, 46   // filas de numeros 1-23
        bne loop1

        ret

Comando_Resta_ins:
    // Extraer los operandos
    BL Extraer_Operandos
    // Realizar la resta
    SUB x0, x1, x2
    // Guardar el resultado en la variable retorno
    LDR x3, =retorno
    STR x0, [x3]
    RET

Comando_Multiplicacion_ins:
    // Extraer los operandos
    BL Extraer_Operandos
    // Realizar la multiplicación
    MUL x0, x1, x2
    // Guardar el resultado en la variable retorno
    LDR x3, =retorno
    STR x0, [x3]
    RET

Comando_Division:
    // Extraer los operandos
    BL Extraer_Operandos
    // Verificar división por cero
    CBZ x2, Division_Error
    // Realizar la división
    UDIV x0, x1, x2
    // Guardar el resultado en la variable retorno
    LDR x3, =retorno
    STR x0, [x3]
    RET

Division_Error:
    // Manejar el error de división por cero
    LDR x1, =errorDivisionCero
    LDR x2, =lenErrorDivisionCero
    BL print
    RET

Comando_OR_Logico:
    // Extraer los operandos
    BL Extraer_Operandos
    // Realizar la operación OR lógica
    ORR x0, x1, x2
    // Guardar el resultado en la variable retorno
    LDR x3, =retorno
    STR x0, [x3]
    RET

Comando_AND_Logico:
    // Extraer los operandos
    BL Extraer_Operandos
    // Realizar la operación AND lógica
    AND x0, x1, x2
    // Guardar el resultado en la variable retorno
    LDR x3, =retorno
    STR x0, [x3]
    RET

Comando_XOR_Logico:
    // Extraer los operandos
    BL Extraer_Operandos
    // Realizar la operación XOR lógica
    EOR x0, x1, x2
    // Guardar el resultado en la variable retorno
    LDR x3, =retorno
    STR x0, [x3]
    RET

Comando_NOT_Logico:
    // Extraer el operando
    LDR x0, =bufferComando
    BL Verificar_Operando
    // Realizar la operación NOT lógica
    MVN x0, x0
    // Guardar el resultado en la variable retorno
    LDR x1, =retorno
    STR x0, [x1]
    RET


Extraer_Operandos:
    // Primer Operando
    LDR x0, =bufferComando
    BL Verificar_Operando
    MOV x1, x0  // Guardar en x1 el primer operando

    // Segundo Operando
    LDR x0, =bufferComando
    BL Verificar_Operando
    MOV x2, x0  // Guardar en x2 el segundo operando
    RET



Verificar_Comando_Suma:
    ldr x0, =Comando_Suma  // dirección del comando SUMA
    ldr x1, =bufferComando
    suma_loop:  // verificar comando
        ldrb w2, [x0], 1
        ldrb w3, [x1], 1
        cbz w2, Procesar_Suma  // si es 0, salta o null
        cmp w2, w3
        bne siguiente_comando  // salta al siguiente comando si no coincide
        b suma_loop

Procesar_Suma:
    ldr x1, =bufferComando

    // Leer y procesar el primer operando
    bl Leer_Operando
    mov x0, x19  // guardar el primer operando en x19

    // Leer y procesar el segundo operando
    bl Leer_Operando
    mov x1, x19  // guardar el segundo operando en x19

    // Realizar la suma
    add x0, x0, x1  // x0 = primer operando + segundo operando

    // Guardar el resultado en la variable retorno
    ldr x2, =retorno
    str x0, [x2]

    // Mostrar el resultado
    mov x1, x0
    bl int_to_Ascii  // convertir el resultado a ASCII para impresión

    ret

Leer_Operando:
    // Salte espacios
    ldrb w2, [x1], 1
    cmp w2, ' '  // comparar con espacio
    beq Leer_Operando

    // Verificar si es '*'
    cmp w2, '*'  
    beq Es_Retorno

    // Verificar si es un número
    cmp w2, '0'
    blt Leer_Celda  // si es menor que '0', no es un número
    cmp w2, '9'
    bgt Leer_Celda  // si es mayor que '9', no es un número

    // Leer número
    sub x1, x1, 1
    bl Ascii_to_int
    mov x19, x0  // guardar el número leído
    ret

Es_Retorno:
    ldr x0, =retorno
    ldr x19, [x0]  // cargar el valor de retorno
    ret

Leer_Celda:
    // Leer fila y columna de la celda
    ldrb w2, [x1], 1
    sub w2, w2, 'A'  // convertir a índice de columna
    lsl x2, x2, 1  // multiplicar por 2 para obtener el desplazamiento en bytes
    ldrb w3, [x1], 1
    sub w3, w3, '1'  // convertir a índice de fila
    lsl x3, x3, 4  // multiplicar por el tamaño de la fila

    // Cargar el valor de la celda
    add x2, x2, x3
    ldrh w19, [x0, x2]
    ret


Verificar_Guardar:
    ldr x0, =ComandoGuardar  // direccion de comando importar
    ldr x1, =bufferComando

    imp_loop_G: // verificar comando
        ldrb w2, [x0], 1
        ldrb w3, [x1], 1

        cbz w2, Buscar_Entero // si es 0 salta o null

        cmp w2, w3
        bne Prueba

        b imp_loop_G

        Prueba:
            //print 1, errorImport, lenError
            b Probar_otro1
    Buscar_Entero:
        ldr x0, =num  // A guardar en num
        Verificando:
            ldrb w2, [x1], 1 // comando ingresado

            cmp w2, 32 // espacio
            beq Verificar_EN

            strb w2, [x0], 1
            b Verificando

        Verificar_EN:
            ldr x5, =num
            ldr x8, =num
            stp x29, x30, [SP, -16]!
            bl Ascii_to_int // retorno en w9
            ldp x29, x30, [SP], 16

            ldr x0, =ComandoEN  // direccion de comando importar
            imp_loop_e: // verificar comando
                ldrb w2, [x0], 1
                ldrb w3, [x1], 1
        
                cbz w2, Buscar_Celda // si es 0 salta o null
        
                cmp w2, w3
                bne Error_g
                b imp_loop_e
            Error_g:
                print 1, errorImport, lenError
            Buscar_Celda:
                ldr x0, =celda  // A guardar celda
                Guardando_en_Celda:
                    ldrb w2, [x1], 1 // comando ingresado
        
                    cmp w2, 10 // salto de linea
                    beq end_g
                    strb w2,[x0],1
                    b Guardando_en_Celda
        
            end_g:
                ldr x0, =celda      
                ldrb w2, [x0],1       
                 
                uxtw x20,w2  // Guardamos la letra para la columna

                ldr x1, =Num_f
                ldrh w2, [x0]       
                strh w2,[x1]   // guardamos el numero de fila que puede ser de dos bytes

                mov w12, w9 // Guardamos el valor antiguo de w9 ya que es el numero a guardar

                ldr x5, =Num_f
                ldr x8, =Num_f
                stp x29, x30, [SP, -16]!
                bl Ascii_to_int // retorno en w9
                ldp x29, x30, [SP], 16
                
                /*
                print 0, Num_f, 2
                print 0, num, 8
                print 0, Letra, 1*/

                uxtw x9, w9   // w9 es el valor de la fila lo pasamos a x  
                sub x9,x9,1    // fila para el arreglo 1-23   
                sub x20,x20,65 // columna para el arreglo A-K (Restamos 65 por el valor ascii)
                
                setPosicion Hoja_Calculo, x20, x9, w12  // arreglo, i, j, valor
                ret
                    
/*
el orden en que se ejecutaran los comandos seran del 1 hasta el final, o sea si un comando falla 
entonces prueba con el siguiente
 */
_start:

    Ingreso_Comandos:
        //print 1, clear, lenClear

        bl Imprimir_Hoja

        print 1, dosPuntos, lenDos_Puntos
        Input 0, bufferComando, 50 // Ingreso de comando
        // 1) Comando importar
        bl Verificar_save_filname
        bl import_datos

        guardar: // 2) comando guardar
            bl Verificar_Guardar
        Probar_otro1:

    b Ingreso_Comandos

    exit: 
        mov x0, 0
        mov x8, 93
        svc 0