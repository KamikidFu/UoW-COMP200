.global	main
.text
main:
	subui	$sp, $sp, 5
	sw	$5, 0($sp)
	sw	$6, 1($sp)
	sw	$7, 2($sp)
	sw	$12, 3($sp)
	sw	$13, 4($sp)
	addui	$7, $0, 1
	j	L.3
L.2:
	lhi	$13, 0x7
	ori	$13, $13, 0x3001
	lw	$5, 0($13)
	lhi	$13, 0x7
	ori	$13, $13, 0x3000
	lw	$6, 0($13)
	seq	$13, $5, $0
	bnez	$13, L.5
	addu	$7, $0, $5
L.5:
	snei	$13, $7, 1
	bnez	$13, L.7
	lhi	$13, 0x7
	ori	$13, $13, 0x3002
	srai	$12, $6, 4
	andi	$12, $12, 15
	sw	$12, 0($13)
	lhi	$13, 0x7
	ori	$13, $13, 0x3003
	andi	$12, $6, 15
	sw	$12, 0($13)
	j	L.8
L.7:
	snei	$13, $7, 2
	bnez	$13, L.9
	remi	$6, $6, 100
	lhi	$13, 0x7
	ori	$13, $13, 0x3002
	divi	$12, $6, 10
	sw	$12, 0($13)
	lhi	$13, 0x7
	ori	$13, $13, 0x3003
	remi	$12, $6, 10
	sw	$12, 0($13)
	j	L.10
L.9:
	snei	$13, $7, 3
	bnez	$13, L.11
	j	L.1
L.11:
L.10:
L.8:
L.3:
	j	L.2
L.1:
	lw	$5, 0($sp)
	lw	$6, 1($sp)
	lw	$7, 2($sp)
	lw	$12, 3($sp)
	lw	$13, 4($sp)
	addui	$sp, $sp, 5
	jr	$ra
