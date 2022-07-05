
.data
	dataset0: .space 40 
	dataset1: .space 40 # from 40($3)
	dataset2: .space 40 # from 80($3)
	dataset3: .space 40 # from 120($3)
	con_dataset0: .space 40 #from 160
	con_dataset2: .space 40 #from 200
	
.text
main: 

#-------register lists------------
# $1,$2,$28 only used for IO
# $5 used to record how many numbers entered
# $6 0xffffffff
# $4 for sw and lw
# $3 used for datasets base address (is one base address enough)
# registers bigger than $7 need to reset before executing each case, only use registers $8~$25
# if inputs are less than 4, in sorting, set no input values to ff
	addi $31, $0, 0
	lui $1,0xFFFF			
	ori $28,$1,0xF000
	lui $6,0xFFFF
	ori $6,$6,0xFFFF	#inti $6=0xFFFFFFFF
	lui $3, 0x1001		#set base address of dataset
	addi $2,$0,256		#init MAX, only initialize once
	sw $2,0($3)
	sw $2,4($3)
	sw $2,8($3)
	sw $2,12($3)
	sw $2,16($3)
	sw $2,20($3)
	sw $2,24($3)
	sw $2,28($3)
	sw $2,32($3)
	sw $2,36($3)
	sw $2,40($3)
	sw $2,44($3)
	sw $2,48($3)
	sw $2,52($3)
	sw $2,56($3)
	sw $2,60($3)
	sw $2,64($3)
	sw $2,68($3)
	sw $2,72($3)
	sw $2,76($3)
	sw $0,80($3)
	sw $0,84($3)
	sw $0,88($3)
	sw $0,92($3)
	sw $0,96($3)
	sw $0,100($3)
	sw $0,104($3)
	sw $0,108($3)
	sw $0,112($3)
	sw $0,116($3)
	sw $0,120($3)
	sw $0,124($3)
	sw $0,128($3)
	sw $0,132($3)
	sw $0,136($3)
	sw $0,140($3)
	sw $0,144($3)
	sw $0,148($3)
	sw $0,152($3)
	sw $0,156($3)



loop:

	addi $17, $0, 0		#default state, show dataset0[0]
	addi $18, $0, 1		# sort state, sort dataset0 and store in dataset1, smaller number go smaller address
	addi $19, $0, 2		# convert into 2's complement, put into dataset2
	addi $20, $0, 3		# sort 2's complement, put into dataset 3
	addi $21, $0, 4		# get biggest-smallest in dataset1
	addi $22, $0, 5		# get biggest-smallest in dataset3
	addi $23, $0, 6		# show dataset123 by index
	addi $24, $0, 7		# led blink
 
	#sw23 be input control
	addi $25, $0, 128  #put data in pos0 of ds0 1_00_0_0000
	addi $26, $0, 136  #pos1 of ds0 1_0001_000
	addi $27, $0, 144  #pos2 of ds0 1_0010_000
	addi $16, $0, 152 #pos3 of ds0 1_0011_000 avoid 28
	addi $15, $0, 160 #pos4 of ds0 1_0100_000 avoid 28
	addi $14, $0, 168  #pos5 of ds0 1_0101_000 avoid 28
	addi $13, $0, 176 #pos6 of ds0 1_0110_000 avoid 28
	addi $12, $0, 184  #pos7 of ds0 1_0111_000 avoid 28
	addi $11, $0, 192  #pos8 of ds0 1_1000_000 avoid 28
	addi $10, $0, 200  #pos9 of ds0 1_1001_000 avoid 28

	lw $1, 0xC72($28)	#left-8 switch in $1
	beq $1,$17,case0
	beq $1,$18,case1
	beq $1,$19,get_complement
	beq $1,$20,sort_complement
	beq $1,$21,show_ds1_biggest_minus_smallest
	beq $1,$22,show_ds3_biggest_minus_smallest
	beq $1,$23,find_by_index
	beq $1,$24,blink
	beq $1,$25,insert_index0
	beq $1,$26,insert_index1
	beq $1,$27,insert_index2
	beq $1,$16,insert_index3 
	beq $1,$15,insert_index4
	beq $1,$14,insert_index5
	beq $1,$13,insert_index6
	beq $1,$12,insert_index7
	beq $1,$11,insert_index8
	beq $1,$10,insert_index9

	addi $1,$1,0 #filler command test beq
	j loop
	addi $1,$1,0 #filler command test beq


