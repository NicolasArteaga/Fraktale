.intel_syntax noprefix
.global tricorn_simd
.text
# void tricorn(float Real, float Imaginary, char* img);
# 
# parameters:
#      xmm0: argument 1 -> packed zReal
#      xmm1: argument 2 -> packed zImaginary
#       rdi: argument 3 -> pointer Image
#
# variables:
#      rdx: MAX_ITERATIONS = 100
#      rcx: Iteration counter
#       al: Red
#       dl: Green
#      r8b: Blue
#     xmm0: zReal
#     xmm1: zImaginary
#     xmm2: cReal
#     xmm3: cImaginary
#     xmm4: Helper
#     xmm5: Helper
#     xmm6: Counter
#     xmm7: Incrementor
#     xmm8: Helper
#     xmm9: Helper
#    xmm10: Counter comparison


tricorn_simd:
    push rdi
    push rbp                             # Push base pointer
    mov rbp, rsp                         # Create frame moving stack pointer to base pointer
    sub rsp, 80                          # Allocate 16*5 bytes for xmm6-10
    movdqu xmmword ptr [rsp], xmm6       # Save xmm6 due to calling conventions in the stack
    movdqu xmmword ptr [rsp+16], xmm7    # Save xmm7 due to calling conventions in the stack
    movdqu xmmword ptr [rsp+32], xmm8    # Save xmm8 due to calling conventions in the stack
    movdqu xmmword ptr [rsp+48], xmm9    # Save xmm9 due to calling conventions in the stack
    movdqu xmmword ptr [rsp+64], xmm10   # Save xmm10 due to calling conventions in the stack


    mov r8,0                             # Set r8 to 0
    cvtsi2ss xmm2, r8                    # Set cReal to 0
    cvtsi2ss xmm3, r8                    # Set cImaginary to 0
    pshufd xmm2, xmm2, 0x00              # Move 0 to all 4  32 bit registers quita
    pshufd xmm3, xmm3, 0x00              # Move 0 to all 4  32 bit registers quitar

    cvtsi2ss xmm6, r8                    # Set counter to packed integers in 0
    pshufd xmm6, xmm6, 0x00
    cvtps2dq xmm6, xmm6     

    mov r8,1                             # Set incrementor to packed integers in 1
    cvtsi2ss xmm7, r8
    pshufd xmm7, xmm7, 0x00
    cvtps2dq xmm7, xmm7     

    cvtsi2ss xmm10, r8                   # Set counter comparison to packed integers in 0
    pshufd xmm10, xmm10, 0x00
    cvtps2dq xmm10, xmm10

    mov rdx, 100                         # Set MAX_ITERATIONS
    mov rcx, 0                           # Set iteration counter

start_loop_simd:
    
    cmp rcx, rdx                         # If iteration counter > MAX_ITERATIONS
    jge end_tricorn_simd                 # then jump to end_loop

squareConjugate_simd:                    # Calculates the square and then the conjugate of packed [cReal,cImaginary]
                                         # Conjugate -> zImaginary negative
    mov r8, -1                           # Prepare r8 to calculate conjugate
    cvtsi2ss xmm4, r8                    # r8 to float in xmm4
    pshufd xmm4, xmm4, 0x00              # Move -1 to all 4  32 bit registers
    mulps xmm3, xmm4                     # Negate xmm3 cImaginary

                                         # Square:= (x, y)*i(x', y') -> (xx'-yy')+i(xy'+x'y)
    movups xmm4, xmm2                    # Set helper register to cReal
    movups xmm5, xmm3                    # Set helper register to cImaginary

    mulps xmm4, xmm4                     # Mul cReal * cReal
    mulps xmm5, xmm5                     # Mul cImaginary * zImaginary
    subps xmm4, xmm5                     # tmp = ((cReal * cReal) - (cImaginary * zImaginary))

    movups xmm5, xmm4                    # Set helper xmm5 as tmp 
    movups xmm4, xmm2                    # Retrieve cReal
    movups xmm2, xmm5                    # cReal_neu = tmp
   
    movups xmm5, xmm3                    # Set helper to cImaginary
    mulps xmm4, xmm5                     # tmp = cReal * cImaginary
    addps xmm4, xmm4                     # tmp * 2
    movups xmm3, xmm4                    # cImaginary = tmp * 2

complexAddition_simd:                    # Adds [cReal,cImaginary] to [zReal,zImaginary]  
    addps xmm2, xmm0                     # Add cReal = cReal + zReal
    addps xmm3, xmm1                     # Add cImaginary = cImaginary + zImaginary
    
    inc rcx                              # Increase the iteration counter
    addps xmm6, xmm7                     # Increase the counter

