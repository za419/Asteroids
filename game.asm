; #########################################################################
;
;   game.asm - Assembly file for EECS205 Assignment 4/5
;
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include stars.inc
include lines.inc
include trig.inc
include blit.inc
include game.inc

;; Has keycodes
include keys.inc


.DATA

;; If you need to, you can place global variables here


.CODE

;; Returns the absolute value of a
AbsoluteValue PROC a:SDWORD

    mov eax, a
    cmp eax, 0
    jge SKIP
    neg eax
SKIP:
    ret
AbsoluteValue ENDP

CheckIntersect PROC USES ebx, ecx oneX:DWORD, oneY:DWORD, oneBitmap:PTR EECS205BITMAP, twoX:DWORD, twoY:DWORD, twoBitmap:PTR EECS205BITMAP

    ;; ebx contains the sum of halfwidths as a DWORD (not FXPT)
    INVOKE ToFixedPoint, (EECS205BITMAP PTR [oneBitmap]).dwWidth
    INVOKE FixedMultiply, eax, HALF
    mov ebx, eax
    INVOKE ToFixedPoint, (EECS205BITMAP PTR [twoBitmap]).dwWidth
    INVOKE FixedMultiply, eax, HALF
    INVOKE FixedAdd, ebx, eax
    INVOKE FromFixedPoint, eax
    mov ebx, eax

    ;; ecx contains the sum of halfheights
    INVOKE ToFixedPoint, (EECS205BITMAP PTR [oneBitmap]).dwHeight
    INVOKE FixedMultiply, eax, HALF
    mov ecx, eax
    INVOKE ToFixedPoint, (EECS205BITMAP PTR [twoBitmap]).dwHeight
    INVOKE FixedMultiply, eax, HALF
    INVOKE FixedAdd, ecx, eax
    INVOKE FromFixedPoint, eax
    mov ecx, eax

    ;; If the difference between xcenters is greater than or equal to ebx, return 0
    mov eax, twoX
    sub eax, oneX
    INVOKE AbsoluteValue, eax
    cmp eax, ebx
    jl FALSE

    ;; If the difference between ycenters is greater than or equal to ecx, return 0
    mov eax, twoY
    sub eax, oneY
    INVOKE AbsoluteValue, eax
    cmp eax, ecx
    jl FALSE

    ;; If we get here, then there exists some overlap
    mov eax, 1
    jmp EXIT

FALSE:
    mov eax, 0
    ;; Fallthrough
EXIT:
    ret
CheckIntersect ENDP

GameInit PROC

	ret         ;; Do not delete this line!!!
GameInit ENDP


GamePlay PROC

	ret         ;; Do not delete this line!!!
GamePlay ENDP

END