sort_complement:
	#register list: 
	# $21 store $5+1, how many loops
	#$7 int i; $8 int j; $21: length=4; $9 check loop2; $10 store arr[j]; 
	#$11 store arr[j+1], $12 store arr[j]'s address, $9 check is swap arr[j] and arr[j+1] (arr[j]>arr[j+1]), $14 store tmp for swap
	addi $7,$0,0 #i=0
	addi $8,$0,0
	addi $9,$0,0
	addi $10,$0,0
	addi $11,$0,0
	addi $12, $0,0 #reset $12
	addi $14, $0,0 #reset $14
	addi $18, $0,1 #reset $18=1
	addi $21,$5,1

	#conserve original order
	lw $13,80($3)
	lw $15,84($3)
	lw $16,88($3)
	lw $17,92($3)
	lw $19,96($3)
	lw $20,100($3)
	lw $22,104($3)
	lw $23,108($3)
	lw $24,112($3)
	lw $25,116($3)

comp_for1tst:

	beq $7,$21,comp_exit1 #loop continues if i<n, breaks if i=n
	addi $1,$1,0

	sub $8,$7,$18 	#j=i-1 # or sub $8,$8,$18
comp_for2tst:
	#check if continue loop
	slti $9, $8,0
	bne $9,$0,comp_exit2
	addi $1,$1,0

	#arr[j] address= 4*j + base addr + bias
	sll $12,$8,2
	add $12,$12,$3 
	addi $12,$12,80
	lw $10,0($12)
	lw $11,4($12)
	#if(arr[j]<arr[j+1]) break; else swap
	slt $9,$10,$11 
	beq $9,$18,comp_exit2
	addi $1,$1,0
	#swap
	lw $14,0($12) # tmp=arr[j]
	sw $11,0($12)
	sw $10,4($12)
	#j--
	sub $8,$8,$18 
	j comp_for2tst
	addi $1,$1,0

comp_exit2:
	addi $7,$7,1 #i++
	j comp_for1tst
	addi $1,$1,0

	
comp_exit1:
	#now need to store sorted array into ds3
	lw $4,80($3)
	sw $4,120($3)
	lw $4,84($3)
	sw $4,124($3)
	lw $4,88($3)
	sw $4,128($3)
	lw $4,92($3)
	sw $4,132($3)
	lw $4,96($3)
	sw $4,136($3)
	lw $4,100($3)
	sw $4,140($3)
	lw $4,104($3)
	sw $4,144($3)
	lw $4,108($3)
	sw $4,148($3)
	lw $4,112($3)
	sw $4,152($3)
	lw $4,116($3)
	sw $4,156($3)
	
	#restore
	sw $13,80($3)
	sw $15,84($3)
	sw $16,88($3)
	sw $17,92($3)
	sw $19,96($3)
	sw $20,100($3)
	sw $22,104($3)
	sw $23,108($3)
	sw $24,112($3)
	sw $25,116($3)

	j loop
	addi $1,$1,0


get_complement:

	addi $9,$0,0 #i=0
	addi $8,$0,10 #if i=10 break
	addi $7,$0,0 #address
comp_loop:
	beq $8,$9, comp_exit
	addi $1,$1,0

	sll $7,$9,2 #i*4
	add $7,$7,$3 #i*4+base (no bias for ds0)
	lw $10,0($7)
	#if bit7 is 1, convert; if 0, remain the same.
	# $20 to judge bit7
	sll $10,$10,24 #clear [31:8] 1_0000_0000
	srl $10, $10,24 #restore original number (if original is MAX, it will become 0 in ds2)
	srl $20,$10,7
	beq $20,$0,comp_sw	#if 20=0, convert else store
	addi $1,$1,0

	#convert
	#find first 1, and set bits before it to all 1
	# $11: 1111_1111_1111_1111_1111_1111_1000_0000
	# $6: 0xFFFFFFFF
	lui $11,0xFFFF #upper 16
	ori $11,$11,0xFF00 #[15:8]
	sra $11,$11,1
	#clear sign bit
	sll $10,$10,25
	srl $10,$10,25
	#all 1-num
	sub $10,$6,$10
	addi $10,$10,1

comp_sw:
	sw $10,80($7) # $7+bias
	addi $9,$9,1 #i+=1
	j comp_loop
	addi $1,$1,0

comp_exit:
	j loop
	addi $1,$1,0
	# $10 to $19 store each number in ds0

	


case0:
	j loop

