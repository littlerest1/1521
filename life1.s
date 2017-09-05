# board.s ... Game of Life on a 10x10 grid

   .data

N: .word 10  # gives board dimensions

board:
   .byte 1, 0, 0, 0, 0, 0, 0, 0, 0, 0
   .byte 1, 1, 0, 0, 0, 0, 0, 0, 0, 0
   .byte 0, 0, 0, 1, 0, 0, 0, 0, 0, 0
   .byte 0, 0, 1, 0, 1, 0, 0, 0, 0, 0
   .byte 0, 0, 0, 0, 1, 0, 0, 0, 0, 0
   .byte 0, 0, 0, 0, 1, 1, 1, 0, 0, 0
   .byte 0, 0, 0, 1, 0, 0, 1, 0, 0, 0
   .byte 0, 0, 1, 0, 0, 0, 0, 0, 0, 0
   .byte 0, 0, 1, 0, 0, 0, 0, 0, 0, 0
   .byte 0, 0, 1, 0, 0, 0, 0, 0, 0, 0

newBoard: .space 100
# prog.s ... Game of Life on a NxN grid
#
# Needs to be combined with board.s
# The value of N and the board data
# structures come from board.s
#
# Written by <<YOU>>, August 2017
 
   .data
main_ret_save: .space 4
msg1:
   .asciiz "# Iterations: "
msg2:
   .asciiz "."
msg3:
   .asciiz "#"
msg4:
   .asciiz "=== After iteration "
msg5:
   .asciiz " ==="
msg6:
   .asciiz "nbzer"
msg7:
   .asciiz "nbone"
char0:
   .byte 1
eol:
   .asciiz "\n"
   
   .text
   .globl main
main:
   sw   $ra, main_ret_save

   la   $a0, msg1   		#printf("Iterations:")
   li   $v0, 4				
   syscall
   li   $v0, 5				#scanf("&maxiter")==v0
   syscall
   move $s0,$v0    

		li $t0,1        #t0=n=1
		li $t1,0				#i=t1=0
		li $t2,0				#j=t2=0
		lw $t3,N
		la $t4,board    #t4=board
		la $t5,newBoard    #t5=newboard
		j  loop2
    
loop2:
		bgt $t0,$s0,end_main     #t0=n if >maxiter=s0 end
	    j loop3
loop3:
		bge $t1,$t3,end_loop3     #t1=i if >=N  end loop3
	    j loop4
loop4:
		lw $t3,N
		la $t5,newBoard
	  la $t4,board
		bge $t2,$t3,end_loop4     #t2=j if >=N end loop4
	    
		move $a0,$t1
		move $a1,$t2              #move to argument a0=i a1=j
		jal neighbours            #call function   neighbours
		move $s2,$v0        	    #v0->s3  nn return by v0
##		move $a0,$s2
##		li $v0,1
##		syscall

    mul $t1,$t1,10				#t1=i=10i
		add $t4,$t4,$t1				#t4=board[i]
		add $t4,$t4,$t2				#t4=board[i][j]
		lb  $a0,($t4)				#load byte of b[i][j]
		
		beq $a0,1,if2				#if [i][j]=1
		beq $s2,3,nb1 				#if nn=3 nb1
		j   nb0						#else to nb0


		
end_loop4:              
		li $t2,0			#t2=j=0 
		add $t1,$t1,1     #t1=i=i+1
		j loop3

if2:   
	blt $s2,2,nb0
	beq $s2,2,nb1
	beq $s2,3,nb1
	j nb0
nb0:
##sw  $t5,($t5)
	add $t5,$t5,$t1
	add $t5,$t5,$t2
  
  sb $zero,($t5)
  lb $a0,($t5)
  
#  li $v0,1
#  syscall
	
	div $t1,$t1,10
	la  $t4,board
	addi $t2,$t2,1
	j loop4
nb1:
	
##	sw  $t5,($t5)
	add $t5,$t5,$t1
	add $t5,$t5,$t2
	
  lb $a0,char0
  sb $a0,($t5)
  
  lb $a0,($t5)
#  li $v0,1
#  syscall
	
	div $t1,$t1,10
	la  $t4,board
	addi $t2,$t2,1
	j loop4 

