.data

.text
main: 
	lui $1,0xFFFF			
	ori $28,$1,0xF000
    
	addi $17, $0, 0
	addi $18, $0, 1
	addi $19, $0, 2
	addi $20, $0, 3
	addi $21, $0, 4
	addi $22, $0, 5
	addi $23, $0, 6
	addi $24, $0, 7
    
loop:
	lw $1, 0xC72($28)	#left-8 switch in $1
	#no need to shift srl5 ?
	beq $1,$17,palindrome	#000 0
	beq $1,$18,loadAndShow	#001 1
	beq $1,$19,bitAnd	#010 2
	beq $1,$20, bitOr	#011 3
	beq $1,$21, bitXor	#100 4
	beq $1,$22, shiftLeftLogical		#101 5
	beq $1,$23, shiftRightLogical		#110 6
	beq $1,$24, shiftRightArithmetic	#111 7

palindrome:
	lw   $2,0xC70($28)
	sw   $2,0xC60($28)	
	
	#no need to empty: 2,5,7,8,9,10
	and $8,$8,$0
	add $8,$2,$0	#input in $2
	
	and $5,$5,$0	#empty $5
	add $5,$2,$0
	
	and $6,$6,$0	#empty $6
	and $9,$9,$0
	and $10,$10,$0
	and $25,$25,$0
	#t0,t2 stores input
	#s0 stores reversed binary,s1 stores orginal number,s2 stores reversed hex
	#t1 stores 1
LoopBinary:
	lw $2,0xC70($28)	#right-16 switch in $2
	beq $8,$0,exit2
	addi $1,$1,0	#filler
	
	sll $6,$6,1
	
	#check if the lowest-significant bit is 1
	sll $9,$8,31
	srl $9,$9,31
	
	srl $8,$8,1
	addi $10, $0, 1
	
	beq $9,$10,have1
	addi $1,$1,0	#filler
	
	j LoopBinary
	addi $1,$1,0	#filler
	
have1:
	addi $6,$6,1
	j LoopBinary
	addi $1,$1,0	#filler
	
exit2:
	add $5,$2,$0
	xor $7,$5,$6

	beq $7,$0,p2
	addi $1,$1,0	#filler
	
	#NOT binary palindrome
	addi $25,$0,0
	sw $25, 0xC62($28)
	j loop
	addi $1,$1,0	#filler
	
p2:	
	#is binary palindrome
	
	addi $25,$0,1
	sw $25, 0xC62($28)
	j loop
	addi $1,$1,0	#filler
	



















loadAndShow:
	sw $0,0xC62($28)

	lw $2,0xC70($28)	#right-16 switch in $2
	sw $2,0xC60($28) 
	add $3,$0,$2 
	andi $2,$2,0xFF00
	srl $2,$2,8		#a

	andi $3,$3,0x00FF	#b
	
	j loop
	addi $1,$1,0	#filler
	
bitAnd:
	sw $0,0xC62($28)
	
	lw $2,0xC70($28)	#right-16 switch in $2
	add $3,$0,$2 
	andi $2,$2,0xFF00
	srl $2,$2,8		#a
	andi $3,$3,0x00FF	#b
	
	and $4,$2,$3
	sw $4,0xC60($28)
	j loop
	addi $1,$1,0	#filler
	
bitOr:
	sw $0,0xC62($28)
	
	lw $2,0xC70($28)	#right-16 switch in $2
	add $3,$0,$2 
	andi $2,$2,0xFF00
	srl $2,$2,8		#a
	andi $3,$3,0x00FF	#b
	
	or $4,$2,$3
	sw $4,0xC60($28)
	j loop
	addi $1,$1,0	#filler
	
bitXor:
	sw $0,0xC62($28)

	lw $2,0xC70($28)	#right-16 switch in $2
	add $3,$0,$2 
	andi $2,$2,0xFF00
	srl $2,$2,8		#a
	andi $3,$3,0x00FF	#b
	
	xor $4,$2,$3
	sw $4,0xC60($28)
	j loop
	addi $1,$1,0	#filler
	
shiftLeftLogical:
	sw $0,0xC62($28)

	lw $2,0xC70($28)	#right-16 switch in $2
	add $3,$0,$2 
	andi $2,$2,0xFF00
	srl $2,$2,8		#a
	andi $3,$3,0x00FF	#b
	
	sllv $4,$2,$3
	sw $4,0xC60($28)
	j loop
	addi $1,$1,0	#filler
	
shiftRightLogical:
	sw $0,0xC62($28)

	lw $2,0xC70($28)	#right-16 switch in $2
	add $3,$0,$2 
	andi $2,$2,0xFF00
	srl $2,$2,8		#a
	andi $3,$3,0x00FF	#b
	
	srlv $4,$2,$3
	sw $4,0xC60($28)
	j loop
	addi $1,$1,0	#filler
	
shiftRightArithmetic:
	sw $0,0xC62($28)

	lw $2,0xC70($28)	#right-16 switch in $2
	add $3,$0,$2
	andi $2,$2,0xFF00
	srl $2,$2,8		#a
	andi $3,$3,0x00FF	#b
	
	srl $13,$2,7
	bne $13,$18,l1
	addi $1,$1,0	#filler
	lui $14,0xFFFF
	ori $14,$14,0xFF00
   	or $2,$2,$14
l1:	
	srl $13,$3,7
	bne $13,$18,l2	#if b is positive then l2
	addi $1,$1,0	#filler
	lui $14,0xFFFF
	ori $14,$14,0xFF00
   	or $3,$3,$14
l2:
	srlv $8,$2,$3
	andi $8,$8,0x00FF
	sw $8, 0xC60($28) 
	j loop
	addi $1,$1,0	#filler