check_simd:                              # Checks if the [cReal,cImaginary] is unstable
    mov r8,-2                            # Set stability range form [-2,2] in both axis 
    cvtsi2ss xmm5,r8                     # of interval [-2, 2] it is unstable -> A bigger constant would not change almost anything. It's innecessary 
    pshufd xmm5,xmm5,0x00                # Move -2  to all four  32-bit registers

    mov r8,2            
    cvtsi2ss xmm4,r8
    pshufd xmm4,xmm4, 0x00               # Move 2 to all four 32-bit registers

    movdqu xmm8, xmm2                    # Save cReal
    movdqu xmm9, xmm3                    # Save cImaginary
                                         # If xmm2 has a Wert das divergiert
                                         # dieser Zone ist 0000 und wird bei xmm7 geändert,
                                         # also xmm6 andert sich nicht mehr

    cmpps xmm2,xmm5, 5                   # If -2 < cReal
    pand xmm7,xmm2                       # see line 111
    movdqu xmm2, xmm8                    # Restore xmm2 from xmm8
 
    cmpps xmm2,xmm4, 2                   # If 2 > cReal
    pand xmm7,xmm2                       # see line 111
    movdqu xmm2, xmm8                    # Restore xmm2 from xmm8

    cmpps xmm3,xmm5, 5                   # If zImaginary < -2
    pand xmm7,xmm3                       # see line 111
    movdqu xmm3, xmm9                    # Restore xmm3 from xmm9

    cmpps xmm3,xmm4, 2                   # If zImaginary > 2
    pand xmm7,xmm3                       # see line 111
    movdqu xmm3, xmm9                    # Restore xmm3 fom xmm9

    ptest xmm7, xmm10                    # If incrementor is zero for all the values, all the pixels did convert
    jz end_tricorn_simd                  # then stop calculating and paint

    jmp start_loop_simd                  # Calculate more iterations

end_tricorn_simd:                        # The counter in xmm6 will be now stored in rcx
    mov r11,4                            # set 4 iterations
    movd r10d, xmm6                      # Retrieve last counter
    pshufd xmm6, xmm6, 0x39              # Shuffle -> 00 11 10 01
    movd r9d, xmm6                       # Retrieve third counter
    pshufd xmm6, xmm6, 0x39              # Shuffle -> 00 11 10 01
    movd r8d, xmm6                       # Retrieve the second counter
    pshufd xmm6, xmm6, 0x39              # Shuffle -> 00 11 10 01
    movd ecx, xmm6                       # Retrieve first counter
    
    shl ecx,8                            # Put all the counters in ecx -> 4 * 8 = 32 bits
    mov cl,r8b 
    shl ecx,8
    mov cl,r9b
    shl ecx,8
    mov cl,r10b

end_loop_simd:
    cmp r11,0                            # End if there are no more counters left to store
    jz return_simd
    cmp cl, 100
    jz convergent_simd
                                         # Unstable -> rcx (counter) describes how unstable

    mov al, cl                           # Calculate red color
    imul ax,10
    add al,60
    mov dl, cl                           # Calculate green color
    imul dx,10
    add dl,100
    mov r8b, cl
    imul r8w,5                           # Calculate blue color
    neg r8w
    add r8b, 220

    mov byte ptr [rdi], r8b              # Paint in memory B = calc        
    mov byte ptr [rdi+1], dl             # Paint in memory G = calc         
    mov byte ptr [rdi+2], al             # Paint in memory R = calc
    add rdi, 3
    
    dec r11
    shr ecx,8
    jmp end_loop_simd

convergent_simd:
                                         # Stable
    xor al, al                           # B = 0
    xor dl, dl                           # G = 0
    xor r8b, r8b                         # R = 0
    mov byte ptr [rdi], r8b              # Paint in memory B = 0        
    mov byte ptr [rdi+1], dl             # Paint in memory G = 0          
    mov byte ptr [rdi+2], al             # Paint in memory R = 0
    add rdi, 3

    dec r11
    shr ecx,8
    jmp end_loop_simd

return_simd:
    movdqu xmm6, xmmword ptr [rsp]       # Restore xmm6 due to calling conventions
    movdqu xmm7, xmmword ptr [rsp+16]    # Restore xmm7 due to calling conventions in the stack
    movdqu xmm8, xmmword ptr [rsp+32]    # Restore xmm8 due to calling conventions in the stack
    movdqu xmm9, xmmword ptr [rsp+48]    # Restore xmm9 due to calling conventions in the stack
    movdqu xmm10, xmmword ptr [rsp+64]   # Restore xmm10 due to calling conventions in the stack
    mov rsp, rbp
    pop rbp         
    pop rdi                              # Pop base pointer
    ret 