case1:
	#register list: 
	#$7 int i; $8 int j; $21: length=4; $9 check loop2; $10 store arr[j]; 
	#$11 store arr[j+1], $12 store arr[j]'s address, $9 check is swap arr[j] and arr[j+1] (arr[j]>arr[j+1]), $14 store tmp for swap

	addi $7,$0,0 #i=0
	addi $8,$0,0
	addi $9,$0,0
	addi $10,$0,0
	addi $11,$0,0
	addi $12, $0,0 #reset $12
	addi $14, $0,0 #reset $14
	addi $18, $0,1 #reset $18=1
	addi $21, $0, 10 # set $21=n
	#conserve original order
	lw $13,0($3)
	lw $15,4($3)
	lw $16,8($3)
	lw $17,12($3)
	lw $19,16($3)
	lw $20,20($3)
	lw $22,24($3)
	lw $23,28($3)
	lw $24,32($3)
	lw $25,36($3)
	
for1tst:

	beq $7,$21,exit1 #loop continues if i<n, breaks if i=n
	addi $1,$1,0

	sub $8,$7,$18 	#j=i-1 # or sub $8,$8,$18
for2tst:
	#check if continue loop
	slti $9, $8,0
	bne $9,$0,exit2
	addi $1,$1,0

	#arr[j] address= 4*j + base addr
	sll $12,$8,2
	add $12,$12,$3 
	lw $10,0($12)
	lw $11,4($12)
	#if(arr[j]<arr[j+1]) break; else swap
	slt $9,$10,$11 
	beq $9,$18,exit2
	addi $1,$1,0
	#swap
	lw $14,0($12) # tmp=arr[j]
	sw $11,0($12)
	sw $10,4($12)
	#j--
	sub $8,$8,$18  # or sub $8,$8,$18
	j for2tst
	addi $1,$1,0

exit2:
	addi $7,$7,1 #i++
	j for1tst
	addi $1,$1,0
	
exit1:
	#now need to store sorted array into ds1
	lw $4,0($3)
	sw $4,40($3)
	lw $4,4($3)
	sw $4,44($3)
	lw $4,8($3)
	sw $4,48($3)
	lw $4,12($3)
	sw $4,52($3)
	lw $4,16($3)
	sw $4,56($3)
	lw $4,20($3)
	sw $4,60($3)
	lw $4,24($3)
	sw $4,64($3)
	lw $4,28($3)
	sw $4,68($3)
	lw $4,32($3)
	sw $4,72($3)
	lw $4,36($3)
	sw $4,76($3)

	#restore order
	sw $13,0($3)
	sw $15,4($3)
	sw $16,8($3)
	sw $17,12($3)
	sw $19,16($3)
	sw $20,20($3)
	sw $22,24($3)
	sw $23,28($3)
	sw $24,32($3)
	sw $25,36($3)

	j loop
	addi $1,$1,0


show_index0:
	lw $4,76($3) #changed to show index9
	sw $4,0xC60($28)
	j loop

show_index1:
	lw $4,44($3)
	sw $4,0xC60($28)
	j loop

show_index2:
	lw $4,48($3)
	sw $4,0xC60($28)
	j loop

show_index3:
	lw $4,12($3)
	sw $4,0xC60($28)
	j loop
	addi $1,$1,0

find_by_index:
	lw $9, 0xC70($28)	#right switch in $9
	#total 30 cases
	#use right 16 switches for selection
	#[1:0] for dataset, [5:2] for index
	#first pick dataset
	addi $10,$0,1	#0000_0000_0000_0001
	addi $11,$0,2	#0000_0000_0000_0010
	addi $12,$0,4	#0000_0000_0000_0100
	beq $9,$10, find_in_ds1
	beq $9,$11, find_in_ds2
	beq $9,$12, find_in_ds3
	addi $1,$1,0
	j loop
	addi $1,$1,0  

