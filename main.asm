.data

welcome1: .asciiz "########## WELCOME ###########\n"
welcome2: .asciiz "# Valores permitidos: 0 - 99 #\n\n"
string1: .asciiz "Introduce el tamaño del vector:"
string2: .asciiz "Dime el valor "
string3: .asciiz "\n--Media aritmetica: "
string4: .asciiz "Error: Introduce un valor entre 1 y 99!\n"
string5: .asciiz "Error: Introduce un valor entre 0 y 99!\n"
string6: .asciiz "\n\nPulse una tecla para continuar... "
string7: .asciiz "\n--Distancia euclidea: "
string8: .asciiz "\n--Factorial: "
string9: .asciiz "\n No se puede representar un valor > 99 "
string10: .asciiz ": "

.space 4
			
size:	.byte 0x00
one:	.byte 0x01		# constante. valor decimal 1
min: 	.byte 0x00		# constante. Definimos el valor mínimo
max:	.byte 0x63		# constante. Definimos el valor máximo
media:	.byte 0x22		# media aritmetica
dist:	.byte 0x00		# distancia euclidea
fact:	.half 0x0000		# factorial del tamaño del vector

.align 2			# Alineamos	
		
cero:	.byte 0x3F		# Definimos los valores correspondientes a
uno:	.byte 0x06		# los números a representar por el display
dos:	.byte 0x5B
tres:	.byte 0x4F
cuat:	.byte 0x66
cinc: 	.byte 0x6D
seis:	.byte 0x7D
siet:	.byte 0x07
ocho:	.byte 0x7F
nuev:	.byte 0x6F
e:	.byte 0x79		# Letra E
r:	.byte 0x50 		# Letra r

.align 2			# Alineamos
vector_dir:  .word		# Dirección dinámica del vector.

#======================================================================================
#				MAIN
#======================================================================================
	#t0 = cont, $t1 = tamanho $t2 = aux, t3 = suma, t4 = cuadrado, t5 = media aritmetica
	#s0 = ??, $s5 = rais?, s6 factorial
.text
	#========================= DIRECCIONES =============================
	li 	$s0, 0xFFFF0010 	# carga dirección base del display derecho
	li 	$s1, 0xFFFF0011 	# carga dirección base del display izquierdo
	
	la 	$s4, cero 		#direccion dinamica para los numeros para el display
	la 	$s3, vector_dir 	#direccion dinamica del vector
	
	#========================= WELCOME =================================
	la 	$a0, welcome1
	li	$v0, 4
	syscall
	
	la 	$a0, welcome2
	li	$v0, 4
	syscall
	
	la  	$t2, min		# reset displays
	lb  	$t2, 0($t2)
	sb 	$t2, 0($s0) 
	sb 	$t2, 0($s1) 
	
	#========================= TAMAÑO DEL VECTOR =========================
vector:
	
	la 	$a0, string1		# --- "Introduce el tamaño del vector:"
	li	$v0, 4
	syscall
	
	li	$v0, 5			# leemos un entero introducido por teclado
	syscall
	
	move 	$t1, $v0		# guardamos en $t1 el entero
	sb	$t1, size		# Almacenamos el valor en la direccion de la etiqueta
	
	lb	$t6, min		# cargamos 0 como valor minimo
	ble 	$t1, $t6, error1 	# si el numero es <= 0, error, repetir
	lb	$t6, max		# cargamos 99 como valor maximo
	bge 	$t1, $t6, error1 	# si el numero es >99 error, repetir
	
	la  	$t2, min		# reset displays
	lb  	$t2, 0($t2)
	sb 	$t2, 0($s0) 
	sb 	$t2, 0($s1) 
	
	
	#=================== LECTURA VALORES VECTOR ================
