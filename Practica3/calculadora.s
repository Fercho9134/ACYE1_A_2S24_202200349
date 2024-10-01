.section .data
header:
    .asciz "Universidad de San Carlos de Guatemala\nFacultad de Ingeniería\nEscuela de Ciencias y Sistemas\nArquitectura de Computadores y Ensambladores 1\nSección A\nIrving Fernando Alvarado Asensio\n202200349\n\nPresione ENTER para continuar...\n"
menu:
    .asciz "\n\n-----Menu-----\n1. Suma\n2. Resta\n3. Multiplicación\n4. División\n5. Calculo con memoria\n6. Finalizar calculadora\n\nSeleccione una opción: "
alerta:
    .asciz "\n\nPresione ENTER para continuar...\n"
sum_menu:
    .asciz "\nSeleccione la forma de entrada:\n1. Ingrese el primer número y el segundo número\n2. Ingrese la operación completa\n3. Ingrese los números separados por comas\nSeleccione una opción: "
primer_prompt:
    .asciz "Ingrese el primer numero: "
segundo_prompt:
    .asciz "Ingrese el segundo numero: "
result_msg:
    .asciz "El resultado es: %d\n"

.section .bss
    .lcomm buffer, 100

.section .text
.global _start

_start:
    // Mostrar el encabezado
    mov x0, 1          // file descriptor 1 (stdout)
    ldr x1, =header    // dirección del encabezado
    mov x2, 228        // longitud del encabezado
    mov x8, 64         // syscall write
    svc 0              // llamada al sistema

    // Leer entrada del usuario (esperar Enter)
    mov x0, 0          // file descriptor 0 (stdin)
    ldr x1, =buffer    // dirección del buffer
    mov x2, 100          // longitud del buffer
    mov x8, 63         // syscall read
    svc 0              // llamada al sistema

menu_loop:
    // Mostrar el menú
    mov x0, 1          // file descriptor 1 (stdout)
    ldr x1, =menu      // dirección del menú
    mov x2, 140       // longitud del menú
    mov x8, 64         // syscall write
    svc 0              // llamada al sistema

    // Leer opción del usuario
    mov x0, 0          // file descriptor 0 (stdin)
    ldr x1, =buffer    // dirección del buffer
    mov x2, 1          // longitud del buffer
    mov x8, 63         // syscall read
    svc 0              // llamada al sistema

    // Comparar la opción y decidir la acción
    ldrb w0, [x1]      // cargar la opción en w0
    cmp w0, '1'        // comparar con '1'
    beq sum_operation  // si es '1', ir a la suma
    cmp w0, '6'        // comparar con '6'
    beq end_program    // si es '6', finalizar

    // Aquí puedes agregar las funciones para cada opción
    b menu_loop        // volver al menú


sum_operation:
    // Pedir el primer número
    mov x0, 1          // file descriptor 1 (stdout)
    ldr x1, =primer_prompt  // dirección del mensaje
    mov x2, 26         // longitud del mensaje
    mov x8, 64         // syscall write
    svc 0              // llamada al sistema

    bl clear_buffer
    // Leer el primer número
    mov x0, 0          // file descriptor 0 (stdin)
    ldr x1, =buffer    // dirección del buffer
    mov x2, 100        // longitud del buffer
    mov x8, 63         // syscall read
    svc 0              // llamada al sistema

    // Convertir el primer número a entero
    b convert_to_int
    // Guardamos el prmer número en x4
    mov x4, x2

    // Pedir el segundo número
    mov x0, 1          // file descriptor 1 (stdout)
    ldr x1, =segundo_prompt  // dirección del mensaje
    mov x2, 27         // longitud del mensaje
    mov x8, 64         // syscall write
    svc 0              // llamada al sistema
    // Leer el segundo número
    mov x0, 0          // file descriptor 0 (stdin)
    ldr x1, =buffer    // dirección del buffer
    mov x2, 100        // longitud del buffer
    mov x8, 63         // syscall read
    svc 0              // llamada al sistema

    // Convertir el segundo número a entero
    b convert_to_int
    // Guardamos el segundo número en x5
    mov x5, x2

    // Sumar los números
    add x6, x4, x5

    // Mostrar el resultado
    b show_result

clear_buffer:
    ldr x0, =buffer
    mov x1, 100

clear_loop:
    subs x1, x1, 1
    strb w2, [x0], 1
    cbnz x1, clear_loop
    ret

convert_to_int:
    mov x2, 0
    mov x3, 10
    ldr x1, =buffer

convert_loop:
    ldrb w4, [x1], 1
    subs x4, x4, '0'
    blt end_convert
    mul x2, x2, x3
    add x2, x2, x4
    b convert_loop

end_convert:
    ret

show_result:
    // Mostrar el resultado
    mov x0, 1          // file descriptor 1 (stdout)
    ldr x1, =result_msg  // dirección del mensaje
    mov x2, 20         // longitud del mensaje
    mov x8, 64         // syscall write
    svc 0              // llamada al sistema

    //Conertimos X6 a string para mostrarlo
    ldr x0, =buffer
    mov x1, x6
    bl int_to_string
    mov x0, 1          // file descriptor 1 (stdout)
    ldr x1, =buffer    // dirección del buffer
    mov x2, 20       // longitud del buffer
    mov x8, 64         // syscall write
    svc 0              // llamada al sistema

    b menu_loop 

int_to_string:
    stp x29, x30, [sp, -16]!
    mov x29, sp

    mov x2, x0 
    add x2, x2, 19
    mov w3, 0

convert_loop2:
    mov x10, 10
    udiv x4, x1, x10
    msub x5, x4, x4, x10
    add x5, x5, '0'
    strb w5, [x2], -1
    mov x1, x4
    add w3, w3, 1
    cbnz x1, convert_loop2

    mov w5, 0
    strb w5, [x2]

    sub x0, x0, w3, uxtw
    ldp x29, x30, [sp], 16
    ret



end_program:
    // Finalizar el programa
    mov x8, 93         // syscall exit
    mov x0, 0          // código de salida
    svc 0              // llamada al sistema
