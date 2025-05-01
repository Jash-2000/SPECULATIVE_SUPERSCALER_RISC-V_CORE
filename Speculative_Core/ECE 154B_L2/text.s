.data 
.text 
.globl      MAIN  
MAIN: 	addi    s0, x0, 0          # countx = 0;           
	addi    s1, x0, 0          # county = 0;          
	addi    s2, x0, 0          # countz = 0;          
	addi    s3, x0, 0          # innercount = 0;          
	addi    t0, x0, 1          # x = 1
# beginning of the loop
	addi    t3, x0, 0          # outer = 0
	addi    t4, x0, 10         # end of the outer loop constant 
	addi    t6, x0, 4          # end of the inner loop constant
OUTER:  beq     t3, t4, END        # using on purpose not efficient implementation of the outer for loop 
	andi    t1, t3, 1          # y=outer&1
	and     t2, t0, t1         # z=x&y       z=x&y
	beq     t0, x0, SKIPX       
	addi    s0, s0, 1            # countx++;
SKIPX:  beq     t1, x0, SKIPY      
	addi    s1, s1, 1            # county++;
SKIPY:  beq     t2, x0, SKIPZ      
	addi    s2, s2, 1            # countz++;
SKIPZ:  addi    t5, x0, 0            # beginning of inner loop 
INNER:  addi    t5, t5, 1            # inner++;  
	addi    s3, s3, 1            # innercount++;  
	bne     t5, t6, INNER   
	addi    t3, t3, 1            # outer++;  
	jal     x0, OUTER
END:    addi   x0, x0, 0
