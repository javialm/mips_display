# Pedir por teclado el tamaño del vector

#la media aritmetica se muestra por consola, pero ademas mostrar la distancia euclidea.
#Para ello indicaremos pulse una tecla, y cuando lees un char, si pulsas una tecla salta. No hace falta imprimir la tecla.

.data
welcome1: .asciiz "########## WELCOME ###########\n"
welcome2: .asciiz "# Valores permitidos: 0 - 99 #\n\n"
string1: .asciiz "Introduce el tamaño del vector:"
string2: .asciiz "Dime el valor "
string3: .asciiz "\nResultado media aritmetica: "
string4: .asciiz "Error: Introduce un valor entre 1 y 99!\n"
string5: .asciiz "Error: Introduce un valor entre 0 y 99!\n"
string6: .asciiz "\nCuadrado = "
string7: .asciiz "\nRaiz = "
tamaño: .byte 0x00
min: 	.byte 0x00
max:	.byte 0x63

.align 4
cero:	.byte 0x3F
uno:	.byte 0x06
dos:	.byte 0x5B
tres:	.byte 0x4F
cuat:	.byte 0x66
cinc: 	.byte 0x6D
seis:	.byte 0x7D
siet:	.byte 0x07
ocho:	.byte 0x7F
nuev:	.byte 0x6F
e:	.byte 0x79
r:	.byte 0x50 # 
#cero: .byte 0x0A
#vector: .word
.align 4
vector_dir:  .word

.text
	#========================= DIRECCIONES =============================
	li 	$s0, 0xFFFF0010 # carga dirección base del display derecho
	li 	$s1, 0xFFFF0011 # carga dirección base del display izquierdo
	
	la  $t2, min			# reset displays
	lb  $t2, 0($t2)
	sb $t2, 0($s0) 
	sb $t2, 0($s1) 
	
	#li 	$s4, 0x10010100 #direccion estatica para los numeros para el display
	la 	$s4, cero 	#direccion dinamica para los numeros para el display
	
	
	#li 	$s3, 0x10010140 #direccion estatica del vector
	la 	$s3, vector_dir #direccion dinamica del vector
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
	
	
	la  $t2, min			# reset displays
	lb  $t2, 0($t2)
	sb $t2, 0($s0) 
	sb $t2, 0($s1) 
	
	
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
	
	
	
	add 	$t3, $t3, $t2 		# suma de los comp del vector
	
	
	sw 	$t2, 0($s3)
	addi 	$s3, $s3, 4 		# siguiente palabra
	
	la  $t2, min			# reset displays
	lb  $t2, 0($t2)
	sb $t2, 0($s0) 
	sb $t2, 0($s1) 
	
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
	#li $s3, 0x10010140
	la  $s3, vector_dir
	lb	$t0, min #reset cont
	lb	$t3, min 		#reset suma
pointer:
	
	la 	$a0, string6		# --- "Cuadrado"
	li	$v0, 4
	syscall
	
	lw	$a0, 0($s3)		# Cargamos la palabra i del vector que almacenamos en data
	mult 	$a0, $a0			# Obtenemos su cuadrado
	
	mflo	$t4			# almacenamos el cuadrado en $t4
	
	add 	$t3, $t3, $t4 		# suma
	
	move 	$a0, $t3
	li	$v0, 1
	syscall
	
	addi	$t0, $t0, 1 # cont++
	addi 	$s3, $s3, 4 		# siguiente palabra
	blt 	$t0, $t1, pointer
	##.....
					# sqrt(valor[1]^2 + ... valor[i]^2)
	
	
	#========================= RAIZ =================================
	#ir multiplicando numero x el mismo numero. Si da el numero que evaluamos, y la siguiente es mayor, esa es la raiz.
	
	lb	$t0, min 		#reset suma		
sqrt:	
	addi	$t0, $t0, 1 		# cont++
	
	mult $t0, $t0
	mflo $t2
	
	blt $t2, $t3 sqrt
	
	la 	$a0, string7		# --- "RAIZ"
	li	$v0, 4
	syscall
	
	move 	$a0, $t0  		# mostrar la rais
	li	$v0, 1
	syscall
	
	
	move 	$s5, $t0		# guardamos raiz en s5
	
	
	#t0 = cont, $t1 = tamanho $t2 = aux, t3 = suma, t4 = cuadrado, t5 = media aritmetica
	#s0 = ??, $s5 = rais?

#======================================================================================
#				DISPLAYS
#======================================================================================
	#mostrar media aritmetica
	#...
	
	#pedir caracter para continuar
	#...
	
	div $t2, $s5, 10 # dividimos el numero de la raiz x 10 para obtener
	
	mfhi $t2
	add $t2, $s4, $t2 # sumamos la unidad a la direccion de memoria.
	lb $t2, 0($t2)
	sb $t2, 0($s0) # almacena en dirección del displayderecho el valor de $t1
	
	mflo $t2
	add $t2, $s4, $t2 # sumamos la unidad a la direccion de memoria.
	lb $t2, 0($t2)
	sb $t2, 0($s1) # almacena en dirección del displayderecho el valor de $t1


	
end:	li	$v0, 10			# Fin del programa#
	syscall
	

#======================================================================================
#				CONTROL DE ERRORES
#======================================================================================
error1: la 	$a0, string4		# --- "Error: Introduce un valor entre 1 y 99"
	li	$v0, 4
	syscall
	
	la  $t2, r			# Display Er
	lb  $t2, 0($t2)
	sb $t2, 0($s0)
	la  $t2, e
	lb  $t2, 0($t2)
	sb $t2, 0($s1)
	j vector
	
error2: la 	$a0, string5		# --- "Error: Introduce un valor entre 0 y 99"
	li	$v0, 4
	syscall
	subi	$t0, $t0, 1 # cont--
	
	la  $t2, r			# Display Er
	lb  $t2, 0($t2)
	sb $t2, 0($s0)
	la  $t2, e
	lb  $t2, 0($t2)
	sb $t2, 0($s1)
	j ask
	
