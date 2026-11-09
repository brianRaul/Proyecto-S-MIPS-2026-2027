# ==========================================================================
# stress.asm - PRUEBA DE ESTRES DE LA CPU S-MIPS (autoverificable)
# Instrucciones: add sub and or slt sll srl addi slti andi ori lui lw sw lb lbu
#   sb beq bne j jal jr syscall(10,11), addu/addiu (move, li), $zero.
# Casos tabla 3: add/sub con negativos; and/or con 16 bits altos; slt/slti con
#   signo vs sin signo; sll/srl con shamt 0..31 y srl sobre negativo; addi
#   negativo; li/move; andi/ori con bit15=1; lui con bit15=1; lw/sw con
#   desplazamiento + y -; lb/lbu en varias posiciones; sb en los 4 carriles;
#   beq/bne tomado y no tomado, saltos atras; j; jal/jr con pila (recursion);
#   jr a direccion calculada; escritura en $zero; los 31 registros.
# Salida: 25 palabras hex, producto en hex+decimal, cadena invertida, PASS/FAIL.
# ==========================================================================
        .data
scratch: .space 128
saved:   .space 16
col:     .word 0
fails:   .word 0
buf:     .word 0x11223344
arr:     .word 5, -3, 0x12345678, 0x80000000, 0, 77, -1, 0x7fffffff
str:     .asciiz "S-MIPS rocks!"
         .align 2
btab:    .byte 127, -128, -1, 1, 2, -23, 16, -112
         .align 2
pot:     .word 1000000000, 100000000, 10000000, 1000000, 100000, 10000, 1000, 100, 10, 1
jtab:    .word h0, h1, h2
        .text
main:
# ---- A: valores iniciales de $gp/$sp y prueba de los 31 registros ----
        move $a0, $gp
        jal  pw
        move $a0, $sp
        jal  pw
        sw   $gp, 8320($zero)
        sw   $sp, 8324($zero)
        sw   $ra, 8328($zero)
        addi $8, $zero, 85
        sw   $8, 8192($zero)          # centinela en la ranura 0
        addi $1, $zero, 8196
        addi $2, $zero, 8200
        addi $3, $zero, 8204
        addi $4, $zero, 8208
        addi $5, $zero, 8212
        addi $6, $zero, 8216
        addi $7, $zero, 8220
        addi $8, $zero, 8224
        addi $9, $zero, 8228
        addi $10, $zero, 8232
        addi $11, $zero, 8236
        addi $12, $zero, 8240
        addi $13, $zero, 8244
        addi $14, $zero, 8248
        addi $15, $zero, 8252
        addi $16, $zero, 8256
        addi $17, $zero, 8260
        addi $18, $zero, 8264
        addi $19, $zero, 8268
        addi $20, $zero, 8272
        addi $21, $zero, 8276
        addi $22, $zero, 8280
        addi $23, $zero, 8284
        addi $24, $zero, 8288
        addi $25, $zero, 8292
        addi $26, $zero, 8296
        addi $27, $zero, 8300
        addi $28, $zero, 8304
        addi $29, $zero, 8308
        addi $30, $zero, 8312
        addi $31, $zero, 8316
        addi $0, $zero, 99            # escribir en $zero no debe tener efecto
        sw   $0, 8192($zero)          # debe quedar 0
        sw   $1, 0($1)            # usa el registro como base Y como dato
        sw   $2, 0($2)            # usa el registro como base Y como dato
        sw   $3, 0($3)            # usa el registro como base Y como dato
        sw   $4, 0($4)            # usa el registro como base Y como dato
        sw   $5, 0($5)            # usa el registro como base Y como dato
        sw   $6, 0($6)            # usa el registro como base Y como dato
        sw   $7, 0($7)            # usa el registro como base Y como dato
        sw   $8, 0($8)            # usa el registro como base Y como dato
        sw   $9, 0($9)            # usa el registro como base Y como dato
        sw   $10, 0($10)            # usa el registro como base Y como dato
        sw   $11, 0($11)            # usa el registro como base Y como dato
        sw   $12, 0($12)            # usa el registro como base Y como dato
        sw   $13, 0($13)            # usa el registro como base Y como dato
        sw   $14, 0($14)            # usa el registro como base Y como dato
        sw   $15, 0($15)            # usa el registro como base Y como dato
        sw   $16, 0($16)            # usa el registro como base Y como dato
        sw   $17, 0($17)            # usa el registro como base Y como dato
        sw   $18, 0($18)            # usa el registro como base Y como dato
        sw   $19, 0($19)            # usa el registro como base Y como dato
        sw   $20, 0($20)            # usa el registro como base Y como dato
        sw   $21, 0($21)            # usa el registro como base Y como dato
        sw   $22, 0($22)            # usa el registro como base Y como dato
        sw   $23, 0($23)            # usa el registro como base Y como dato
        sw   $24, 0($24)            # usa el registro como base Y como dato
        sw   $25, 0($25)            # usa el registro como base Y como dato
        sw   $26, 0($26)            # usa el registro como base Y como dato
        sw   $27, 0($27)            # usa el registro como base Y como dato
        sw   $28, 0($28)            # usa el registro como base Y como dato
        sw   $29, 0($29)            # usa el registro como base Y como dato
        sw   $30, 0($30)            # usa el registro como base Y como dato
        sw   $31, 0($31)            # usa el registro como base Y como dato
        lw   $gp, 8320($zero)
        lw   $sp, 8324($zero)
        lw   $ra, 8328($zero)
        li   $s0, 0
        li   $s1, 0
        li   $t0, 8196
        li   $t1, 8320