ask:	
	addi	$t0, $t0, 1 # cont++
	la 	$a0, string2		# --- "Dime valor nº:"
	li	$v0, 4
	syscall
	
	move 	$a0, $t0
	li	$v0, 1
	syscall
	
	la 	$a0, string10
	li	$v0, 4
	syscall
	
	li	$v0, 5			# leemos un entero introducido por teclado
	syscall
	
	move 	$t2, $v0
	
	lb	$t6, min		# cargamos 0 como valor minimo
	blt 	$t2, $t6, error2 	# si el numero es negativo repetir
	lb	$t6, max		# cargamos 99 como valor maximo
	bge 	$t2, $t6, error2	# si el numero >99 repetir
	
	add 	$t3, $t3, $t2 		# suma de los componentes del vector
	
	sw 	$t2, 0($s3)
	addi 	$s3, $s3, 4 		# siguiente palabra
	
	la  	$t2, min		# reset displays
	lb  	$t2, 0($t2)
	sb 	$t2, 0($s0) 
	sb 	$t2, 0($s1) 
	
	blt 	$t0, $t1, ask	

	#==================== MEDIA ARITMETICA =====================
	
	mtc1 $t3, $f0
  	cvt.s.w $f12, $f12
  	
  	mtc1 $t1, $f2
  	cvt.s.w $f12, $f12
  	
  	div.s $f4, $f0, $f2
	
	div 	$t3, $t1 		# dividir suma de los componentes / num elementos
	mflo 	$t5
	sb	$t5, media		# Almacenamos la media en memoria

	
	#==================== SUMA DE LOS CUADRADOS =====================
	
	la  	$s3, vector_dir		#reset puntero del vector
	lb	$t0, min 		#reset cont
	lb	$t3, min 		#reset suma
	
pointer:
	
	lw	$a0, 0($s3)		# Cargamos el elemento i del vector que almacenamos en data
	mult 	$a0, $a0		# Obtenemos su cuadrado
	
	mflo	$t4			# almacenamos el cuadrado en $t4
	
	add 	$t3, $t3, $t4 		# suma de cuadrados
	
	addi	$t0, $t0, 1 		# cont++
	addi 	$s3, $s3, 4 		# siguiente palabra
	blt 	$t0, $t1, pointer	# Si quedan elementos por recorrer --> pointer


	#========================= RAIZ =================================
	#ir multiplicando numero x el mismo numero. Si da el numero que evaluamos, y la siguiente es mayor, esa es la raiz.
	# sqrt(valor[1]^2 + ... valor[i]^2)
	
	lb	$t0, min 		#reset suma		
sqrt:	
	addi	$t0, $t0, 1 		# cont++
	
	mult 	$t0, $t0
	mflo 	$t2
	
	blt 	$t2, $t3 sqrt
	
	bgt 	$t3,$t2, end_sqrt	# si 50 > 64
	subi	$t0, $t0, 1 		# cont--
	end_sqrt:

	move 	$s5, $t0		# guardamos raiz en s5
	sb	$t0, dist		# Almacenamos la distancia euclidea en memoria
	
	
	#========================= FACTORIAL =================================
	
	lb 	$t7, one
	move 	$t2, $t1 		# cargar tamaño del vector
	move 	$t0, $t1		# cargar tamaño del vector
factor:
	subi 	$t2, $t2, 1
	mult 	$t2, $t0
	mflo 	$t0
	
	blt 	$t7, $t2, factor
	move 	$s7, $t0
	sh	$t0, fact		# Almacenamos el factorial en memoria

