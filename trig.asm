; #########################################################################
;
;   trig.asm - Assembly file for EECS205 Assignment 3
;
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include trig.inc

.DATA

;;  These are some useful constants (fixed point values that correspond to important angles)
PI_HALF = 102943           	;;  PI / 2
PI =  205887	                ;;  PI
TWO_PI	= 411774                ;;  2 * PI
PI_INC_RECIP =  5340353        	;;  Use reciprocal to find the table entry for a given angle
	                        ;;              (It is easier to use than divison would be)
ROUND_FACTOR = 00004000h        ;; Adjusts rounding behavior of lookup
ONE = 00010000h                 ;; ONE

	;; If you need to, you can place global variables here

.CODE

;; Handles fixed-point multiplication
;; (so if I make a mistake I can easily change this function to fix it)
FixedMultiply PROC USES edx a:FXPT, b:FXPT

    mov eax, a
    imul b ;; Treat a and b as integers
    ;; Integer part of the result is the lower word of edx
    ;; Decimal part of the result is the upper word of eax
    shl edx, 16 ;; Shift the results into being in place for fixed point
    shr eax, 16
    or  eax, edx ;; And or the results together
    ret
FixedMultiply ENDP

;; Handles fixed-point division
FixedDivide PROC USES edx a:FXPT, b:FXPT

    shl a, 16 ;; Offset x so that we get the correct representation
    xor edx,edx
    mov eax, a
    idiv b ;; Placing the correct quotient in eax
    ret
FixedDivide ENDP

;; Handles fixed-point subtraction
;; (so if I make a mistake I can easily change this function to fix it)
FixedSubtract PROC a:FXPT, b:FXPT

    mov eax, a
    sub eax, b
    ret
FixedSubtract ENDP

;; Handles fixed-point addition
;; (so if I make a mistake I can easily change this function to fix it)
FixedAdd PROC a:FXPT, b:FXPT

    mov eax, a
    add eax, b
    ret
FixedAdd ENDP

FixedSin PROC USES ebx angle:FXPT

    cmp angle, 0 ;; This code doesn't account for negative angles.
    jl FIXER ;; FIXER will recurse to make the angle positive

    ;; Slight edge optimization: If the input is exactly 0, return 0 instead of a value very near it (avoiding the overhead of a lookup)
    je EXACT0

	cmp angle, PI_HALF ;; If the angle is less than pi/2, we can do a table lookup
    jl LOOKUP ;; If it is, jump into the lookup

    ;; Slight edge optimization: If the input is exactly pi/2, return 1 instead of a value very near it (avoiding the overhead of a lookup)
    je EXACT1

    cmp angle, TWO_PI ;; If the angle is greater than pi/2, recurse on angle-[pi/2]
    jg CIRCLED ;; CIRCLED will handle that recursion
    je EXACT0

    cmp angle, PI ;; If the angle is greater than pi, recurse on angle-pi and negate the result
    jg NEGATE ;; NEGATE will handle that recursion
    je EXACT0

    ;; If we're here, that means PI_HALF<angle<pi
    ;; That means we should use the third identity.
    ;; Subtract angle from pi and recurse.
    INVOKE FixedSubtract, PI, angle ;; Subtract angle from pi...
    INVOKE FixedSin, eax ;; Recurse on the result
    jmp EXIT ;; Return the result of that recursion.

FIXER: ;; Add 2*pi to the angle and recurse (eventually thus making it positive even for very negative angles)
    INVOKE FixedAdd, angle, TWO_PI
    INVOKE FixedSin, eax
    jmp EXIT ;; Return the result of the recursion

EXACT0:
    mov eax, 0
    jmp EXIT

EXACT1:
    mov eax, ONE
    jmp EXIT

NEGATE: ;; pi<=angle
    INVOKE FixedSubtract, angle, PI ;; Subtract pi
    INVOKE FixedSin, eax ;; Recurse on the result
    neg eax ;; Negate the result
    jmp EXIT ;; And return it.

CIRCLED: ;; 2*pi<=angle
    INVOKE FixedSubtract, angle, TWO_PI ;; Subtract 2*pi
    INVOKE FixedSin, eax ;; Recurse on the result
    jmp EXIT ;; And return the result.

LOOKUP: ;; angle<pi/2
    INVOKE FixedMultiply, angle, PI_INC_RECIP ;; Calculate the table index
    INVOKE FixedAdd, eax, ROUND_FACTOR ;; Round away from zero
    shr eax, 15 ;; Shift out the decimal part (round-to-zero)
    and eax, 0fffffffeh ;; Make sure the index is on a word boundary
    mov ebx, OFFSET SINTAB
    add ebx, eax
    movzx eax, WORD PTR [ebx] ;; Dereference and move result into eax
    ;; Fallthrough to exit
EXIT:
	ret			; Don't delete this line!!!
FixedSin ENDP

FixedCos PROC angle:FXPT

    ;; Optimizations for known values and bounds checking
    cmp angle, 0
    jl NEGATE ;; Recurse on negative factors
    je RETONE ;; Return one for known value

    cmp angle, PI_HALF
    je ZERO ;; Return zero for known value

    mov eax, PI_HALF
    neg eax
    cmp angle, eax
    je ZERO ;; Return zero for known value

    cmp angle, PI
    je NEGONE ;; Return negative one for known value

    ;; General case: Use our trig identity
    ;; Use FixedSin: cos(x)=sin(x+[pi/2])
    INVOKE FixedAdd, angle, PI_HALF ;; eax=angle+[pi/2]
    INVOKE FixedSin, eax ;; eax=sin(eax)
    ;; And return that result
    jmp DONE

RETONE: ;; Return 1
    mov eax, ONE
    jmp DONE

ZERO: ;; Return 0
    mov eax, 0
    jmp DONE

NEGONE: ;; Return negative one
    mov eax, ONE
    neg eax
    jmp DONE

NEGATE: ;; Add 2*pi and recurse
    INVOKE FixedAdd, angle, TWO_PI
    INVOKE FixedCos, eax
    ;; Fallthrough to return
DONE:
	ret			; Don't delete this line!!!
FixedCos ENDP
END
