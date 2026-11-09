# t3_ctrl.asm - Tabla 3: filas beq/bne, j, jal/jr, syscall.
# Instrucciones: beq bne j jal jr syscall (servicios 11 y 10) addi sll add lw sw.
# Casos: beq y bne tomados y no tomados; salto hacia atras (bucle); j; un
#   procedimiento que llama a otro (no hoja) guardando $ra en la pila y retornando;
#   syscall 11 (imprimir caracter) y syscall 10 (terminar).
        .text
main:
# fila 1: beq/bne tomado y no tomado (cada uno suma un valor distinto)
        li   $t0, 5
        li   $t1, 5
        li   $t2, 6
        li   $s0, 0
        beq  $t0, $t1, b1              # tomado
        addi $s0, $s0, 1
b1:     addi $s0, $s0, 2
        move $a0, $s0                  # 2
        jal  ph
        li   $s0, 0
        beq  $t0, $t2, b2              # no tomado
        addi $s0, $s0, 4
b2:     addi $s0, $s0, 8
        move $a0, $s0                  # 12
        jal  ph
        li   $s0, 0
        bne  $t0, $t2, b3              # tomado
        addi $s0, $s0, 16
b3:     addi $s0, $s0, 32
        move $a0, $s0                  # 32
        jal  ph
        li   $s0, 0
        bne  $t0, $t1, b4              # no tomado
        addi $s0, $s0, 64
b4:     addi $s0, $s0, 128
        move $a0, $s0                  # 192
        jal  ph
# salto hacia atras: suma 1..10
        li   $s0, 0
        li   $t3, 10
loop:   add  $s0, $s0, $t3
        addi $t3, $t3, -1
        bne  $t3, $zero, loop
        move $a0, $s0                  # 55
        jal  ph
        jal  nl
# fila 2: j salta instrucciones
        li   $s0, 7
        j    fwd
        addi $s0, $s0, 1000            # no se ejecuta
fwd:    move $a0, $s0                  # 7
        jal  ph
# jal/jr: f(x)=g(x)+g(x+1) con $ra en la pila (f no es hoja)
        li   $a0, 5
        jal  f                          # g(5)+g(6) = 15+18 = 33
        move $s1, $v0
        move $a0, $s1
        jal  ph
        li   $a0, 20
        jal  f                          # 60+63 = 123
        move $a0, $v0
        jal  ph
        move $a0, $sp                  # la pila debe quedar como al empezar
        jal  ph
        jal  nl
# syscall 11: imprimir "OK" y terminar con syscall 10
        li   $a0, 79
        li   $v0, 11
        syscall
        li   $a0, 75
        li   $v0, 11
        syscall
        jal  nl
        li   $v0, 10
        syscall
f:      addi $sp, $sp, -8
        sw   $ra, 4($sp)
        sw   $a0, 0($sp)
        jal  g
        move $t4, $v0
        lw   $a0, 0($sp)
        addi $a0, $a0, 1
        sw   $t4, 0($sp)
        jal  g
        lw   $t4, 0($sp)
        add  $v0, $v0, $t4
        lw   $ra, 4($sp)
        addi $sp, $sp, 8
        jr   $ra
g:      sll  $t5, $a0, 1                # g(x) = 3x
        add  $v0, $t5, $a0
        jr   $ra
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
