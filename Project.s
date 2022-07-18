.data
sequence:  .byte 0
count:     .word 4
color1:    .word 0xFF7A33
color2:    .word 0xFF0000
color3:    .word 0x00FF00
color4:    .word 0xFFFF00
color5:    .word 0x000000
askt:      .string "\nDo you want to play again? press UP for yes, other for no.\n"
askt1:     .string "Play Hard or eazy? press UP for Hard, other for Eazy.\n"

.globl main
.text

main:
    # TODO: Before we deal with the LEDs, we need to generate a random
    # sequence of numbers that we will use to indicate the button/LED
    # to light up. For example, we can have 0 for UP, 1 for DOWN, 2 for
    # LEFT, and 3 for RIGHT. Store the sequence in memory. We provided 
    # a declaration above that you can use if you want.
    # HINT: Use the rand function provided to generate each number
    
    lw s6, count
    li s8, 1001
    
    li a7, 4 	
	la a0, askt1	
	ecall 
    call pollDpad
    beq a0, zero, Hard1

main1:
    mv a0, s6
    li a7, 1
	ecall 
    la t2, sequence
    mv t1, s6
    WHILE:
        lw a0, count
        call rand
        sb a0, (0)t2
        addi t2, t2, 8
        addi t1, t1, -1
        bne t1, zero, WHILE
    
   
    # TODO: Now read the sequence and replay it on the LEDs. You will
    # need to use the delay function to ensure that the LEDs light up 
    # slowly. In general, for each number in the sequence you should:
    # 1. Figure out the corresponding LED location and colour
    # 2. Light up the appropriate LED (with the colour)
    # 2. Wait for a short delay (e.g. 500 ms)
    # 3. Turn off the LED (i.e. set it to black)
    # 4. Wait for a short delay (e.g. 1000 ms) before repeating
    la t4, sequence
    mv t5, s6
    WHILE1:
        lb a0, (0)t4
        call CXY
        lw a0, color1
        call setLED
        mv a0, s8
        call delay
        lb a0, (0)t4
        call CXY
        lw a0, color5
        call setLED
        mv a0, s8
        call delay
        addi t4, t4, 8
        addi t5, t5, -1
        bne t5, zero, WHILE1

    li s4, 4
    call Flash

    # TODO: Read through the sequence again and check for user input
    # using pollDpad. For each number in the sequence, check the d-pad
    # input and compare it against the sequence. If the input does not
    # match, display some indication of error on the LEDs and exit. 
    # Otherwise, keep checking the rest of the sequence and display 
    # some indication of success once you reach the end.
    Ck:
    la t4, sequence
    mv t5, s6
    li s4, 4
    WHILE2:
        lb t6, (0)t4
        call pollDpad
        mv s5, a0
        
        call CXY
        lw a0, color4
        call setLED
        li a0, 300
        call delay
        mv a0, s5
        call CXY
        lw a0, color5
        call setLED
        
        bne s5, t6, Lost
        addi t4, t4, 8
        addi t5, t5, -1
        bne t5, zero, WHILE2
        beq t5, zero, Win
        
    # TODO: Ask if the user wishes to play again and either loop back to
    # start a new round or terminate, based on their input.
    ctu:
        lw a0, color5
        call Rest
    Ask:
        li a7, 4 	
	    la a0, askt	
	    ecall 
        call pollDpad
        beq a0, zero, Hard
 
exit:
    li a7, 10
    ecall
    
    
# --- HELPER FUNCTIONS ---
# Feel free to use (or modify) them however you see fit
     
# Takes in the number of milliseconds to wait (in a0) before returning
delay:
    mv t0, a0
    li a7, 30
    ecall
    mv t1, a0
delayLoop:
    ecall
    sub t2, a0, t1
    bgez t2, delayIfEnd
    addi t2, t2, -1
delayIfEnd:
    bltu t2, t0, delayLoop
    jr ra

# Takes in a number in a0, and returns a (sort of) random number from 0 to
# this number (exclusive)
rand:
    mv t0, a0
    li a7, 30
    ecall
    remu a0, a0, t0
    jr ra
    
# Takes in an RGB color in a0, an x-coordinate in a1, and a y-coordinate
# in a2. Then it sets the led at (x, y) to the given color.
setLED:
    li t1, LED_MATRIX_0_WIDTH
    mul t0, a2, t1
    add t0, t0, a1
    li t1, 4
    mul t0, t0, t1
    li t1, LED_MATRIX_0_BASE
    add t0, t1, t0
    sw a0, (0)t0
    jr ra
    
# Polls the d-pad input until a button is pressed, then returns a number
# representing the button that was pressed in a0.
# The possible return values are:
# 0: UP
# 1: DOWN
# 2: LEFT
# 3: RIGHT
pollDpad:
    mv a0, zero
    li t1, 4
pollLoop:
    bge a0, t1, pollLoopEnd
    li t2, D_PAD_0_BASE
    slli t3, a0, 2
    add t2, t2, t3
    lw t3, (0)t2
    bnez t3, pollRelease
    addi a0, a0, 1
    j pollLoop
pollLoopEnd:
    j pollDpad
pollRelease:
    lw t3, (0)t2
    bnez t3, pollRelease
pollExit:
    jr ra



CXY:
    li s1, 1
    li s2, 2
    li s3, 3
    beq a0, zero, X0
    beq a0, s1, X1
    beq a0, s2, X2
    beq a0, s3, X3
X0:
    mv a1 zero
    mv a2 zero
    jr ra
X1:
    mv a1 s1
    mv a2 zero
    jr ra
X2:
    mv a1 zero
    mv a2 s1
    jr ra
X3:
    mv a1 s1
    mv a2 s1
    jr ra


Lost:
    addi s4, s4, -1
    mv a0, s4
    call CXY
    lw a0, color2
    call setLED
    li a0, 200
    call delay
    beq s4, zero, Dhard
    j Lost
    
    
Win:
    addi s4, s4, -1
    mv a0, s4
    call CXY
    lw a0, color3
    call setLED
    li a0, 200
    call delay
    beq s4, zero, ctu
    j Win

Rest:
    mv s7, a0
    li a0, 1000
    call delay
    li a0, 0
    call CXY
    mv a0, s7
    call setLED
    li a0, 800
    call delay
    li a0, 3
    call CXY
    mv a0, s7
    call setLED
    li a0, 800
    call delay
    li a0, 1
    call CXY
    mv a0, s7
    call setLED
    li a0, 800
    call delay
    li a0, 2
    call CXY
    mv a0, s7
    call setLED
    j Ask
    
Hard:
    addi s6, s6, 1
    addi s8, s8, -10
    blt s8, zero, exit
    j main1
    
Dhard:
    addi s6, s6, -1
    addi s8, s8, 10
    j ctu
    
Flash:
    addi s4, s4, -1
    mv a0, s4
    call CXY
    lw a0, color4
    call setLED
    li a0, 150
    call delay
    mv a0, s4
    call CXY
    lw a0, color5
    call setLED
    beq s4, zero, Ck
    j Flash
    
Hard1:
    addi s6, s6, 4
    li s8, 501
    j main1