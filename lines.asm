; #########################################################################
;
;   lines.asm - Assembly file for EECS205 Assignment 2
;
;   Modified by: Ryan Hodin (NetID rah025)
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include stars.inc
include lines.inc

.DATA

	;; If you need to, you can place global variables here

.CODE


;; Don't forget to add the USES the directive here
;;   Place any registers that you modify (either explicitly or implicitly)
;;   into the USES list so that caller's values can be preserved

;;   For example, if your procedure uses only the eax and ebx registers
;;      DrawLine PROC USES eax ebx x0:DWORD, y0:DWORD, x1:DWORD, y1:DWORD, color:DWORD
DrawLine PROC USES eax ebx ecx edx esi x0:DWORD, y0:DWORD, x1:DWORD, y1:DWORD, color:DWORD
	;; Feel free to use local variables...declare them here
	;; For example:
	;; 	LOCAL foo:DWORD, bar:DWORD
    LOCAL deltax:DWORD, deltay:DWORD, ix:DWORD, iy:DWORD
    
	;; Place your code here
    ;; First, setup deltax and deltay with absolute values
      ;; delta_x = abs(x1-x0)
      mov eax, x1
      sub eax, x0
      jge L1 ; Only negate if x1<x0, that is if (x1-x0)<0
      neg eax
   L1:
      mov deltax, eax

      ;; delta_y = abs(y1-y0)
      mov eax, y1
      sub eax, y0
      jge L2 ; Only negate if y1<y0, that is if (y1-y0)<0
      neg eax
   L2:
      mov deltay, eax

    ;; Now, setup increments
      ;; if (x0<x1) inc_x=1 else inc_x = -1
      mov eax, x0
      mov ix, 1 ; Set ix to 1
      cmp eax, x1
      jl L3
      neg ix ; Negate ix iff x0>=x1

   L3:
      ;; if (y0<y1) inc_y=1 else inc_y = -1
      mov eax, y0
      mov iy, 1
      cmp eax, y1
      jl L4
      neg iy ; Negate iy iff y0>=y1

    ;; Now, setup error
   L4:
      ;; if (delta_x>delta_y) ...
      mov eax, deltax
      xor edx, edx ; Null edx for idiv - Note that this is a recognized zeroing idiom on all CPUs, and therefore is strictly better than mov edx, 0
      mov ebx, 2 ; For idiv
      cmp eax, deltay ; Actual comparison
      jle L5
      ;; error=delta_x/2
      idiv ebx ; eax=delta_x/2
      jmp L6
   L5:
      ;; else error=-delta_y/2
      mov eax, deltay ; To correctly divide deltay
      idiv ebx ; eax=delta_y/2
      neg eax ; eax=-delta_y/2

   L6: ; By here, eax is error
    ;; Setup current coords
      ;; curr_x=x0
      ;; curr_y=y0
      mov ebx, x0 ; ebx is curr_x
      mov ecx, y0 ; ecx is curr_y

    ;; Now, the drawing loop.
    ;; First, the conditional
 COND:
      ;; while (curr_x!=x1 OR curr_y!=y1)
      cmp ebx, x1
      jne BODY ; Jump to body if curr_x!=x1
      cmp ecx, y1
      jne BODY ; Jump to body if curr_y!=y1
	ret ; If neither condition is met, the loop is complete and we return

    ;; Loop body
 BODY:
      ;; DrawPixel(curr_x, curr_y, color)
      invoke DrawPixel, ebx, ecx, color

      ;; prev_error=error
      mov edx, eax ; edx is prev_error

      ;; if (prev_error>-delta_x)
      mov esi, deltax ; So we can negate deltax
      neg esi
      cmp edx, esi
      jle L7
      ;; error=error-delta_y
      ;; curr_x=curr_x+inc_x
      sub eax, deltay
      add ebx, ix

   L7:
      ;; if (prev_error<delta_y)
      cmp edx, deltay
      jge COND ; If prev_error>=delta_y, jump back to the conditional early. Else...
      ;; error=error+delta_x
      ;; curr_y=curr_y=inc_y
      add eax, deltax
      add ecx, iy
      jmp COND ; Jump back to the conditional
DrawLine ENDP

END