chkA:   lw   $t2, 0($t0)
        add  $s1, $s1, $t2
        beq  $t2, $t0, okA
        addi $s0, $s0, 1
okA:    addi $t0, $t0, 4
        bne  $t0, $t1, chkA
        lw   $s2, 8192($zero)
        move $a0, $s0
        jal  pw
        move $a0, $s0
        li   $a1, 0
        jal  chk
        move $a0, $s1
        jal  pw
        move $a0, $s1
        li   $a1, 255936              # suma de 0x2000+4i, i=1..31
        jal  chk
        move $a0, $s2
        jal  pw
        move $a0, $s2
        li   $a1, 0
        jal  chk
# ---- B: hash de todos los desplazamientos 0..31 (sll y srl) ----
        lui  $s2, 0xA5C3
        ori  $s2, $s2, 0xF00F         # x = 0xA5C3F00F (negativo)
        li   $s3, 0x1234              # hash
        sll  $a1, $s2, 0
        jal  mix
        srl  $a1, $s2, 0
        jal  mix
        sll  $a1, $s2, 1
        jal  mix
        srl  $a1, $s2, 1
        jal  mix
        sll  $a1, $s2, 2
        jal  mix
        srl  $a1, $s2, 2
        jal  mix
        sll  $a1, $s2, 3
        jal  mix
        srl  $a1, $s2, 3
        jal  mix
        sll  $a1, $s2, 4
        jal  mix
        srl  $a1, $s2, 4
        jal  mix
        sll  $a1, $s2, 5
        jal  mix
        srl  $a1, $s2, 5
        jal  mix
        sll  $a1, $s2, 6
        jal  mix
        srl  $a1, $s2, 6
        jal  mix
        sll  $a1, $s2, 7
        jal  mix
        srl  $a1, $s2, 7
        jal  mix
        sll  $a1, $s2, 8
        jal  mix
        srl  $a1, $s2, 8
        jal  mix
        sll  $a1, $s2, 9
        jal  mix
        srl  $a1, $s2, 9
        jal  mix
        sll  $a1, $s2, 10
        jal  mix
        srl  $a1, $s2, 10
        jal  mix
        sll  $a1, $s2, 11
        jal  mix
        srl  $a1, $s2, 11
        jal  mix
        sll  $a1, $s2, 12
        jal  mix
        srl  $a1, $s2, 12
        jal  mix
        sll  $a1, $s2, 13
        jal  mix
        srl  $a1, $s2, 13
        jal  mix
        sll  $a1, $s2, 14
        jal  mix
        srl  $a1, $s2, 14
        jal  mix
        sll  $a1, $s2, 15
        jal  mix
        srl  $a1, $s2, 15
        jal  mix
        sll  $a1, $s2, 16
        jal  mix
        srl  $a1, $s2, 16
        jal  mix
        sll  $a1, $s2, 17
        jal  mix
        srl  $a1, $s2, 17
        jal  mix
        sll  $a1, $s2, 18
        jal  mix
        srl  $a1, $s2, 18
        jal  mix
        sll  $a1, $s2, 19
        jal  mix
        srl  $a1, $s2, 19
        jal  mix
        sll  $a1, $s2, 20
        jal  mix
        srl  $a1, $s2, 20
        jal  mix
        sll  $a1, $s2, 21
        jal  mix
        srl  $a1, $s2, 21
        jal  mix
        sll  $a1, $s2, 22
        jal  mix
        srl  $a1, $s2, 22
        jal  mix
        sll  $a1, $s2, 23
        jal  mix
        srl  $a1, $s2, 23
        jal  mix
        sll  $a1, $s2, 24
        jal  mix
        srl  $a1, $s2, 24
        jal  mix
        sll  $a1, $s2, 25
        jal  mix
        srl  $a1, $s2, 25
        jal  mix
        sll  $a1, $s2, 26
        jal  mix
        srl  $a1, $s2, 26
        jal  mix
        sll  $a1, $s2, 27
        jal  mix
        srl  $a1, $s2, 27
        jal  mix
        sll  $a1, $s2, 28
        jal  mix
        srl  $a1, $s2, 28
        jal  mix
        sll  $a1, $s2, 29
        jal  mix
        srl  $a1, $s2, 29
        jal  mix
        sll  $a1, $s2, 30
        jal  mix
        srl  $a1, $s2, 30
        jal  mix
        sll  $a1, $s2, 31
        jal  mix
        srl  $a1, $s2, 31
        jal  mix
        lui  $t0, 0x8765
        ori  $t0, $t0, 0xCAFE         # 0x8765CAFE
        andi $a1, $t0, 0xF0F0         # andi con bit15=1 -> 0xC0F0
        jal  mix
        srl  $s4, $s2, 4              # srl de negativo: entran ceros
        sll  $s5, $s2, 16
        lui  $t0, 0x8765
        ori  $s7, $t0, 0xCAFE
        li   $t0, -1
        li   $t1, 1
        slt  $t2, $t0, $t1            # -1 < 1  -> 1 (sin signo daria 0)
        slt  $t3, $t1, $t0            # 1 < -1  -> 0
        sll  $t3, $t3, 1
        or   $t2, $t2, $t3
        lui  $t4, 0x8000
        lui  $t5, 0x7fff
        ori  $t5, $t5, 0xffff
        slt  $t6, $t4, $t5            # minint < maxint -> 1
        sll  $t6, $t6, 2
        or   $t2, $t2, $t6
        slt  $t6, $t5, $t4            # maxint < minint -> 0
        sll  $t6, $t6, 3
        or   $t2, $t2, $t6
        slti $t6, $t0, -3             # -1 < -3 -> 0
        sll  $t6, $t6, 4
        or   $t2, $t2, $t6
        slti $t6, $t4, -3             # minint < -3 -> 1
        sll  $t6, $t6, 5
        or   $t2, $t2, $t6
        slti $t6, $t1, 2              # 1 < 2 -> 1
        sll  $t6, $t6, 6
        or   $s6, $t2, $t6
        move $a0, $s3
        jal  pw
        move $a0, $s3
        li   $a1, 2665713580
        jal  chk
        move $a0, $s4
        jal  pw
        move $a0, $s5
        jal  pw
        move $a0, $s6
        jal  pw
        move $a0, $s7
        jal  pw
