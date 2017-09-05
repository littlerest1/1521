
	  
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
   .asciiz "===After iteration "
msg5:
   .asciiz "==="
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