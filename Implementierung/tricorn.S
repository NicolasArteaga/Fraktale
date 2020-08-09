.intel_syntax noprefix
.global tricorn

.text
# void tricorn(float Real, float Imaginary, char* img);
# 
# parameters:
#      xmm0: argument 1 -> zReal
#      xmm1: argument 2 -> zImaginary
#       rdi: argument 3 -> pointer Image
#
# variables:
#      rdx: MAX_ITERATIONS = 100
#      rcx: Iteration counter
#     xmm0: zReal
#     xmm1: zImaginary
#     xmm2: cReal
#     xmm3: cImaginary
#     xmm4: Helper
#     xmm5: Helper


tricorn:  
    
    mov r8,0                        # Set r8 to 0
    cvtsi2ss xmm2, r8               # Set cReal to 0
    cvtsi2ss xmm3, r8               # Set cImaginary to 0

    mov rdx, 100                    # Set MAX_ITERATIONS
    mov rcx, 0                      # Set iteration counter

start_loop:
    cmp rcx, rdx                    # If iteration counter > MAX_ITERATIONS
    jge end_loop                    # then jump to end_loop

squareConjugate:                    # Calculates the square and then the conjugate of [cReal,cImaginary]
                                    # Conjugate -> zImaginary negative
    mov r8, -1                      # Prepare r8 to calculate conjugate
    cvtsi2ss xmm4, r8               # r8 to float in xmm4
    mulps xmm3, xmm4                # Negate xmm3 cImaginary

                                    # Square:= (x, y)*i(x', y') -> (xx'-yy')+i(xy'+x'y)
    movups xmm4, xmm2               # Set helper register to cReal
    movups xmm5, xmm3               # Set helper register to cImaginary

    mulps xmm4, xmm4                # Mul cReal * cReal
    mulps xmm5, xmm5                # Mul cImaginary * zImaginary
    subps xmm4, xmm5                # tmp = ((cReal * cReal) - (cImaginary * zImaginary))

    movups xmm5, xmm4               # Set helper xmm5 as tmp
    movups xmm4, xmm2               # Retrieve cReal
    movups xmm2, xmm5               # cReal_neu = tmp
   
    movups xmm5, xmm3               # Set helper to cImaginary
    mulps xmm4, xmm5                # tmp = cReal * cImaginary
    addps xmm4, xmm4                # tmp * 2
    movups xmm3, xmm4               # cImaginary = tmp * 2

complexAddition:                    # Adds [cReal,cImaginary] to [zReal,zImaginary]  
    addss xmm2, xmm0                # Add cReal = cReal + zReal
    addss xmm3, xmm1                # Add cImaginary = cImaginary + zImaginary
    
    inc rcx                         # Increase the iteration counter

check:                              # Checks if the [cReal,cImaginary] is unstable
    mov r8,-2                       # Set stability range form [-2,2] in both axis
    cvtsi2ss xmm5,r8                
    mov r8,2            
    cvtsi2ss xmm4,r8

    ucomiss xmm2,xmm5               # If -2 < cReal
    jb unstable                     # then go to calculate how unstable

    ucomiss xmm2,xmm4               # If 2 > cReal
    ja unstable                     # then go to calculate how unstable

    ucomiss xmm3,xmm5               # If zImaginary < -2
    jb unstable                     # then go to calculate how unstable

    ucomiss xmm3,xmm4               # If zImaginary > 2
    ja unstable                     # then go to calculate how unstable

    mov rax,0                       # Rcx = 0 -> stable
    jmp finish_check

unstable:
    mov rax,rcx
    
finish_check:
    cmp rax, 0                      # If rax = 0
    je start_loop                   # then go back and calculate next iteration
    # Scalar color choosed thanks to: https://www.rapidtables.com/web/color/RGB_Color.html
    mov al, cl                      # Calculate red color
    imul ax,10
    add al,60
    mov dl, cl                      # Calculate green color
    imul dx,10
    add dl,100
    imul cx,5                       # Calculate blue color
    neg cx
    add cl, 220

    mov byte ptr [rdi], cl          # Paint in memory B = calc        
    mov byte ptr [rdi+1], dl        # Paint in memory G = calc        
    mov byte ptr [rdi+2], al        # Paint in memory R = calc
    ret
end_loop:
                                    # Stable
    xor al, al                      # B = 0
    xor dl, dl                      # G = 0
    xor cl, cl                      # R = 0
    mov byte ptr [rdi], cl          # Paint in memory B = 0        
    mov byte ptr [rdi+1], dl        # Paint in memory G = 0         
    mov byte ptr [rdi+2], al        # Paint in memory R = 0
    ret
