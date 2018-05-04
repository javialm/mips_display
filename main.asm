# Pedir por teclado el tama�o del vector
.data
string1: .asciiz "Introduce el tama�o del vector:"
string2: .asciiz "Dime el valor "
tama�o: .byte 0
#cero: .byte 0x0A
#vector: .word

.text
	li $s0, 0xFFFF0010 # carga direcci�n base del displayderecho
	li $s1, 0xFFFF0011 # carga direcci�n base del displayizquierdo
	
	li $s3, 0x10010040
	
	#========================= TAMA�O DEL VECTOR =========================
	# Completar el vector con valores por teclado, TIENEN QUE SER NUMEROS
	la 	$a0, string1		# --- "Introduce el tama�o del vector:"
	li	$v0, 4
	syscall
	
	li	$v0, 5			# leemos un entero introducido por teclado
	syscall
	move 	$t1, $v0		# t1 tama�o, t0 cont
	sb	$t1, tama�o
	.data
	#.align $t1
	#.space tama�o
	.text
	
	#=================== LECTURA VALORES VECTOR ================
ask:	
	addi	$t0, $t0, 1 # cont++
	la 	$a0, string2		# --- "Dime valor n�:"
	li	$v0, 4
	syscall
	
	move 	$a0, $t0
	li	$v0, 1
	syscall
	
	li	$v0, 5			# leemos un entero introducido por teclado
	syscall
	
	move 	$t2, $v0
	
	add $t3, $t3, $t2 #suma
	
	sw $t2, 0($s0)
	addi 	$s3, $s0, 4 		# siguiente palabra
	
	blt 	$t0, $t1, ask
	
	#==================== MEDIA ARITMETICA =====================
	
	div $t3, $t1 #media aritmetica
	mflo $t5
	#lb $t5, cero
	
	
	num:
	#andi	$t0, $t0, 1 # cont++
	#blt 	$t0, $t1, num
	move 	$a0, $t0
	li	$v0, 1
	syscall
	
	#case0: bne $t5, 0, case1
		#code...
	#case1: bne $t5, 1, case2
		#code...
	#case2: bne $t5, 1, case3
		#code...
	#case3: bne $t5, 1, case4
	
	
	
end:	li	$v0, 10			# Fin del programa#
	syscall
