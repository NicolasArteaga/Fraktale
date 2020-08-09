.intel_syntax noprefix
.global tricorn

# the idea of our algorithm in c can be found under ../c/tricorn

# void tricorn(float Real, float Imaginary, char* img);
# 
# parameters:
#      xmm0: zReal
#      xmm1: zImaginary
#       rdi: pointer Image
#
# local variables:
#   - rdx: constant: max iterations (i in formula)
#   - rcx: iteration count
#   - xmm0   = zReal
#   - xmm1   = zImaginary
#   - xmm2   = cReal
#   - xmm3   = cImaginary

.text
tricorn:  
    
    # First Function Iteration C=0
    mov r8,0
    cvtsi2ss xmm2, r8
    cvtsi2ss xmm3, r8

    mov rdx, 100        # max iteration number
    mov rcx, 0          # loop counter

start_loop:
    cmp rcx, rdx
    jge end_loop

squareConjugate:        # squares and conjugates z
    mov r8, -1
    cvtsi2ss xmm4, r8
    mulps xmm3, xmm4   # zImaginary negative -> conjugate

    # (x, y)* i(x', y') -> (xx'-yy')+i(xy'+x'y) -> square
    movups xmm4, xmm2  # helper registers
    movups xmm5, xmm3  # helper registers

    mulps xmm4, xmm4  # xx'
    mulps xmm5, xmm5  # yy'
    subps xmm4, xmm5  # (xx'-yy')

    movups xmm5, xmm4 # xmm5 as temp
    movups xmm4, xmm2
    movups xmm2, xmm5  # xmm0 = (xx'-yy')
   
    movups xmm5, xmm3
    mulps xmm4, xmm5  # xy'
    addps xmm4, xmm4  # (xy'+x'y), since x=x' and y=y'
    movups xmm3, xmm4  # xmm1 = (xy'+x'y)

complexAddition:        # adds z and c    
    addss xmm2, xmm0    
    addss xmm3, xmm1
    
    inc rcx             # loop continuation

check:                  # checks if unstable 
    mov r8,-2           # constants we compare with, if number out
    cvtsi2ss xmm5,r8    # of interval [-2, 2] it is unstable
    mov r8,2            
    cvtsi2ss xmm4,r8

    ucomiss xmm2,xmm5   # cmp -2 < x -> false
    jb unstable

    ucomiss xmm2,xmm4  # cmp 1 > x -> false
    ja unstable

    ucomiss xmm3,xmm5  # cmp -1 < x -> false
    jb unstable

    ucomiss xmm3,xmm4  # cmp 1 > x -> false
    ja unstable

    mov rax,0           # not unstable
    jmp finish_check

unstable:
    mov rax,rcx
    
finish_check:
    cmp rax, 0
    je start_loop

                # Unstable -> rcx (counter) describes how unstable
                # Scalar color choosed thanks to: https://www.rapidtables.com/web/color/RGB_Color.html
      
    mov al, cl                          # Scalaring red color
    imul ax,10
    add al,60
    mov dl, cl                          # Scalaring green color
    imul dx,10
    add dl,100
    imul cx,5                           # Scalaring blue color
    neg cx
    add cl, 220

    mov byte ptr [rdi], cl               # pintar en la memoria B = 255        
    mov byte ptr [rdi+1], dl             # pintar en la memoria G = 255        
    mov byte ptr [rdi+2], al             # pintar en la memoria R = 255
    # Calcular colores y guardar en memoria, usar el counter rcx
    ret
end_loop:
                                         # Stable
    xor al, al                           # B = 0
    xor dl, dl                           # G = 0
    xor cl, cl                           # R = 0
    mov byte ptr [rdi], cl               # pintar en la memoria B = 0        
    mov byte ptr [rdi+1], dl             # pintar en la memoria G = 0         
    mov byte ptr [rdi+2], al             # pintar en la memoria R = 0        # stable -> returns 0 rcx = 100
    ret
