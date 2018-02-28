; #########################################################################
;
;   game.inc - Includes for EECS205 Assignment 4/5
;
;
; #########################################################################

;; Library Definitions
MouseInfo STRUCT
 horiz DWORD ?
 vert  DWORD ?
 buttons DWORD ?
MouseInfo ENDS

MK_CONTROL  = 0008h  ;; The CTRL key is down.
MK_LBUTTON  = 0001h  ;; The left mouse button is down.
MK_MBUTTON  = 0010h  ;; The middle mouse button is down.
MK_RBUTTON  = 0002h  ;; The right mouse button is down.
MK_SHIFT    = 0004h  ;; The SHIFT key is down.
MK_XBUTTON1 = 0020h  ;; The first X button is down.
MK_XBUTTON2 = 0040h  ;; The second X button is down.


;; FXPT constants
ONE = 00010000h
HALF = 00008000h
ZERO = 00000000h
PI_HALF = 102943           	;;  PI / 2
PI =  205887	                ;;  PI
ROT_INC = 00000648h ;; Increment for rotation: PI/64
ACCEL = 00002000h ;; Increment for linear acceleration: one quarter-pixel per frame

;; Library Functions
BlackStarField	PROTO
DrawStr PROTO myStr:PTR BYTE, x:DWORD, y:DWORD, color:DWORD

;; Library Data
EXTERNDEF StarBitmap:EECS205BITMAP
EXTERNDEF MouseStatus:MouseInfo
EXTERNDEF KeyUp:DWORD
EXTERNDEF KeyDown:DWORD
EXTERNDEF KeyPress:DWORD

;; User Defined Functions
GameInit PROTO
GamePlay PROTO
CheckIntersect PROTO oneX:DWORD, oneY:DWORD, oneBitmap:PTR EECS205BITMAP, twoX:DWORD, twoY:DWORD, twoBitmap:PTR EECS205BITMAP

;; Game object structures
GameObject STRUCT
    sprite DWORD ? ;; Pointer to sprite representing this GameObject. Null if this is empty
    xcenter DWORD ?
    ycenter DWORD ?
    xvelocity FXPT ?
    yvelocity FXPT ?
    rotation FXPT ?
    rvelocity FXPT ?
GameObject ENDS


