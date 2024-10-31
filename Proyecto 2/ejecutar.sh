# Ensamblar el archivo calculadora.s
aarch64-linux-gnu-as -mcpu=cortex-a57 proyecto.s -o proyecto.o

# Enlazar el archivo objeto
#aarch64-linux-gnu-ld proyecto.o -o proyecto

# Ejecutar el programa sin depuración
#qemu-aarch64 
./proyecto