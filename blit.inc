; #########################################################################
;
;   blit.inc - Includes for EECS205 Assignment 3
;
;
; #########################################################################


_EECS205BITMAP STRUCT
 dwWidth      DWORD  ?
 dwHeight     DWORD  ?
 bTransparent BYTE   ?
              BYTE   3 DUP(?)
 lpBytes      DWORD  ?
_EECS205BITMAP ENDS

EECS205BITMAP TYPEDEF _EECS205BITMAP

;; Screen size constants
SCREEN_WIDTH = 640
SCREEN_HEIGHT = 480

;; Screen size as fixed point
SCREEN_WIDTH_FXPT = 02800000h
SCREEN_HEIGHT_FXPT = 01E00000h

EXTERNDEF ScreenBitsPtr:DWORD

BasicBlit PROTO STDCALL ptrBitmap:PTR EECS205BITMAP, xcenter:DWORD, ycenter:DWORD

RotateBlit PROTO STDCALL ptrBitmap:PTR EECS205BITMAP, xcenter:DWORD, ycenter:DWORD, angle:FXPT
	   

ToFixedPoint PROTO STDCALL a:SDWORD
FromFixedPoint PROTO STDCALL a:SDWORD