find_in_ds3:
	lw $9, 0xC70($28)	#right switch in $9
	addi $10,$0,4    #0000_0000_0000_0100
	addi $11,$0,20    #0000_0000_0001_0100
	addi $12,$0,36    #0000_0000_0010_0100
	addi $13,$0,52    #0000_0000_0011_0100
	addi $14,$0,68    #0000_0000_0100_0100
	addi $15,$0,84    #0000_0000_0101_0100
	addi $16,$0,100    #0000_0000_0110_0100
	addi $17,$0,116    #0000_0000_0111_0100
	addi $18,$0,132    #0000_0000_1000_0100
	addi $19,$0,148   #0000_0000_1001_0100
	beq $9,$10, find_in_ds3_0
	beq $9,$11, find_in_ds3_1
	beq $9,$12, find_in_ds3_2
	beq $9,$13, find_in_ds3_3
	beq $9,$14, find_in_ds3_4
	beq $9,$15, find_in_ds3_5
	beq $9,$16, find_in_ds3_6
	beq $9,$17, find_in_ds3_7
	beq $9,$18, find_in_ds3_8
	beq $9,$19, find_in_ds3_9
	beq $9,$0,loop
	addi $1,$1,0

	j find_in_ds3
	addi $1,$1,0

find_in_ds3_0:
	lw $4, 120($3)
	sw $4, 0xC60($28)
	j find_in_ds3
	addi $1,$1,0
find_in_ds3_1:
	lw $4, 124($3)
	sw $4, 0xC60($28)
	j find_in_ds3
	addi $1,$1,0
find_in_ds3_2:
	lw $4, 128($3)
	sw $4, 0xC60($28)
	j find_in_ds3
	addi $1,$1,0
find_in_ds3_3:
	lw $4, 132($3)
	sw $4, 0xC60($28)
	j find_in_ds3
	addi $1,$1,0

find_in_ds3_4:
	lw $4,136($3)
	sw $4, 0xC60($28)
	j find_in_ds3
	addi $1,$1,0

find_in_ds3_5:
	lw $4, 140($3)
	sw $4, 0xC60($28)
	j find_in_ds3
	addi $1,$1,0

find_in_ds3_6:
	lw $4, 144($3)
	sw $4, 0xC60($28)
	j find_in_ds3
	addi $1,$1,0

find_in_ds3_7:
	lw $4, 148($3)
	sw $4, 0xC60($28)
	j find_in_ds3
	addi $1,$1,0

find_in_ds3_8:
	lw $4, 152($3)
	sw $4, 0xC60($28)
	j find_in_ds3
	addi $1,$1,0

find_in_ds3_9:
	lw $4, 156($3)
	sw $4, 0xC60($28)
	j find_in_ds3
	addi $1,$1,0


find_in_ds2:
	lw $9, 0xC70($28)	#right switch in $9
	addi $10,$0,2    #0000_0000_0000_0010
	addi $11,$0,18    #0000_0000_0001_0010
	addi $12,$0,34    #0000_0000_0010_0010
	addi $13,$0,50    #0000_0000_0011_0010
	addi $14,$0,66    #0000_0000_0100_0010
	addi $15,$0,82    #0000_0000_0101_0010
	addi $16,$0,98    #0000_0000_0110_0010
	addi $17,$0,114    #0000_0000_0111_0010
	addi $18,$0,130    #0000_0000_1000_0010
	addi $19,$0,146   #0000_0000_1001_0010
	beq $9,$10, find_in_ds2_0
	beq $9,$11, find_in_ds2_1
	beq $9,$12, find_in_ds2_2
	beq $9,$13, find_in_ds2_3
	beq $9,$14, find_in_ds2_4
	beq $9,$15, find_in_ds2_5
	beq $9,$16, find_in_ds2_6
	beq $9,$17, find_in_ds2_7
	beq $9,$18, find_in_ds2_8
	beq $9,$19, find_in_ds2_9
	beq $9,$0,loop
	addi $1,$1,0

	j find_in_ds2
	addi $1,$1,0

find_in_ds2_0:
	lw $4, 80($3)
	sw $4, 0xC60($28)
	j find_in_ds2
	addi $1,$1,0
find_in_ds2_1:
	lw $4, 84($3)
	sw $4, 0xC60($28)
	j find_in_ds2
	addi $1,$1,0
find_in_ds2_2:
	lw $4, 88($3)
	sw $4, 0xC60($28)
	j find_in_ds2
	addi $1,$1,0
find_in_ds2_3:
	lw $4, 92($3)
	sw $4, 0xC60($28)
	j find_in_ds2
	addi $1,$1,0

find_in_ds2_4:
	lw $4, 96($3)
	sw $4, 0xC60($28)
	j find_in_ds2
	addi $1,$1,0

find_in_ds2_5:
	lw $4, 100($3)
	sw $4, 0xC60($28)
	j find_in_ds2
	addi $1,$1,0

find_in_ds2_6:
	lw $4, 104($3)
	sw $4, 0xC60($28)
	j find_in_ds2
	addi $1,$1,0

