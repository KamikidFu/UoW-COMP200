.global	counter
counter:
	.word	0x38f75
.global	number_charArray
number_charArray:
	.word	0x30
	.word	0x31
	.word	0x32
	.word	0x33
	.word	0x34
	.word	0x35
	.word	0x36
	.word	0x37
	.word	0x38
	.word	0x39
.global	main
.text
main:
	subui	$sp, $sp, 9
	sw	$3, 0($sp)
	sw	$4, 1($sp)
	sw	$5, 2($sp)
	sw	$6, 3($sp)
	sw	$7, 4($sp)
	sw	$11, 5($sp)
	sw	$12, 6($sp)
	sw	$13, 7($sp)
	addui	$13, $0, 1
	sw	$13, 8($sp)
	j	L.3
L.2:
	lhi	$13, 0x7
	ori	$13, $13, 0x1003
	lw	$4, 0($13)
	andi	$13, $4, 1
	seq	$13, $13, $0
	bnez	$13, L.3
	lhi	$13, 0x7
	ori	$13, $13, 0x1001
	lw	$3, 0($13)
L.6:
	snei	$13, $3, 49
	bnez	$13, L.7
	addui	$4, $0, 1
	j	L.16
L.7:
	snei	$13, $3, 50
	bnez	$13, L.9
	addui	$4, $0, 2
	j	L.16
L.9:
	snei	$13, $3, 51
	bnez	$13, L.11
	addui	$4, $0, 3
	j	L.16
L.11:
	snei	$13, $3, 113
	bnez	$13, L.3
	addu	$4, $0, $0
	j	L.16
L.15:
	lhi	$13, 0x7
	ori	$13, $13, 0x1003
	lw	$13, 0($13)
	andi	$13, $13, 2
	seq	$13, $13, $0
	bnez	$13, L.18
	lhi	$13, 0x7
	ori	$13, $13, 0x1000
	addui	$12, $0, 13
	sw	$12, 0($13)
	j	L.21
L.18:
L.16:
	j	L.15
	j	L.21
L.20:
	lhi	$13, 0x7
	ori	$13, $13, 0x1003
	lw	$13, 0($13)
	andi	$13, $13, 2
	seq	$13, $13, $0
	bnez	$13, L.23
	lhi	$13, 0x7
	ori	$13, $13, 0x1000
	addui	$12, $0, 10
	sw	$12, 0($13)
	j	L.22
L.23:
L.21:
	j	L.20
L.22:
	snei	$13, $4, 1
	bnez	$13, L.25
	j	L.28
L.27:
	lhi	$13, 0x7
	ori	$13, $13, 0x1003
	lw	$13, 0($13)
	andi	$13, $13, 2
	seq	$13, $13, $0
	bnez	$13, L.30
	lhi	$13, 0x7
	ori	$13, $13, 0x1000
	addui	$12, $0, 13
	sw	$12, 0($13)
	j	L.29
L.30:
L.28:
	j	L.27
L.29:
	lw	$13, counter($0)
	divi	$13, $13, 100
	addui	$12, $0, 60
	div	$6, $13, $12
	rem	$5, $13, $12
	addui	$7, $0, 10
L.32:
	slt	$13, $6, $7
	bnez	$13, L.36
	j	L.39
L.38:
	lhi	$13, 0x7
	ori	$13, $13, 0x1003
	lw	$13, 0($13)
	andi	$13, $13, 2
	seq	$13, $13, $0
	bnez	$13, L.41
	lhi	$13, 0x7
	ori	$13, $13, 0x1000
	addui	$12, $0, 10
	mult	$12, $12, $7
	rem	$12, $6, $12
	div	$12, $12, $7
	lw	$12, number_charArray($12)
	sw	$12, 0($13)
	j	L.40
L.41:
L.39:
	j	L.38
L.40:
L.36:
L.33:
	divi	$7, $7, 10
	sgt	$13, $7, $0
	bnez	$13, L.32
	j	L.44
L.43:
	lhi	$13, 0x7
	ori	$13, $13, 0x1003
	lw	$13, 0($13)
	andi	$13, $13, 2
	seq	$13, $13, $0
	bnez	$13, L.46
	lhi	$13, 0x7
	ori	$13, $13, 0x1000
	addui	$12, $0, 58
	sw	$12, 0($13)
	j	L.45
L.46:
L.44:
	j	L.43
L.45:
	addui	$7, $0, 10
L.48:
	slt	$13, $5, $7
	bnez	$13, L.52
	j	L.55
