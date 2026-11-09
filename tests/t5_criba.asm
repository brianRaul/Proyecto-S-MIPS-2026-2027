# t5_criba.asm - Criba de Eratostenes sobre un arreglo de BYTES (primos < 64).
# Instrucciones: sb lbu lw slt slti add addi or sll beq bne j jal jr la li syscall.
# Casos: sb/lbu en muchas posiciones d[1:0] distintas; lw sobre bytes escritos con
#   sb; bucles anidados con saltos hacia atras. Imprime: cantidad de primos, su suma,
#   mapa de bits de los primos (palabra baja y alta) y 2 palabras leidas con lw.
        .data
flags:  .space 64
        .text
main:
        la   $s0, flags
        li   $t0, 1
        li   $t1, 0
init:   add  $t2, $s0, $t1
        sb   $t0, 0($t2)
        addi $t1, $t1, 1
        slti $t3, $t1, 64
        bne  $t3, $zero, init
        sb   $zero, 0($s0)
        sb   $zero, 1($s0)
        li   $s1, 2
sv:     add  $t2, $s0, $s1
        lbu  $t3, 0($t2)
        beq  $t3, $zero, snext
        add  $t4, $s1, $s1
inner:  slti $t5, $t4, 64
        beq  $t5, $zero, snext
        add  $t6, $s0, $t4
        sb   $zero, 0($t6)
        add  $t4, $t4, $s1
        j    inner
snext:  addi $s1, $s1, 1
        slti $t5, $s1, 8
        bne  $t5, $zero, sv
        li   $s2, 0
        li   $s3, 0
        li   $t1, 0
cs:     add  $t2, $s0, $t1
        lbu  $t3, 0($t2)
        beq  $t3, $zero, csn
        addi $s2, $s2, 1
        add  $s3, $s3, $t1
csn:    addi $t1, $t1, 1
        slti $t5, $t1, 64
        bne  $t5, $zero, cs
        li   $s4, 0
        li   $t1, 31
blo:    sll  $s4, $s4, 1
        add  $t2, $s0, $t1
        lbu  $t3, 0($t2)
        or   $s4, $s4, $t3
        addi $t1, $t1, -1
        slt  $t5, $t1, $zero
        beq  $t5, $zero, blo
        li   $s5, 0
        li   $t1, 63
bhi:    sll  $s5, $s5, 1
        add  $t2, $s0, $t1
        lbu  $t3, 0($t2)
        or   $s5, $s5, $t3
        addi $t1, $t1, -1
        slti $t5, $t1, 32
        beq  $t5, $zero, bhi
        move $a0, $s2
        jal  ph
        move $a0, $s3
        jal  ph
        move $a0, $s4
        jal  ph
        move $a0, $s5
        jal  ph
        lw   $a0, 4($s0)
        jal  ph
        jal  nl
        lw   $a0, 28($s0)
        jal  ph
        lw   $a0, 60($s0)
        jal  ph
        jal  nl
        li   $v0, 10
        syscall
# ---------- utilidades ----------
# ph: imprime $a0 en 8 digitos hex y un espacio. Solo toca $k0,$k1,$v0,$v1,$fp
# y deja $a0 intacto (los tests no usan esos registros).
ph:     move $fp, $a0
        move $k0, $a0
        li   $k1, 8
phl:    srl  $a0, $k0, 28
        slti $v1, $a0, 10
        bne  $v1, $zero, phd
        addi $a0, $a0, 87
        j    pho
phd:    addi $a0, $a0, 48
pho:    li   $v0, 11
        syscall
        sll  $k0, $k0, 4
        addi $k1, $k1, -1
        bne  $k1, $zero, phl
        li   $a0, 32
        li   $v0, 11
        syscall
        move $a0, $fp
        jr   $ra
# nl: salto de linea (solo toca $v0,$v1; conserva $a0)
nl:     move $v1, $a0
        li   $a0, 10
        li   $v0, 11
        syscall
        move $a0, $v1
        jr   $ra
