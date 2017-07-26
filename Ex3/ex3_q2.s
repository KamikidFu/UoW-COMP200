.text
.global main

main:
	addi $1,$0,'a'		#$1 stores char a data
	addi $2,$2,'z'		#$2 stores char z data
	addi $2,$2,0x01		#$2 stores one more because it could output char z
	subi $3,$1,0x01		#$3 stores the previous data of char a because it could output char a

display:	
	#check current serial status
	lw $4,0x71003($0)	#Load status data from register
	andi $4,$4,0x02		#most-left 2 bits are what we want
	beqz $4,display		#check the status of TDS
				#cases: 01 - TDS has data, RDD no data (Busy)
				#cases: 00 - TDS has data, RDD has new data received (Busy)
	addi $3,$3,1		#Increse the lower alphabet for store
	sw $3,0x71000($0)	#Store data into VT320

	sub $1,$3,$2		#Check if $3 is already becoming char z
	beqz $1, exit		#If so, exit the program

	j display		#if not, run the loop agian

exit:
	syscall
