# t1_alu.asm - Tabla 3: filas add/sub, and/or, slt/slti, sll/srl, addi,
#   addiu/addu (li y move), andi/ori, lui y $zero.
# Instrucciones: add sub and or slt slti sll srl addi andi ori lui addu addiu
#   (via li/move) syscall 11 y 10.
# Casos: add/sub con positivos y negativos; and/or con unos en los 16 bits altos;
#   slt/slti con resultado 1 y 0 y con negativo (signo != sin signo); sll/srl con
#   shamt 0 y !=0 y srl sobre negativo; addi con inmediato negativo; li entre
#   -2^15 y 2^15-1 y move; andi/ori con bit15=1; lui con bit15=1; escritura en $zero.
        .text
main:
# fila 1: add/sub
        li   $s0, 100
        li   $s1, 23
        li   $s2, -50
        add  $a0, $s0, $s1            # 123
        jal  ph
        add  $a0, $s0, $s2            # 50 (operando negativo)
        jal  ph
        sub  $a0, $s0, $s1            # 77
        jal  ph
        sub  $a0, $s1, $s0            # -77
        jal  ph
        sub  $a0, $s0, $s2            # 150 (resta de negativo)
        jal  ph
        jal  nl
# fila 2: and/or con 16 bits altos y slt
        lui  $s3, 0xF0F0
        ori  $s3, $s3, 0x0FF0          # 0xF0F00FF0
        lui  $s4, 0x0FFF
        ori  $s4, $s4, 0xFF00          # 0x0FFFFF00
        and  $a0, $s3, $s4
        jal  ph
        or   $a0, $s3, $s4
        jal  ph
        li   $t2, -1
        li   $t3, 1
        slt  $a0, $t2, $t3            # -1 < 1  -> 1 (sin signo: 0)
        jal  ph
        slt  $a0, $t3, $t2            # 1 < -1  -> 0
        jal  ph
        li   $t4, -5
        li   $t5, -3
        slt  $a0, $t4, $t5            # -5 < -3 -> 1
        jal  ph
        jal  nl
# fila 3: slti y desplazamientos con shamt 0 y !=0
        slti $a0, $t2, 1               # -1 < 1 -> 1
        jal  ph
        slti $a0, $s0, -1              # 100 < -1 -> 0
        jal  ph
        lui  $s5, 0xF234
        ori  $s5, $s5, 0xABCD          # 0xF234ABCD (negativo)
        sll  $a0, $s5, 0
        jal  ph
        sll  $a0, $s5, 5
        jal  ph
        srl  $a0, $s5, 0
        jal  ph
        jal  nl
# fila 4: srl de negativo, addi negativo, li y move
        srl  $a0, $s5, 8                # entran ceros
        jal  ph
        srl  $a0, $s5, 31
        jal  ph
        addi $a0, $s0, -1000           # 100-1000 = -900
        jal  ph
        li   $a0, 32767
        jal  ph
        li   $a0, -32768
        jal  ph
        jal  nl
# fila 5: move, andi/ori con bit15=1, lui con bit15=1, $zero
        move $a0, $s5
        jal  ph
        andi $a0, $s5, 0x8F0F          # extension con ceros
        jal  ph
        ori  $a0, $zero, 0x8001        # 0x00008001, no 0xFFFF8001
        jal  ph
        lui  $a0, 0x8001
        jal  ph
        addi $zero, $zero, 5            # no debe tener efecto
        add  $a0, $zero, $zero
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