find_in_ds2_7:
	lw $4, 108($3)
	sw $4, 0xC60($28)
	j find_in_ds2
	addi $1,$1,0

find_in_ds2_8:
	lw $4, 112($3)
	sw $4, 0xC60($28)
	j find_in_ds2
	addi $1,$1,0

find_in_ds2_9:
	lw $4, 116($3)
	sw $4, 0xC60($28)
	j find_in_ds2
	addi $1,$1,0



find_in_ds1:
	lw $9, 0xC70($28)	#right switch in $9
	addi $10,$0,1    #0000_0000_0000_0001
	addi $11,$0,17    #0000_0000_0001_0001
	addi $12,$0,33    #0000_0000_0010_0001
	addi $13,$0,49    #0000_0000_0011_0001
	addi $14,$0,65    #0000_0000_0100_0001
	addi $15,$0,81    #0000_0000_0101_0001
	addi $16,$0,97    #0000_0000_0110_0001
	addi $17,$0,113    #0000_0000_0111_0001
	addi $18,$0,129    #0000_0000_1000_0001
	addi $19,$0,145   #0000_0000_1001_0001
	beq $9,$10, find_in_ds1_0
	beq $9,$11, find_in_ds1_1
	beq $9,$12, find_in_ds1_2
	beq $9,$13, find_in_ds1_3
	beq $9,$14, find_in_ds1_4
	beq $9,$15, find_in_ds1_5
	beq $9,$16, find_in_ds1_6
	beq $9,$17, find_in_ds1_7
	beq $9,$18, find_in_ds1_8
	beq $9,$19, find_in_ds1_9
	beq $9,$0,loop
	addi $1,$1,0

	j find_in_ds1
	addi $1,$1,0

find_in_ds1_0:
	lw $4, 40($3)
	sw $4, 0xC60($28)
	j find_in_ds1
	addi $1,$1,0
find_in_ds1_1:
	lw $4, 44($3)
	sw $4, 0xC60($28)
	j find_in_ds1
	addi $1,$1,0
find_in_ds1_2:
	lw $4, 48($3)
	sw $4, 0xC60($28)
	j find_in_ds1
	addi $1,$1,0
find_in_ds1_3:
	lw $4, 52($3)
	sw $4, 0xC60($28)
	j find_in_ds1
	addi $1,$1,0

find_in_ds1_4:
	lw $4, 56($3)
	sw $4, 0xC60($28)
	j find_in_ds1
	addi $1,$1,0

find_in_ds1_5:
	lw $4, 60($3)
	sw $4, 0xC60($28)
	j find_in_ds1
	addi $1,$1,0

find_in_ds1_6:
	lw $4, 64($3)
	sw $4, 0xC60($28)
	j find_in_ds1
	addi $1,$1,0

find_in_ds1_7:
	lw $4, 68($3)
	sw $4, 0xC60($28)
	j find_in_ds1
	addi $1,$1,0

find_in_ds1_8:
	lw $4, 72($3)
	sw $4, 0xC60($28)
	j find_in_ds1
	addi $1,$1,0

find_in_ds1_9:
	lw $4, 76($3)
	sw $4, 0xC60($28)
	j find_in_ds1
	addi $1,$1,0



show_ds1_biggest_minus_smallest:
	#$5 have biggest index inserted (0-indexed)
	#$11 have biggest num
	#$12 have smallest num
	addi $10,$0,0
	
	
	sll $10, $5,2 # 4*i
	addi $10,$10,40 # 4*i + bias
	add $10,$10,$3 # 4*i + bias + base addr
	lw $11, 0($10)

	addi $10,$0,0
	addi $10,$10,40
	lw $12,0($10)
	
	sub $11, $11, $12
	sw $11, 0xC60($28)
	j loop
	addi $1,$1,0

show_ds3_biggest_minus_smallest:
	#$5 have biggest index inserted (0-indexed)
	#$11 have biggest num
	#$12 have smallest num
	addi $10,$0,0
	
	sll $10, $5,2 # 4*i
	addi $10,$10,120 # 4*i + bias
	add $10,$10,$3 # 4*i + bias + base addr
	lw $11, 0($10)

	addi $10,$0,0
	addi $10,$10,120
	lw $12,0($10)
	
	sub $11, $11, $12
	sw $11, 0xC60($28)
	j loop
	addi $1,$1,0

	

