; #########################################################################
;
;   blit.asm - Assembly file for EECS205 Assignment 3
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

;; Prototypes for helpers in trig.asm
FixedMultiply PROTO STDCALL a:FXPT, b:FXPT
FixedSubtract PROTO STDCALL a:FXPT, b:FXPT
FixedAdd      PROTO STDCALL a:FXPT, b:FXPT


.DATA

    ONE_HALF = 00008000h ;; One half as a fixed point

.CODE

;; Helper function: Converts an integer to an FXPT
ToFixedPoint PROC USES ebx a:SDWORD

    mov eax, a
    mov ebx, 080000000h
    and ebx, eax ;; ebx contains only the sign bit
    shl eax, 16 ;; eax is now moved into only containing the lower 16 bits as an integer FXPT value

    cmp ebx, 080000000h
    jne DONE ;; If the sign bit was unset, we're done

    ;; If the sign bit was set, we need to make sure it is set in the result
    or eax, 080000000h
    ;; Fallthrough
DONE:
    ret
ToFixedPoint ENDP

;; Helper function: Converts an FXPT to an SDWORD
FromFixedPoint PROC a:FXPT

    mov eax, a
    sar eax, 16 ;; Preserve sign of eax
    ret
FromFixedPoint ENDP

;; Helper function: Convert an index into a 2D array into a 1D index
Index2D PROC x:DWORD, y:DWORD, xWidth:DWORD
    mov eax, y
    imul eax, xWidth
    add eax, x
    ret
Index2D ENDP

DrawPixel PROC USES eax ebx x:DWORD, y:DWORD, color:DWORD

    ;; Check for x out of range
    cmp x, SCREEN_WIDTH-1
    ja ERROR ;; Unsigned compare means that negatives (sign bit set) are treated as very large numbers

    ;; Check for y out of range
    cmp y, SCREEN_HEIGHT-1
    ja ERROR ;; Unsigned compare means that negatives (sign bit set) are treated as very large numbers

    ;; First, the address to write to
    mov ebx, ScreenBitsPtr ;; Pointer arithmetic inbound
    add ebx, x ;; Add offset into column
    imul eax, y, 640 ;; Compute offset for number of rows
    add ebx, eax ;; Add offset into pointer

    ;; Now, we get the color
    ;; We've been passed /a/ color...
    ;; But it's a DWORD, and we need a byte. We're going to take the lowest one.
    mov eax, color ;; Evil register byte-level "hacking"
    ;; al now contains our color byte. Told you it was evil...

    ;; Finally, move the color into the screen buffer at the computed position
    mov BYTE PTR [ebx], al

ERROR: ;; Just return on error...
    ;;    Technically, we should signal an error somehow, but I don't want to overwrite eax for a return value, and I am /not/ gonna touch implementing exceptions.
	ret 			; Don't delete this line!!!
DrawPixel ENDP

BasicBlit PROC USES eax ebx ecx edx esi edi ptrBitmap:PTR EECS205BITMAP , xcenter:DWORD, ycenter:DWORD
    LOCAL halfwidth:SDWORD, halfheight:SDWORD, dstWidth:DWORD, dstX:DWORD, dstY:DWORD

    ;; Use a register for faster lookup
    mov esi, ptrBitmap

    ;; Fill in local variables
    ;; halfwidth
    mov eax, (EECS205BITMAP PTR [esi]).dwWidth
    shr eax, 1
    mov halfwidth, eax

    ;; halfheight
    mov eax, (EECS205BITMAP PTR [esi]).dwHeight
    shr eax, 1
    mov halfheight, eax

    ;; dstWidth
    mov eax, (EECS205BITMAP PTR [esi]).dwWidth
    add eax, (EECS205BITMAP PTR [esi]).dwHeight
    mov dstWidth, eax

    ;; For loops
    ;; These are in the wrong order for proper cache coherency. But oh well
    ;; Outer loop initializer
    mov dstX, eax
    neg dstX
OUTER: ;; Outer loop condition
    mov eax, dstX
    cmp eax, dstWidth
    jge DONE

    ;; Inner loop initializer
    mov eax, dstWidth
    neg eax
    mov dstY, eax
