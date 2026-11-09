# t2_mem.asm - Tabla 3: filas lw/sw, lb/lbu y sb.
# Instrucciones: lw sw lb lbu sb (y lui ori li la move addi para preparar).
# Casos: lw/sw con desplazamiento positivo y con negativo; lb y lbu sobre bytes
#   con bit7=1 en las 4 posiciones d[1:0]=0..3 de una palabra; sb en las 4
#   posiciones de una misma palabra comprobando con lw que los otros bytes no cambian.
        .data
w:      .word 0x11223344, 0x80FF7F01, 0, 0
        .text
main:
        la   $s0, w
# fila 1: lw/sw con offset + y -
        lw   $a0, 4($s0)               # 0x80FF7F01
        jal  ph
        sw   $a0, 8($s0)               # offset positivo
        lw   $a0, 8($s0)
        jal  ph
        addi $s1, $s0, 8
        lw   $a0, -8($s1)              # offset negativo: palabra 0
        jal  ph
        sw   $a0, -4($s1)              # palabra 1 <- palabra 0
        lw   $a0, 4($s0)
        jal  ph
        lui  $t0, 0x80FF
        ori  $t0, $t0, 0x7F01
        sw   $t0, 4($s0)               # restaurar
        lw   $a0, 4($s0)
        jal  ph
        jal  nl
# fila 2: lb y lbu en las 4 posiciones de 0x80FF7F01 (bytes 01 7F FF 80)
        lb   $a0, 4($s0)               # 1
        jal  ph
        lb   $a0, 5($s0)               # 0x7F
        jal  ph
        lb   $a0, 6($s0)               # 0xFFFFFFFF
        jal  ph
        lb   $a0, 7($s0)               # 0xFFFFFF80
        jal  ph
        lbu  $a0, 7($s0)               # 0x80
        jal  ph
        jal  nl
        lbu  $a0, 6($s0)               # 0xFF
        jal  ph
        lbu  $a0, 5($s0)
        jal  ph
        lbu  $a0, 4($s0)
        jal  ph
        lb   $a0, -1($s1)              # offset negativo: byte 3 de la palabra 1
        jal  ph
        lbu  $a0, -1($s1)
        jal  ph
        jal  nl
# fila 3: sb en las 4 posiciones, con lw despues de cada una
        li   $t0, -1
        sw   $t0, 12($s0)              # 0xFFFFFFFF
        li   $t1, 0x11
        sb   $t1, 12($s0)              # posicion 0
        lw   $a0, 12($s0)
        jal  ph
        li   $t1, 0x22
        sb   $t1, 13($s0)              # posicion 1
        lw   $a0, 12($s0)
        jal  ph
        li   $t1, 0x33
        sb   $t1, 14($s0)              # posicion 2
        lw   $a0, 12($s0)
        jal  ph
        li   $t1, 0x44
        sb   $t1, 15($s0)              # posicion 3
        lw   $a0, 12($s0)
        jal  ph
        jal  nl
        sw   $zero, 12($s0)
        li   $t1, 0x1A5                 # solo debe escribirse el byte bajo 0xA5
        sb   $t1, 14($s0)
        lw   $a0, 12($s0)
        jal  ph
        sb   $t1, 13($s0)
        lw   $a0, 12($s0)
        jal  ph
        lw   $a0, 0($s0)               # la palabra vecina no cambia
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