L.54:
	lhi	$13, 0x7
	ori	$13, $13, 0x1003
	lw	$13, 0($13)
	andi	$13, $13, 2
	seq	$13, $13, $0
	bnez	$13, L.57
	lhi	$13, 0x7
	ori	$13, $13, 0x1000
	addui	$12, $0, 10
	mult	$12, $12, $7
	rem	$12, $5, $12
	div	$12, $12, $7
	lw	$12, number_charArray($12)
	sw	$12, 0($13)
	j	L.56
L.57:
L.55:
	j	L.54
L.56:
L.52:
L.49:
	divi	$7, $7, 10
	sgt	$13, $7, $0
	bnez	$13, L.48
	j	L.26
L.25:
	snei	$13, $4, 2
	bnez	$13, L.59
	j	L.62
L.61:
	lhi	$13, 0x7
	ori	$13, $13, 0x1003
	lw	$13, 0($13)
	andi	$13, $13, 2
	seq	$13, $13, $0
	bnez	$13, L.64
	lhi	$13, 0x7
	ori	$13, $13, 0x1000
	addui	$12, $0, 13
	sw	$12, 0($13)
	j	L.63
L.64:
L.62:
	j	L.61
L.63:
	lhi	$7, 0x1
	ori	$7, $7, 0x86a0
L.66:
	snei	$13, $7, 10
	bnez	$13, L.70
	j	L.73
L.72:
	lhi	$13, 0x7
	ori	$13, $13, 0x1003
	lw	$13, 0($13)
	andi	$13, $13, 2
	seq	$13, $13, $0
	bnez	$13, L.75
	lhi	$13, 0x7
	ori	$13, $13, 0x1000
	addui	$12, $0, 46
	sw	$12, 0($13)
	j	L.74
L.75:
L.73:
	j	L.72
L.74:
L.70:
	lw	$13, counter($0)
	slt	$13, $13, $7
	bnez	$13, L.77
	j	L.80
L.79:
	lhi	$13, 0x7
	ori	$13, $13, 0x1003
	lw	$13, 0($13)
	andi	$13, $13, 2
	seq	$13, $13, $0
	bnez	$13, L.82
	lhi	$13, 0x7
	ori	$13, $13, 0x1000
	lw	$12, counter($0)
	addui	$11, $0, 10
	mult	$11, $11, $7
	rem	$12, $12, $11
	div	$12, $12, $7
	lw	$12, number_charArray($12)
	sw	$12, 0($13)
	j	L.81
L.82:
L.80:
	j	L.79
L.81:
L.77:
L.67:
	divi	$7, $7, 10
	sgt	$13, $7, $0
	bnez	$13, L.66
	j	L.60
L.59:
	snei	$13, $4, 3
	bnez	$13, L.84
	j	L.87
L.86:
	lhi	$13, 0x7
	ori	$13, $13, 0x1003
	lw	$13, 0($13)
	andi	$13, $13, 2
	seq	$13, $13, $0
	bnez	$13, L.89
	lhi	$13, 0x7
	ori	$13, $13, 0x1000
	addui	$12, $0, 13
	sw	$12, 0($13)
	j	L.88
L.89:
L.87:
	j	L.86
L.88:
	lhi	$7, 0x1
	ori	$7, $7, 0x86a0
L.91:
	lw	$13, counter($0)
	slt	$13, $13, $7
	bnez	$13, L.95
	j	L.98
L.97:
	lhi	$13, 0x7
	ori	$13, $13, 0x1003
	lw	$13, 0($13)
	andi	$13, $13, 2
	seq	$13, $13, $0
	bnez	$13, L.100
	lhi	$13, 0x7
	ori	$13, $13, 0x1000
	lw	$12, counter($0)
	addui	$11, $0, 10
	mult	$11, $11, $7
	rem	$12, $12, $11
	div	$12, $12, $7
	lw	$12, number_charArray($12)
	sw	$12, 0($13)
	j	L.99
L.100:
L.98:
	j	L.97
L.99:
L.95:
L.92:
	divi	$7, $7, 10
	sgt	$13, $7, $0
	bnez	$13, L.91
	j	L.85
L.84:
	sne	$13, $4, $0
	bnez	$13, L.102
	j	L.1
L.102:
L.85:
L.60:
L.26:
L.3:
	j	L.2
L.1:
	lw	$3, 0($sp)
	lw	$4, 1($sp)
	lw	$5, 2($sp)
	lw	$6, 3($sp)
	lw	$7, 4($sp)
	lw	$11, 5($sp)
	lw	$12, 6($sp)
	lw	$13, 7($sp)
	addui	$sp, $sp, 9
	jr	$ra