# ---- C: burbuja con enteros con signo (offsets + y -) ----
        la   $s0, arr
        li   $s1, 8
outer:  addi $s1, $s1, -1
        beq  $s1, $zero, sorted
        move $t4, $s1
        addi $t2, $s0, 4
inner:  lw   $t0, -4($t2)
        lw   $t1, 0($t2)
        slt  $t3, $t1, $t0
        beq  $t3, $zero, noswap
        sw   $t1, -4($t2)
        sw   $t0, 0($t2)
noswap: addi $t2, $t2, 4
        addi $t4, $t4, -1
        bne  $t4, $zero, inner
        j    outer
sorted: la   $s0, arr
        li   $s1, 8
pls:    lw   $a0, 0($s0)
        jal  pw
        lw   $t0, 0($s0)
        lw   $t1, 4($s0)
        slt  $a0, $t1, $t0            # siguiente < actual -> desordenado
        li   $a1, 0
        li   $t2, 1
        beq  $s1, $t2, plsend         # el ultimo no tiene siguiente
        jal  chk
plsend: addi $s0, $s0, 4
        addi $s1, $s1, -1
        bne  $s1, $zero, pls
# ---- D: despacho por tabla con jr a direccion calculada ----
        li   $s4, 1
        li   $s5, 0
        la   $s6, jtab
disp:   move $t0, $s5
mod3:   slti $t1, $t0, 3
        bne  $t1, $zero, gotm
        addi $t0, $t0, -3
        j    mod3
gotm:   sll  $t0, $t0, 2
        add  $t0, $t0, $s6
        lw   $t0, 0($t0)
        jr   $t0
h0:     addi $s4, $s4, 7
        j    dnext
h1:     sll  $s4, $s4, 1
        j    dnext
h2:     addi $s4, $s4, -2
dnext:  addi $s5, $s5, 1
        slti $t0, $s5, 9
        bne  $t0, $zero, disp
        move $a0, $s4
        jal  pw
        move $a0, $s4
        li   $a1, 92
        jal  chk
