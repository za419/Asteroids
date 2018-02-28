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

;; Sprite bitmaps
EXTERNDEF fighter_000:EECS205BITMAP

OBJECTS_SIZE = 100 ;; Constant of max game objects

.DATA

    GameObjects GameObject ? DUP(OBJECTS_SIZE)

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

GameInit PROC USES eax edi

    ;; Initialize the player (who is always the first object in the GameObjects array)
    mov edi, OFFSET GameObjects
    mov (GameObject PTR [edi]).sprite, OFFSET fighter_000
    mov (GameObject PTR [edi]).xcenter, 320
    mov (GameObject PTR [edi]).ycenter, 240
    mov (GameObject PTR [edi]).xvelocity, ONE
    mov (GameObject PTR [edi]).yvelocity, ZERO
    mov (GameObject PTR [edi]).rotation, ZERO

    ;; Spawn the player with sixteen frames of rotational velocity
    INVOKE FixedMultiply, ROT_INC, 00100000h
    mov (GameObject PTR [edi]).rvelocity, eax
	ret         ;; Do not delete this line!!!
GameInit ENDP

;; Draws a game object using RotateBlit, checking for null-ness
DrawGameObject PROC USES eax ebx esi ptrObject:PTR GameObject

    mov esi, ptrObject
    cmp (GameObject PTR [esi]).sprite, 0 ;; Null check
    je SKIP

    INVOKE RotateBlit, (GameObject PTR [esi]).sprite, (GameObject PTR [esi]).xcenter, (GameObject PTR [esi]).ycenter, (GameObject PTR [esi]).rotation
SKIP:
    ret
DrawGameObject ENDP

;; Draws all game objects, in order
DrawGame PROC

    ;; Initializer
    mov esi, OFFSET GameObjects
    mov ecx, 0

TOP: ;; Drawing loop
    INVOKE DrawGameObject, esi
    inc ecx
    add esi, SIZEOF GameObject

    ;; Condition
    cmp ecx, OBJECTS_SIZE
    jl TOP
    ret
DrawGame ENDP

;; Ticks a game object
UpdateGameObject PROC USES eax ptrObject:PTR GameObject

    mov esi, ptrObject

    ;; First, update x coordinate
    INVOKE ToFixedPoint, (GameObject PTR [esi]).xcenter
    INVOKE FixedAdd, eax, (GameObject PTR [esi]).xvelocity
    mov (GameObject PTR [esi]).xcenter, eax

    ;; Now, update y coordinate
    INVOKE ToFixedPoint, (GameObject PTR [esi]).ycenter
    INVOKE FixedAdd, eax, (GameObject PTR [esi]).yvelocity
    mov (GameObject PTR [esi]).ycenter, eax

    ;; Finally, update rotation
    INVOKE FixedAdd, (GameObject PTR [esi]).rotation, (GameObject PTR [esi]).rvelocity
    mov (GameObject PTR [esi]).rotation, eax
    ret
UpdateGameObject ENDP

;; Updates all game objects, in order
UpdateGame PROC

    ;; Initializer
    mov esi, OFFSET GameObjects
    mov ecx, 0

TOP: ;; Tick loop
    INVOKE UpdateGameObject, esi
    inc ecx
    add esi, SIZEOF GameObject

    ;; Condition
    cmp ecx, OBJECTS_SIZE
    jl TOP
    ret
UpdateGame ENDP

GamePlay PROC

    INVOKE DrawGame
    INVOKE UpdateGame
	ret         ;; Do not delete this line!!!
GamePlay ENDP

END
