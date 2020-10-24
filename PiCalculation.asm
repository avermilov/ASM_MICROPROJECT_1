format PE console
entry start

include 'win32a.inc'


section '.code' code readable executable
    start:
        FINIT
        piLoop:
            ; calculating denominator of fraction that will be added: x1*x2*x3
            FLD [denominator]
            FMUL [zero]
            FADD [x1]
            FMUL [x2]
            FMUL [x3]
            FSTP [denominator]

            ; changing denominator product values for next loop: x1 +=2, x2 += 2, x3 += 2
            FLD [x1]
            FADD [stepValue]
            FSTP [x1]
            FLD [x2]
            FADD [stepValue]
            FSTP [x2]
            FLD [x3]
            FADD [stepValue]
            FSTP [x3]

            ;calculating numerator: multiplying numerator by -1
            FLD [numerator]
            FMUL [sign]
            FSTP [numerator]

            ; calculating fraction: +-4 / (x1 * x2 * x3)
            FLD [numerator]
            FDIV [denominator]
            FSTP [fraction]

            ; adding calculated fraction to our answer
            FLD [res]
            FADD [fraction]
            FSTP [res]

            ; printing current iteration and its result
            add [i], 1
            invoke printf, pi_string,[i], dword[res],dword[res+4]

            ; the comparison part
            FLD [res]
            FSUB [prev]
            FABS
            FCOM [accuracy]
            FSTSW AX
            SAHF
            jb endMet
    
            ; prev = res
            FLD [res]
            FSTP [prev]
            jmp piLoop

     endMet:
        ; printing total step count and required accuracy.
        invoke printf, steps_string, [i]
        invoke printf, answer_string,dword[accuracy],dword[accuracy+4]

        ; calculating error and getting machine pi
        FSTP [machine_pi]
        FLDPI
        FSTP [machine_pi]
        FLDPI
        FSUB [res]
        FABS
        FSTP [error]

        ; printing machine pi, our result and final error.
        invoke printf,accuracy_info, dword[machine_pi],dword[machine_pi+4],\
                                     dword[res],dword[res+4],\
                                     dword[error],dword[error+4]

        invoke getch
        invoke ExitProcess, 0

section '.data' data readable writable
        ; strings for output
        steps_string db "Calculation completed. The Nilakantha Series took %d steps.",10,0
        pi_string db "Iteration %d. Calculated Pi = %lf", 10, 0
        answer_string db "Required accuracy: %lf. ",10,0
        accuracy_info db "Machine Pi: %lf. Final answer: %lf. Resulting error: %lf.",10,0

        ; variables used to calculate the answer and exit conditions
        res dq 3.0
        x1 dq 2.0
        x2 dq 3.0
        x3 dq 4.0
        stepValue dq 2.0
        fraction dq 0.0
        numerator dq -4.0
        denominator dq 0.0
        sign dq -1.0
        zero dq 0.0
        i dd 0
        accuracy dq 0.0005
        prev dq 3.0
        machine_pi dq ?
        error dq ?


section '.idata' import data readable
    library kernel, 'kernel32.dll',\
                msvcrt, 'msvcrt.dll',\
                user32,'USER32.DLL'

    include 'api\user32.inc'
    include 'api\kernel32.inc'
        import kernel,\
               ExitProcess, 'ExitProcess',\
               HeapCreate,'HeapCreate',\
               HeapAlloc,'HeapAlloc'
        include 'api\kernel32.inc'
        import msvcrt,\
               printf, 'printf',\
               sprintf, 'sprintf',\
               scanf, 'scanf',\
               getch, '_getch'  