#======================================================================================
#				DISPLAYS
#======================================================================================

	#pedir caracter para continuar
	#...
	la 	$a0, string6		# --- "Pulsa una tecla..."
	li	$v0, 4
	syscall
			
	li	$v0, 12
	syscall
	
	#mostrar media aritmetica
	#...
	
	div 	$t2, $t5, 10 		# dividimos la raiz entre 10
	
	mfhi 	$t2
	add 	$t2, $s4, $t2 		# sumamos la unidad a la direccion de memoria.
	lb 	$t2, 0($t2)
	sb 	$t2, 0($s0) 		# almacena en dirección del display derecho el valor
	
	mflo 	$t2
	add 	$t2, $s4, $t2 		# sumamos la decena a la direccion de memoria.
	lb 	$t2, 0($t2)
	sb 	$t2, 0($s1) 		# almacena en dirección del displayderecho el valor
	
	la 	$a0, string3		# --- "Resultado media aritmetica"
	li	$v0, 4
	syscall
	
	#move 	$a0, $t5
	#li	$v0, 1
	#syscall
			#Mostrar en simple precision en vez de entero
	li $v0, 2
  	mov.s $f12, $f4   # Move  $f4 to  $f12
  	syscall
	
	#pedir caracter para continuar
	#...
	la 	$a0, string6		# --- "Pulsa una tecla..."
	li	$v0, 4
	syscall
	
	li	$v0, 12
	syscall
	
	#Mostrar distancia euclidea
	
	div 	$t2, $s5, 10 		# dividimos la raiz entre 10
	
	mfhi 	$t2
	add 	$t2, $s4, $t2 		# sumamos la unidad a la direccion de memoria.
	lb 	$t2, 0($t2)
	sb 	$t2, 0($s0) 		# almacena en dirección del displayderecho el valor
	
	mflo 	$t2
	add 	$t2, $s4, $t2 		# sumamos la decena a la direccion de memoria.
	lb 	$t2, 0($t2)
	sb 	$t2, 0($s1) 		# almacena en dirección del displayderecho el valor
	
	la 	$a0, string7		# --- " Distancia euclidea"
	li	$v0, 4
	syscall
	
	lb	$t0, dist
	move 	$a0, $t0  		# mostrar la raiz
	li	$v0, 1
	syscall
	
	#pedir caracter para continuar
	#...
	la 	$a0, string6		# --- "Pulsa una tecla..."
	li	$v0, 4
	syscall
	
	li	$v0, 12
	syscall
	
	#Mostrar factorial
	
	lh	$t2, fact		# cargamos la variable factorial
	lb	$t0, max		# cargamos el valor máximo
	
	la 	$a0, string8		# --- "Factorial:"
	li	$v0, 4
	syscall
	
	lh	$a0, fact
	li	$v0, 1
	syscall
	
	bgt	$t2, $t0, error3	# si el valor es > 99 no se puede representar
	
	div 	$t2, $t2, 10 		# dividimos el numero entre 10
	
	mfhi 	$t2
	add 	$t2, $s4, $t2 		# sumamos la unidad a la direccion de memoria.
	lb 	$t2, 0($t2)
	sb 	$t2, 0($s0) 		# almacena en dirección del displayderecho el valor
	
	mflo 	$t2
	add 	$t2, $s4, $t2 		# sumamos la decena a la direccion de memoria.
	lb 	$t2, 0($t2)
	sb 	$t2, 0($s1) 		# almacena en dirección del displayderecho el valor
	
	
	
end:	li	$v0, 10			# Fin del programa#
	syscall
	

#======================================================================================
#				CONTROL DE ERRORES
#======================================================================================
error1: la 	$a0, string4		# --- "Error: Introduce un valor entre 1 y 99"
	li	$v0, 4
	syscall
	
	la  	$t2, r			# Display Er
	lb  	$t2, 0($t2)
	sb 	$t2, 0($s0)
	la  	$t2, e
	lb  	$t2, 0($t2)
	sb 	$t2, 0($s1)
	j vector
	
error2: la 	$a0, string5		# --- "Error: Introduce un valor entre 0 y 99"
	li	$v0, 4
	syscall
	subi	$t0, $t0, 1 		# cont--
	
	la  	$t2, r			# Display Er
	lb  	$t2, 0($t2)
	sb 	$t2, 0($s0)
	la  	$t2, e
	lb  	$t2, 0($t2)
	sb 	$t2, 0($s1)
	j ask
	
error3: la 	$a0, string9		# --- "Error: Introduce un valor entre 0 y 99"
	li	$v0, 4
	syscall
	subi	$t0, $t0, 1 		# cont--
	
	la  	$t2, r			# Display Er
	lb  	$t2, 0($t2)
	sb 	$t2, 0($s0)
	la  	$t2, e
	lb  	$t2, 0($t2)
	sb 	$t2, 0($s1)
	j end
	