end_loop3:
		li $t1,0              #t1=i=0
		la $a0,msg4         #print ===after iteration
		li $v0,4
		syscall
		move $a0,$t0      #print t0=n
		li $v0,1
		syscall
		la $a0,msg5         #print ===
		li $v0,4
		syscall
		la $a0,eol        #new line
		li $v0,4
		syscall		
		j copyshow      #call funtion copybackand show

    
end_main:
   lw   $ra, main_ret_save
   jr   $ra

  .data
   .align 2
neb_ret_save:
   .space 4

   .text
neighbours:   #a0=i a1=j
	  sw $ra,neb_ret_save
	  move $t1,$a0 		#t1=a0=i
	  move $t2,$a1      #t2=a1=j
	  
	  li $t6,0      #t6=nn=0
	  li $t7,-1     #t7=-1=x
	  li $t8,-1		#t8=-1=y
	  lw $t3,N		#t3=N
	  li $t9,0
	  li $s1,0
	  la $t4,board        #t4=board addr
	  
loop5: 	 
	  bgt $t7,1,end_loop5    #t7=x if x>1 out
	  j loop6
loop6:
	  bgt $t8,1,end_loop6		#t8=y if y>1 out
#if1:  
	  add $t9,$t1,$t7			#t9=t1+t7=i+x
	  bltz $t9,continue     #t9<0 continue    
	  sub  $t3,$t3,1			#t3=N-1
	  bgt  $t9,$t3,continue   #t9>9 continue
	  
	  add $s1,$t2,$t8			  #s1=t2+t8=j+y
	  bltz $s1,continue     #s1<0 continue
	  bgt  $s1,$t3,continue #s1>9,continue
	  
	  beqz $t7,second       #if t7=0  second statement
    j    comp
second:
	  beqz $t8,continue      #if y also equal to 0,continue	  
	  j   comp	   

end_loop6:
    li $t8,-1             #y=-1
	  add $t7,$t7,1         #t7=t7+1 x=x+1
	  j loop5
end_loop5:
    move $v0,$t6            #v0=t6
    li $t6,0
	  lw $ra,neb_ret_save   #return value
	  jr $ra
comp:
	  mul $t9,$t9,10        #t9=t9*10
	  add $t4,$t4,$t9       #t4=t4+t9
	  add $t4,$t4,$s1       #t4=t4+s1
	  lb  $a0,($t4)         #load byte of a0
	  beq $a0,1,addn        #if a0=1 add nn

continue:
     lw $t3,N             #t3=N
     li $t9,0             #t9=0
     li $s1,0             #s1=0
     la $t4,board         #reload the add of t4
     add $t8,$t8,1        #t8=t8+1, y=y+1
	   j loop6              #back to loop6


addn:
	 add $t6,$t6,1          #add nn t6=t6+1
	 lw $t3,N             #t3=N
   li $t9,0             #t9=0
   li $s1,0             #s1=0
   la $t4,board         #reload the add of t4
	 add $t8,$t8,1      #y=y+1
	 
	 j loop6            #jump to continue
	 

copyshow:
    li $t1,0
		li $t2,0
		lw $t3,N
		la $t4,board
		la $t5,newBoard
loop7:		
		bge $t1,$t3,end_loop7
		j loop8
loop8:
    bge $t2,$t3,end_loop8
		la  $t4,board
		la  $t5,newBoard
#		sw  $t5,($t5)
		mul $t1,$t1,10
		
		add $t4,$t4,$t1
		add $t4,$t4,$t2
	  add $t5,$t5,$t1
		add $t5,$t5,$t2

    lb $s5,($t5)
  ##  li $v0,1
 ##   syscall
    
		sb $s5,($t4)
	  lb $a0,($t4)
		beqz $a0,printdot
		j printo
end_loop8:
		la $a0,eol
		li $v0,4
		syscall
		
		li $t2,0
		add $t1,$t1,1
		j loop7
end_loop7:
    li $t1,0
    li $t2,0
    lw $t3,N
		la $t4,board
		la $t5,newBoard
		
    addi $t0,$t0,1
    j loop2

printdot:
     la $a0,msg2
	   li $v0,4
	   syscall
	   
	   add $t2,$t2,1
	   div $t1,$t1,10
	   j loop8
printo:
		la $a0,msg3
	   li $v0,4
	   syscall
	   
	   add $t2,$t2,1
	   div $t1,$t1,10
	   j loop8
 