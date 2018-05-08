# Pedir por teclado el tamaño del vector
.data
welcome1: .asciiz "########## WELCOME ###########\n"
welcome2: .asciiz "# Valores permitidos: 0 - 99 #\n"
string1: .asciiz "Introduce el tamaño del vector:"
string2: .asciiz "Dime el valor "
string3: .asciiz "Resultado media aritmetica: "
string4: .asciiz "Error: Introduce un valor entre 1 y 99!\n"
string5: .asciiz "Error: Introduce un valor entre 0 y 99!\n"
string6: .asciiz "\nRaiz = "
tamaño: .byte 0x00
min: 	.byte 0x00
max:	.byte 0x63
#cero: .byte 0x0A
#vector: .word

.text
	li $s0, 0xFFFF0010 # carga dirección base del displayderecho
	li $s1, 0xFFFF0011 # carga dirección base del displayizquierdo
	
	li $s3, 0x10010100
	#========================= WELCOME =================================
	la 	$a0, welcome1
	li	$v0, 4
	syscall
	
	la 	$a0, welcome2
	li	$v0, 4
	syscall
	
	#========================= TAMAÑO DEL VECTOR =========================
	# Completar el vector con valores por teclado, TIENEN QUE SER NUMEROS
vector:
	la 	$a0, string1		# --- "Introduce el tamaño del vector:"
	li	$v0, 4
	syscall
	
	li	$v0, 5			# leemos un entero introducido por teclado
	syscall
	
	
	
	move 	$t1, $v0		# t1 tamaño, t0 cont
	sb	$t1, tamaño
	
	lb	$t6, min		# cargamos 0 como valor minimo
	ble 	$t1, $t6, error1 	# si el numero es <= 0 o >99 volvemos a pedir
	lb	$t6, max		# cargamos 1 como valor maximo
	bge 	$t1, $t6, error1 	
	
	.data
	#.align $t1
	#.space tamaño
	.text
	
	#=================== LECTURA VALORES VECTOR ================
ask:	
	addi	$t0, $t0, 1 # cont++
	la 	$a0, string2		# --- "Dime valor nº:"
	li	$v0, 4
	syscall
	
	move 	$a0, $t0
	li	$v0, 1
	syscall
	
	li	$v0, 5			# leemos un entero introducido por teclado
	syscall
	
	move 	$t2, $v0
	
	lb	$t6, min		# cargamos 0 como valor minimo
	blt 	$t2, $t6, error2 	# si el numero es negativo o >99 volvemos a pedir
	lb	$t6, max		# cargamos 99 como valor maximo
	bge 	$t2, $t6, error2	
	
	add 	$t3, $t3, $t2 		# suma
	
	
	sw 	$t2, 0($s3)
	addi 	$s3, $s3, 4 		# siguiente palabra
	
	blt 	$t0, $t1, ask
	
	
	#==================== MEDIA ARITMETICA =====================
	
	div $t3, $t1 #media aritmetica
	mflo $t5
	#lb $t5, cero
	
	
	num:
	#andi	$t0, $t0, 1 # cont++
	#blt 	$t0, $t1, num
	la 	$a0, string3		# --- "Resultado media aritmetica"
	li	$v0, 4
	syscall
	
	move 	$a0, $t5
	li	$v0, 1
	syscall
	
	#Debemos retornar...
	li $s3, 0x10010100
	lb	$t0, min #reset cont
pointer:
	
	la 	$a0, string6		# --- "Resultado media aritmetica"
	li	$v0, 4
	syscall
	
	lw	$a0, 0($s3)		# Cargamos la palabra i del vector que almacenamos en data
	mult 	$a0, $a0			# Obtenemos su cuadrado
	
	mflo	$t4			# almacenamos el cuadrado en $t4
	lb	$t3, min 		#reset suma
	add 	$t3, $t3, $t4 		# suma
	
	move 	$a0, $t3
	li	$v0, 1
	syscall
	
	addi	$t0, $t0, 1 # cont++
	addi 	$s3, $s3, 4 		# siguiente palabra
	blt 	$t0, $t1, pointer
	##.....
					# sqrt(valor[1]^2 + ... valor[i]^2)
					
	#t0 = cont, t3 = suma, t4 = cuadrado, t5 = media aritmetica
	
	#case0: bne $t5, 0, case1
		#code...
	#case1: bne $t5, 1, case2
		#code...
	#case2: bne $t5, 1, case3
		#code...
	#case3: bne $t5, 1, case4
	
	
	
end:	li	$v0, 10			# Fin del programa#
	syscall
	
	
error1: la 	$a0, string4		# --- "Error: Introduce un valor entre 1 y 99"
	li	$v0, 4
	syscall
	j vector
	
error2: la 	$a0, string5		# --- "Error: Introduce un valor entre 0 y 99"
	li	$v0, 4
	syscall
	subi	$t0, $t0, 1 # cont++
	j ask