INNER: ;; Inner loop condition
    mov eax, dstY
    cmp eax, dstWidth
    jge OINCR ;; Jump to outer loop increment

    ;; Inner loop
    ;; Big condition chain on whether to draw
    ;; If any of the conditions are false (since they are all AND'd together), skip to the inner increment (IINCR)
    ;; If dstX<0, do not draw
    mov edx, dstX
    cmp edx, 0
    jl IINCR

    ;; if dstX>=bitmap width, do not draw
    cmp edx, (EECS205BITMAP PTR [esi]).dwWidth
    jge IINCR

    ;; If dstY<0, do not draw
    mov ebx, dstY
    cmp ebx, 0
    jl IINCR

    ;; IF dstY>=bitmap height, do not draw
    cmp ebx, (EECS205BITMAP PTR [esi]).dwHeight
    jge IINCR

    ;; If (xcenter+dstX-halfwidth)<0, do not draw
    mov eax, xcenter
    add eax, dstX
    sub eax, halfwidth
    cmp eax, 0
    jl IINCR

    ;; IF (xcenter+dstX-halfwidth)>=639, do not draw
    cmp eax, SCREEN_WIDTH-1
    jge IINCR

    ;; If (ycenter+dstY-halfheight)<0, do not draw
    mov eax, ycenter
    add eax, dstY
    sub eax, halfheight
    cmp eax, 0
    jl IINCR

    ;; If (ycenter+dstY-halfheight)>=479, do not draw
    cmp eax, SCREEN_HEIGHT-1
    jge IINCR

    ;; If the target pixel is not transparent
    INVOKE Index2D, dstX, dstY, (EECS205BITMAP PTR [esi]).dwWidth
    ;; eax holds the proper index into the array of pixels
    mov ecx, (EECS205BITMAP PTR [esi]).lpBytes
    mov al, BYTE PTR [ecx+eax] ;; al holds the bitmap pixel
    cmp al, (EECS205BITMAP PTR [esi]).bTransparent
    je IINCR

    ;; If we're here, then we're allowed to draw
    ;; We'll use ebx for x coordinate, and edx for y coordinate
    ;; al holds our color value
    ;; Compute x coordinate
    mov ebx, xcenter
    add ebx, dstX
    sub ebx, halfwidth

    ;; Compute y coordinate
    mov edx, ycenter
    add edx, dstY
    sub edx, halfheight

    ;; Now draw
    INVOKE DrawPixel, ebx, edx, al
    ;; Fallthrough to the increment
IINCR: ;; Inner increment
    inc dstY
    jmp INNER

OINCR: ;; Outer increment
    inc dstX
    jmp OUTER

DONE: ;; Exiting the outer loop is just returning from the function
    ret
BasicBlit ENDP

RotateBlit PROC uses eax ebx ecx edx esi lpBmp:PTR EECS205BITMAP, xcenter:DWORD, ycenter:DWORD, angle:FXPT
    LOCAL cosa:FXPT, sina:FXPT, shiftX:SDWORD, shiftY:SDWORD, dstWidth:DWORD, dstX:DWORD, dstY:DWORD
    
    ;; Slight optimization: Use BasicBlit for zero rotation
    ;; This avoids a lot of slow fixed point math
    cmp angle, 0
    jne SKIP
    INVOKE BasicBlit, lpBmp, xcenter, ycenter
    jmp DONE
    
SKIP:
    ;; Okay, this part is weird.
    ;; I admit it. I have no excuse, only an explanation.
    ;; When I got RotateBlit working, the star rotated in the opposite direction of the arrow key.
    ;; I wasn't sure if that was correct behavior - It's what happens when the local coordinate system of the star is rotated in the correct direction....
    ;; But I disliked it.
    ;; So, I've implemented this fix. I distort the coordinate system again
    ;; I add PI_HALF (this is that constant's value)
    ;; Then swap sin and cos
    ;; This results in rotation in the correct direction (because it's occurring on a flipped coordinate system)
    ;; With the angles offset so that the star starts in the correct orientation
    INVOKE FixedAdd, angle, 102943
    mov angle, eax
    ;; Yeah, I know, it's silly.
    ;; But you know what they say: If it looks stupid, but it works....
    ;; It's probably stupid.
    ;; But!
    ;; It works.
    
    ;; This assignment is going to be four days late in an hour, sue me.

    ;; Fill in local variables
    INVOKE FixedSin, angle
    mov cosa, eax
    INVOKE FixedCos, angle
    mov sina, eax

    ;; Use a register for faster lookup
    mov esi, lpBmp

    ;; Compute shiftX
    mov eax, (EECS205BITMAP PTR [esi]).dwWidth
    INVOKE ToFixedPoint, eax
    INVOKE FixedMultiply, eax, cosa
    INVOKE FixedMultiply, eax, ONE_HALF
    mov shiftX, eax ;; First part of the shiftX expression
    mov eax, (EECS205BITMAP PTR [esi]).dwHeight
    INVOKE ToFixedPoint, eax
    INVOKE FixedMultiply, eax, sina
    INVOKE FixedMultiply, eax, ONE_HALF
    INVOKE FixedSubtract, shiftX, eax ;; shiftX is now complete....
    INVOKE FromFixedPoint, eax ;; But it needs to be an integer
    mov shiftX, eax ;; Now, it's correct.

    ;; Similar code for shiftY
    mov eax, (EECS205BITMAP PTR [esi]).dwHeight
    INVOKE ToFixedPoint, eax
    INVOKE FixedMultiply, eax, cosa
    INVOKE FixedMultiply, eax, ONE_HALF
    mov shiftY, eax ;; First part of the shiftY expression
    mov eax, (EECS205BITMAP PTR [esi]).dwWidth
    INVOKE ToFixedPoint, eax
    INVOKE FixedMultiply, eax, sina
    INVOKE FixedMultiply, eax, ONE_HALF
    INVOKE FixedAdd, shiftY, eax ;; shiftY is now complete...
    INVOKE FromFixedPoint, eax ;; But it needs to be an integer
    mov shiftY, eax ;; Now, it's correct.

    ;; Now compute dstWidth
    mov eax, (EECS205BITMAP PTR [esi]).dwWidth
    add eax, (EECS205BITMAP PTR [esi]).dwHeight
    mov dstWidth, eax

    ;; For loops
    ;; These are in the wrong order for proper cache coherency. But oh well
    ;; Outer loop initializer
    mov dstX, eax
    neg dstX
OUTER: ;; Outer loop condition
    mov eax, dstX
    cmp eax, dstWidth
    jge DONE

    ;; Inner loop initializer
    mov eax, dstWidth
    neg eax
    mov dstY, eax
INNER: ;; Inner loop condition
    mov eax, dstY
    cmp eax, dstWidth
    jge OINCR ;; Jump to outer loop increment

    ;; Inner loop
    ;; First, srcX
    mov eax, dstX ;; edx will be srcX, but eax will be used to compute it.
    INVOKE ToFixedPoint, eax
    INVOKE FixedMultiply, eax, cosa
    mov ebx, eax ;; Temporarily use ebx for storage
    mov eax, dstY
    INVOKE ToFixedPoint, eax
    INVOKE FixedMultiply, eax, sina
    INVOKE FixedAdd, ebx, eax ;; eax now holds srcX
    INVOKE FromFixedPoint, eax
    mov edx, eax ;; Move srcX into place

    ;; Now, srcY
    mov eax, dstY ;; Even though ebx will be dstY, use eax for calculations
    INVOKE ToFixedPoint, eax
    INVOKE FixedMultiply, eax, cosa
    mov ebx, eax
    mov eax, dstX
    INVOKE ToFixedPoint, eax
    INVOKE FixedMultiply, eax, sina
    INVOKE FixedSubtract, ebx, eax
    INVOKE FromFixedPoint, eax
    mov ebx, eax ;; ebx now holds srcY

    ;; Big condition chain on whether to draw
    ;; If any of the conditions are false (since they are all AND'd together), skip to the inner increment (IINCR)
    ;; If srcX<0, do not draw
    cmp edx, 0
    jl IINCR

    ;; if srcX>=bitmap width, do not draw
    cmp edx, (EECS205BITMAP PTR [esi]).dwWidth
    jge IINCR

    ;; If srcY<0, do not draw
    cmp ebx, 0
    jl IINCR

    ;; IF srcY>=bitmap height, do not draw
    cmp ebx, (EECS205BITMAP PTR [esi]).dwHeight
    jge IINCR

    ;; If (xcenter+dstX-shiftX)<0, do not draw
    mov eax, xcenter
    add eax, dstX
    sub eax, shiftX
    cmp eax, 0
    jl IINCR

    ;; IF (xcenter+dstX-shiftX)>=639, do not draw
    cmp eax, SCREEN_WIDTH-1
    jge IINCR

    ;; If (ycenter+dstY-shiftY)<0, do not draw
    mov eax, ycenter
    add eax, dstY
    sub eax, shiftY
    cmp eax, 0
    jl IINCR

    ;; If (ycenter+dstY-shiftY)>=479, do not draw
    cmp eax, SCREEN_HEIGHT-1
    jge IINCR

    ;; If the target pixel is not transparent
    INVOKE Index2D, edx, ebx, (EECS205BITMAP PTR [esi]).dwWidth
    ;; eax holds the proper index into the array of pixels
    mov ecx, (EECS205BITMAP PTR [esi]).lpBytes
    mov al, BYTE PTR [ecx+eax] ;; al holds the bitmap pixel
    cmp al, (EECS205BITMAP PTR [esi]).bTransparent
    je IINCR

    ;; If we're here, then we're allowed to draw
    ;; We'll use ebx for x coordinate, and edx for y coordinate
    ;; (they're unused now)
    ;; al holds our color value
    ;; Compute x coordinate
    mov ebx, xcenter
    add ebx, dstX
    sub ebx, shiftX

    ;; Compute y coordinate
    mov edx, ycenter
    add edx, dstY
    sub edx, shiftY

    ;; Now draw
    INVOKE DrawPixel, ebx, edx, al
    ;; Fallthrough to the increment
IINCR: ;; Inner increment
    inc dstY
    jmp INNER

OINCR: ;; Outer increment
    inc dstX
    jmp OUTER

DONE: ;; Exiting the outer loop is same as returning
	ret 			; Don't delete this line!!!
RotateBlit ENDP



END
