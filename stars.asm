; #########################################################################
;
;   stars.asm - Assembly file for EECS205 Assignment 1
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
      a db 14
      b db 46
.CODE

DrawStarField proc

	;; Place your code here
      ;; 20 coordinate pairs as chosen by random.org at 2018-01-19 07:33:16 UTC
      INVOKE DrawStar, 14, 46
      INVOKE DrawStar, 183, 194
      INVOKE DrawStar, 94, 468
      INVOKE DrawStar, 234, 465
      INVOKE DrawStar, 378, 382
      INVOKE DrawStar, 235, 369
      INVOKE DrawStar, 141, 334
      INVOKE DrawStar, 3, 257
      INVOKE DrawStar, 169, 196
      INVOKE DrawStar, 23, 229
      INVOKE DrawStar, 96, 238
      INVOKE DrawStar, 158, 205
      INVOKE DrawStar, 119, 276
      INVOKE DrawStar, 245, 437
      INVOKE DrawStar, 260, 410
      INVOKE DrawStar, 93, 365
      INVOKE DrawStar, 281, 443
      INVOKE DrawStar, 209, 476
      INVOKE DrawStar, 2, 23
      INVOKE DrawStar, 64, 127
	ret  			; Careful! Don't remove this line
DrawStarField endp



END
