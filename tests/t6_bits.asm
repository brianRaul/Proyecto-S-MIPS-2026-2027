# t6_bits.asm - Collatz, MCD por restas, popcount e inversion de bits.
# Instrucciones: add sub and andi or sll srl slt slti addi lui ori beq bne j jal jr
#   li move syscall. Casos: srl/sll con shamt 1 en bucles largos; andi con 1; slt con
#   valores grandes positivos; saltos hacia atras anidados; ori/lui para constantes de 32 bits.
# Imprime: pasos de Collatz(27), maximo alcanzado, MCD(1071,462), popcount y bit-reverse.
        .text
main:
        li   $s0, 27
        li   $s1, 0
        move $s2, $s0
cl:     li   $t0, 1
        beq  $s0, $t0, cdone
        andi $t1, $s0, 1
        beq  $t1, $zero, ceven
        sll  $t2, $s0, 1
        add  $s0, $s0, $t2
        addi $s0, $s0, 1
        j    cmax
ceven:  srl  $s0, $s0, 1
cmax:   slt  $t3, $s2, $s0
        beq  $t3, $zero, cstep
        move $s2, $s0
cstep:  addi $s1, $s1, 1
        j    cl
cdone:  li   $s3, 1071
        li   $s4, 462
g:      beq  $s3, $s4, gd
        slt  $t0, $s3, $s4
        bne  $t0, $zero, gless
        sub  $s3, $s3, $s4
        j    g
gless:  sub  $s4, $s4, $s3
        j    g
gd:     lui  $t0, 0xF0F0
        ori  $t0, $t0, 0xA5C3
        li   $s5, 0
pc:     beq  $t0, $zero, pcd
        andi $t1, $t0, 1
        add  $s5, $s5, $t1
        srl  $t0, $t0, 1
        j    pc
pcd:    lui  $t0, 0x1234
        ori  $t0, $t0, 0x5678
        li   $s6, 0
        li   $t2, 32
rv:     sll  $s6, $s6, 1
        andi $t1, $t0, 1
        or   $s6, $s6, $t1
        srl  $t0, $t0, 1
        addi $t2, $t2, -1
        bne  $t2, $zero, rv
        move $a0, $s1
        jal  ph
        move $a0, $s2
        jal  ph
        move $a0, $s3
        jal  ph
        move $a0, $s5
        jal  ph
        move $a0, $s6
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
