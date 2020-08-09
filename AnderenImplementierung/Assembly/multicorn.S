# ========================== #
#  Bienvenidos al Infierno   #
# ========================== #
.intel_syntax noprefix
.global multicorn

.text
# void multicorn(float r_start, float r_end, float i_start, float i_end,
#                float res, unsigned char* img)
# parameters:
#      xmm0: argument 1 -> Real part starting point
#      xmm1: argument 2 -> Real part ending point
#      xmm2: argument 3 -> Imaginary part starting point
#      xmm3: argument 4 -> Imaginary part ending point
#      xmm4: argument 5 -> Given resolution
#      rdi: argument 6 ->  Pointer to the start of the image
# variables:
#      eax: 1
#      rax: Width
#     xmm6: Starting point real number
#     xmm7: Ending point real number
#     xmm8: Starting point imaginary number
#     xmm9: Ending point imaginary number
#    xmm10: Resolution
#    xmm11: Column counter
#    xmm12: Distance
#      rbx: Padding -> padding = 4-(((end_re-start_re)*res))*3) MOD 4
#       r12: Pixels per row
#       r13: Remaining pixels per row
#       r14: Remaining rows per image

multicorn:
    push rbp                             # Push base pointer
    mov rbp, rsp                         # Create frame moving stack pointer to base pointer
    sub rsp, 112                         # Allocate 16*7 bytes for xmm6-12
    movdqu xmmword ptr [rsp], xmm6       # Save xmm6 due to calling conventions in the stack
    movdqu xmmword ptr [rsp+16], xmm7    # Save xmm7 due to calling conventions in the stack
    movdqu xmmword ptr [rsp+32], xmm8    # Save xmm8 due to calling conventions in the stack
    movdqu xmmword ptr [rsp+48], xmm9    # Save xmm9 due to calling conventions in the stack
    movdqu xmmword ptr [rsp+64], xmm10   # Save xmm10 due to calling conventions in the stack
    movdqu xmmword ptr [rsp+80], xmm11   # Save xmm11 due to calling conventions in the stack
    movdqu xmmword ptr [rsp+96], xmm12   # Save xmm12 due to calling conventions in the stack
    push rdi                             # Push rdi into the stack due to calling conventions
    push rbx                             # Push rbx into the stack due to calling conventions
    push r12                             # Push r12 into the stack due to calling conventions
    push r13                             # Push r13 into the stack due to calling conventions 
    push r14                             # Push r14 into the stack due to calling conventions

    movss xmm6, xmm0                     # Real part starting point -> xmm6
    movss xmm7, xmm1                     # Real part ending point -> xmm7
    movss xmm8, xmm2                     # Imaginary part starting point -> xmm8
    movss xmm9, xmm3                     # Imaginary part ending point -> xmm9
    movss xmm10,xmm4                     # Resolution

    subss xmm3, xmm2                     # im_range = im_end - im_start
    mulss xmm3, xmm4                     # height = res * im_range => rows per image left to calculate
    cvtss2si r14, xmm3                   # Change width to int in rax
   
                                         # Padding = 4 - ((width)*3) MOD 4
    subss xmm1, xmm0                     # r_range = r_end - r_start
    mulss xmm1, xmm4                     # width = res * r_range
    cvtss2si rax, xmm1                   # Change width to int in rax
    mov r12, rax                         # Number of pixels per row in r12
    mov r13, rax                         # Prepare number of pixels left per row in r13
    mov rbx, 3                           # Move 3 to rbx in order to multiply
    mul rbx                              # Width * 3 in rdx:rax but should only occupy rax
    and rax, 3                           # (width * 3) MOD 4
    cmp rax,0                            # if (width * 3) MOD 4 == 0 => no padding
    je no_pad

    mov rbx, 4                           # Setup rbx to 4 for the substraction
    sub rbx, rax                         # rbx = 4 - ((width * 3) MOD 4) => Padding
    jmp pad

no_pad:
    mov rbx, 0                           # No need for padding bc multiple of 4

pad:
    mov eax, 0x1                         # Assign one to eax
    cvtsi2ss xmm12, eax                  # Convert eax to ss float in xmm12
    divss xmm12, xmm10                   # 1/res = distance

outerLoop:
                                         # xmm8 is the starting point of the pixel rows
    cmp r14, 0                           # If no rows per image are left to calculate 
    je endOuterLoop                      # Jump to endOuterLoop
    movss xmm11, xmm6                    # Set column counter to the start of the pixel columns

innerLoop:
    cmp r13, 0                           # If no pixels per row are left to calculate 
    je endInnerLoop                      # Jump to endInnerLoop

tricorn_asm:                             # Call tricorn(col_c, row_c, *img)
    movss xmm0, xmm11                    # Column counter to xmm0
    movss xmm1, xmm8                     # Row counter to xmm1
    # pointer is already in rdi to be passed as an argument to another function
    call tricorn
    add rdi, 3                           # Prepare pointer for next pixel
    sub r13, 1                           # One pixel less to calculate per row
    addss xmm11, xmm12                   # Add distance between pixels to the column counter
    jmp innerLoop

endInnerLoop:
    addss xmm8, xmm12                    # Add distance between pixels to the row counter
    add rdi, rbx                         # Add padding at the end of the row
    mov r13, r12                         # Reassign remaining number of pixels
    dec r14                              # One row less per image to calculate
    jmp outerLoop                        # Jump to outerLoop to calculate the next row

endOuterLoop:
    pop r14                              # Pop r14 from the stack due to calling conventions
    pop r13                              # Pop r13 from the stack due to calling conventions
    pop r12                              # Pop r12 from the stack due to calling conventions
    pop rbx                              # Pop rbx from the stack due to calling conventions
    pop rdi                              # Pop rdi from the stack due to calling conventions
    movdqu xmm6, xmmword ptr [rsp]       # Restore xmm6 due to calling conventions
    movdqu xmm7, xmmword ptr [rsp+16]    # Restore xmm7 due to calling conventions in the stack
    movdqu xmm8, xmmword ptr [rsp+32]    # Restore xmm8 due to calling conventions in the stack
    movdqu xmm9, xmmword ptr [rsp+48]    # Restore xmm9 due to calling conventions in the stack
    movdqu xmm10, xmmword ptr [rsp+64]   # Restore xmm10 due to calling conventions in the stack
    movdqu xmm11, xmmword ptr [rsp+80]   # Restore xmm11 due to calling conventions in the stack
    movdqu xmm12, xmmword ptr [rsp+96]   # Restore xmm12 due to calling conventions in the stack
    mov rsp, rbp
    pop rbp                              # Pop base pointer
    ret 

