# t7_matriz.asm - Producto de matrices 3x3 con multiplicacion por suma y desplazamiento.
# Instrucciones: lw sw add addi sll srl andi slti beq bne j jal jr la li syscall.
# Casos: direccionamiento calculado (3i+k)*4, tres bucles anidados con saltos atras,
#   subrutina hoja llamada 27 veces, sw/lw en 9 posiciones distintas.
# Imprime C=A*B (9 palabras) y su traza.
        .data
ma:     .word 1, 2, 3, 4, 5, 6, 7, 8, 9
mb:     .word 9, 8, 7, 6, 5, 4, 3, 2, 1
mc:     .space 36
        .text
main:
        li   $s0, 0
rowl:   li   $s1, 0
coll:   li   $s2, 0
        li   $s3, 0
kl:     sll  $t1, $s0, 1
        add  $t1, $t1, $s0
        add  $t1, $t1, $s2
        sll  $t1, $t1, 2
        la   $t2, ma
        add  $t1, $t1, $t2
        lw   $a0, 0($t1)
        sll  $t3, $s2, 1
        add  $t3, $t3, $s2
        add  $t3, $t3, $s1
        sll  $t3, $t3, 2
        la   $t2, mb
        add  $t3, $t3, $t2
        lw   $a1, 0($t3)
        jal  mulsa
        add  $s3, $s3, $v0
        addi $s2, $s2, 1
        slti $t4, $s2, 3
        bne  $t4, $zero, kl
        sll  $t1, $s0, 1
        add  $t1, $t1, $s0
        add  $t1, $t1, $s1
        sll  $t1, $t1, 2
        la   $t2, mc
        add  $t1, $t1, $t2
        sw   $s3, 0($t1)
        addi $s1, $s1, 1
        slti $t4, $s1, 3
        bne  $t4, $zero, coll
        addi $s0, $s0, 1
        slti $t4, $s0, 3
        bne  $t4, $zero, rowl
        la   $s4, mc
        lw   $a0, 0($s4)
        jal  ph
        lw   $a0, 4($s4)
        jal  ph
        lw   $a0, 8($s4)
        jal  ph
        lw   $a0, 12($s4)
        jal  ph
        lw   $a0, 16($s4)
        jal  ph
        jal  nl
        lw   $a0, 20($s4)
        jal  ph
        lw   $a0, 24($s4)
        jal  ph
        lw   $a0, 28($s4)
        jal  ph
        lw   $a0, 32($s4)
        jal  ph
        lw   $t0, 0($s4)
        lw   $t1, 16($s4)
        add  $t0, $t0, $t1
        lw   $t1, 32($s4)
        add  $a0, $t0, $t1
        jal  ph
        jal  nl
        li   $v0, 10
        syscall
# mulsa: $v0 = $a0 * $a1 (positivos)
mulsa:  li   $v0, 0
mloop:  beq  $a1, $zero, mdone
        andi $t0, $a1, 1
        beq  $t0, $zero, mskip
        add  $v0, $v0, $a0
mskip:  sll  $a0, $a0, 1
        srl  $a1, $a1, 1
        j    mloop
mdone:  jr   $ra
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