# ---- E: sb en los 4 carriles (los demas bytes no deben cambiar) ----
        la   $s0, buf
        li   $t1, 0xAB
        sb   $t1, 2($s0)
        lw   $s1, 0($s0)
        li   $t1, 0xCD
        sb   $t1, 0($s0)
        li   $t1, 0xEF
        sb   $t1, 1($s0)
        li   $t1, 0x99
        sb   $t1, 3($s0)
        lw   $s2, 0($s0)
        move $a0, $s1
        jal  pw
        move $a0, $s1
        li   $a1, 0x11AB3344
        jal  chk
        move $a0, $s2
        jal  pw
        move $a0, $s2
        lui  $a1, 0x99AB
        ori  $a1, $a1, 0xEFCD
        jal  chk
# ---- F: lb (con signo) y lbu (sin signo) en 8 posiciones ----
        la   $t0, btab
        li   $t1, 8
        li   $s5, 0
        li   $s6, 0
bsum:   lb   $t2, 0($t0)
        add  $s5, $s5, $t2
        lbu  $t3, 0($t0)
        add  $s6, $s6, $t3
        addi $t0, $t0, 1
        addi $t1, $t1, -1
        bne  $t1, $zero, bsum
        move $a0, $s5
        jal  pw
        move $a0, $s5
        li   $a1, -118
        jal  chk
        move $a0, $s6
        jal  pw
        move $a0, $s6
        li   $a1, 906
        jal  chk
# ---- G: recursion (fib no hoja y Ackermann) con pila ----
        li   $a0, 9
        jal  fib
        move $s0, $v0
        move $a0, $s0
        jal  pw
        move $a0, $s0
        li   $a1, 34
        jal  chk
        li   $a0, 2
        li   $a1, 3
        jal  ack
        move $s0, $v0
        move $a0, $s0
        jal  pw
        move $a0, $s0
        li   $a1, 9
        jal  chk
# ---- H: producto por suma y desplazamiento, en hex y decimal ----
        li   $a0, 0xBEEF
        li   $a1, 0x1234
        jal  mulsa
        move $s0, $v0
        move $a0, $s0
        jal  pw
        move $a0, $s0
        jal  pdec
        jal  flush
        move $a0, $s0
        li   $a1, 227776140
        jal  chk
# ---- I: cadena en mayusculas e invertida (lbu/sb en todos los carriles) ----
        la   $s0, str
up:     lbu  $t0, 0($s0)
        beq  $t0, $zero, updone
        slti $t1, $t0, 97
        bne  $t1, $zero, upnext
        slti $t1, $t0, 123
        beq  $t1, $zero, upnext
        andi $t0, $t0, 0xDF
        sb   $t0, 0($s0)
upnext: addi $s0, $s0, 1
        j    up
updone: la   $s2, str
        addi $s1, $s0, -1
rev:    slt  $t0, $s2, $s1
        beq  $t0, $zero, revdone
        lbu  $t1, 0($s2)
        lbu  $t2, 0($s1)
        sb   $t2, 0($s2)
        sb   $t1, 0($s1)
        addi $s2, $s2, 1
        addi $s1, $s1, -1
        j    rev
revdone: la  $s0, str
prs:    lbu  $a0, 0($s0)
        beq  $a0, $zero, prsdone
        li   $v0, 11
        syscall
        addi $s0, $s0, 1
        j    prs
prsdone: li  $a0, 10
        li   $v0, 11
        syscall
# ---- veredicto ----
        la   $t0, fails
        lw   $s0, 0($t0)
        bne  $s0, $zero, bad
        li   $a0, 80
        li   $v0, 11
        syscall
        li   $a0, 65
        li   $v0, 11
        syscall
        li   $a0, 83
        li   $v0, 11
        syscall
        li   $a0, 83
        li   $v0, 11
        syscall
        j    fin
bad:    li   $a0, 70
        li   $v0, 11
        syscall
        li   $a0, 65
        li   $v0, 11
        syscall
        li   $a0, 73
        li   $v0, 11
        syscall
        li   $a0, 76
        li   $v0, 11
        syscall
        li   $a0, 32
        li   $v0, 11
        syscall
        move $a0, $s0
        jal  pw
fin:    jal  flush
        li   $v0, 10
        syscall
# =========================== subrutinas ===========================
# pw: imprime $a0 en 8 digitos hex + espacio; salta de linea cada 5 palabras
pw:     addi $sp, $sp, -8
        sw   $ra, 4($sp)
        sw   $s0, 0($sp)
        move $s0, $a0
        li   $t2, 8