insert_index0:	
	lw $2,0xC70($28)	#right-16 switch in $2
	andi $2,$2,0x00FF
	sw $2, 0($3) 
	addi $5, $0,0
	j loop
	
insert_index1:

	lw $2,0xC70($28)	#right-16 switch in $2
	andi $2,$2,0x00FF
	sw $2, 4($3)
	addi $5, $0,1

	j loop

insert_index2:

	lw $2,0xC70($28)	#right-16 switch in $2
	andi $2,$2,0x00FF
	sw $2, 8($3)
	addi $5, $0,2
	j loop

insert_index3:
	lw $2,0xC70($28)	#right-16 switch in $2
	andi $2,$2,0x00FF
	sw $2, 12($3)
	addi $5, $0,3

	j loop

insert_index4:
	lw $2,0xC70($28)	#right-16 switch in $2
	andi $2,$2,0x00FF
	sw $2, 16($3)
	addi $5, $0,4

	j loop

insert_index5:
	lw $2,0xC70($28)	#right-16 switch in $2
	andi $2,$2,0x00FF
	sw $2, 20($3)
	addi $5, $0,5

	j loop

insert_index6:
	lw $2,0xC70($28)	#right-16 switch in $2
	andi $2,$2,0x00FF
	sw $2, 24($3)
	addi $5, $0,6

	j loop

insert_index7:
	lw $2,0xC70($28)	#right-16 switch in $2
	andi $2,$2,0x00FF
	sw $2, 28($3)
	addi $5, $0,7
	j loop

insert_index8:
	lw $2,0xC70($28)	#right-16 switch in $2
	andi $2,$2,0x00FF
	sw $2, 32($3)
	addi $5, $0,8

	j loop

insert_index9:
	lw $2,0xC70($28)	#right-16 switch in $2
	andi $2,$2,0x00FF
	sw $2, 36($3)
	addi $5, $0,9

	j loop
	
blink:
	#clear reg!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	addi $20, $0, 0
	addi $21, $0, 0
	addi $22, $0, 0
	addi $23, $0, 0
	addi $24, $0, 0
	addi $25, $0, 0
	addi $26, $0, 0
	addi $27, $0, 0
	
	lui $25, 0x036D		#$25 stores a bigInt which needs 5s to increase to
	ori $25, $25,0x6160
	addi $11, $0, 1	# $11 always stores 1
	addi $12, $0, 2	# $12 always stores 2
	lw $20,0xC70($28)	# $20 store right 16 switch, which is the idx user demand
	# $21 is what to display
	# $22 is dataset0 corresponding element low 8bit
	# $23 is dataset2 corresponding element low 8bit
	# $26,$27 is address the corresponding element of ds0 and ds1
	# $31 is temp reg, if 0 showDS0, if 1 showDS2
	
	wait:	#wait for approx 5s
		addi $24, $24, 1
		bne $24, $25, wait
		addi $1,$1,0	#filler
		
	beq $31, $0, showDS0	# $31 is temp reg, if 0 showDS0, if 1 showDS2
	addi $1,$1,0	#filler
	
	showDS2:
		addi $31, $31, -1
		#TODO
		addi $21, $20, 0	# copy $20 to $21, which is input
		addi $21, $21, 32	# $21 is now 00...,0010,xxxx
		sll $21, $21, 9
		#load $23
		addi $27, $20, 0	# copy $20 to $27, which is input
		sll $27, $27, 2		# $27 * 4
		addi $27, $27, 80	# $27 * 4 + bias
		add $27, $27, $3	# $27 * 4 + bias + base address
		lw $23, 0($27)
		sll $23, $23, 24
		srl $23, $23, 24
		
		add $21, $21, $23	# merge to result
		sw $21, 0xC60($28)
		j loop
		addi $1,$1,0	#filler
	
	showDS0:	#first show DS0
		addi $31, $31, 1
		#TODO
		addi $21, $20, 0	# copy $20 to $21, which is input
		sll $21, $21, 9
		#load $22
		addi $26, $20, 0	# copy $20 to $26, which is input
		sll $26, $26, 2		# $26 * 4
		addi $26, $26, 0	# $26 * 4 + bias
		add $26, $26, $3	# $26 * 4 + bias + base address
		lw $22, 0($26)
		sll $22,$22,24
		srl $22,$22,24		# get low 8 bit of $22
		
		add $21, $21, $22	# merge to result
		sw $21, 0xC60($28)
		j loop
		addi $1,$1,0	#filler

