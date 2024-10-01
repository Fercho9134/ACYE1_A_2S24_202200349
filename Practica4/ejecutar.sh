#!/bin/bash

# Ensamblar el archivo calculadora.s
aarch64-linux-gnu-as -mcpu=cortex-a57 main.s -o main.o

# Enlazar el archivo objeto
aarch64-linux-gnu-ld main.o -o main

# Ejecutar el programa sin depuración
qemu-aarch64 ./main