pwl:    srl  $t0, $s0, 28
        slti $t3, $t0, 10
        bne  $t3, $zero, pwd
        addi $t0, $t0, 87
        j    pwo
pwd:    addi $t0, $t0, 48
pwo:    move $a0, $t0
        li   $v0, 11
        syscall
        sll  $s0, $s0, 4
        addi $t2, $t2, -1
        bne  $t2, $zero, pwl
        li   $a0, 32
        li   $v0, 11
        syscall
        la   $t0, col
        lw   $t1, 0($t0)
        addi $t1, $t1, 1
        slti $t2, $t1, 5
        bne  $t2, $zero, pws
        li   $a0, 10
        li   $v0, 11
        syscall
        li   $t1, 0
pws:    sw   $t1, 0($t0)
        lw   $s0, 0($sp)
        lw   $ra, 4($sp)
        addi $sp, $sp, 8
        jr   $ra
# flush: newline solo si la linea actual no esta vacia
flush:  la   $t0, col
        lw   $t1, 0($t0)
        beq  $t1, $zero, fl_end
        li   $a0, 10
        li   $v0, 11
        syscall
        sw   $zero, 0($t0)
fl_end: jr   $ra
# chk: si $a0 != $a1, fails++
chk:    beq  $a0, $a1, chkok
        la   $t0, fails
        lw   $t1, 0($t0)
        addi $t1, $t1, 1
        sw   $t1, 0($t0)
chkok:  jr   $ra
# mix: $s3 = rol($s3,5) xor $a1   (xor = (a|b)-(a&b), sin overflow)
mix:    sll  $t0, $s3, 5
        srl  $t1, $s3, 27
        or   $t0, $t0, $t1
        or   $t2, $t0, $a1
        and  $t3, $t0, $a1
        sub  $s3, $t2, $t3
        jr   $ra
# fib recursivo (no hoja)
fib:    addi $sp, $sp, -12
        sw   $ra, 8($sp)
        sw   $s0, 4($sp)
        sw   $s1, 0($sp)
        move $s0, $a0
        slti $t0, $a0, 2
        beq  $t0, $zero, frec
        move $v0, $a0
        j    fret
frec:   addi $a0, $s0, -1
        jal  fib
        move $s1, $v0
        addi $a0, $s0, -2
        jal  fib
        add  $v0, $v0, $s1
fret:   lw   $s1, 0($sp)
        lw   $s0, 4($sp)
        lw   $ra, 8($sp)
        addi $sp, $sp, 12
        jr   $ra
# Ackermann(m=$a0, n=$a1)
ack:    addi $sp, $sp, -8
        sw   $ra, 4($sp)
        sw   $a0, 0($sp)
        beq  $a0, $zero, ackm0
        beq  $a1, $zero, ackn0
        addi $a1, $a1, -1
        jal  ack
        move $a1, $v0
        lw   $a0, 0($sp)
        addi $a0, $a0, -1
        jal  ack
        j    ackret
ackm0:  addi $v0, $a1, 1
        j    ackret
ackn0:  addi $a0, $a0, -1
        li   $a1, 1
        jal  ack
ackret: lw   $ra, 4($sp)
        addi $sp, $sp, 8
        jr   $ra
# mulsa: $v0 = $a0 * $a1 por suma y desplazamiento (positivos, producto < 2^31)
mulsa:  li   $v0, 0
mloop:  beq  $a1, $zero, mdone
        andi $t0, $a1, 1
        beq  $t0, $zero, mskip
        add  $v0, $v0, $a0
mskip:  sll  $a0, $a0, 1
        srl  $a1, $a1, 1
        j    mloop
mdone:  jr   $ra
# pdec: imprime $a0 (>=0) en 10 digitos decimales restando potencias de 10
pdec:   addi $sp, $sp, -12
        sw   $ra, 8($sp)
        sw   $s0, 4($sp)
        sw   $s1, 0($sp)
        move $s0, $a0
        la   $s1, pot
        li   $t4, 10
pdl:    lw   $t0, 0($s1)
        li   $t1, 0
pdsub:  slt  $t2, $s0, $t0
        bne  $t2, $zero, pdout
        sub  $s0, $s0, $t0
        addi $t1, $t1, 1
        j    pdsub
pdout:  addi $a0, $t1, 48
        li   $v0, 11
        syscall
        addi $s1, $s1, 4
        addi $t4, $t4, -1
        bne  $t4, $zero, pdl
        lw   $s1, 0($sp)
        lw   $s0, 4($sp)
        lw   $ra, 8($sp)
        addi $sp, $sp, 12
        jr   $ra
