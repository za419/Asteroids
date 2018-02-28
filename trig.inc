; #########################################################################
;
;   trig.inc - Includes for EECS205 Assignment 3
;
;
; #########################################################################

FXPT TYPEDEF SDWORD

EXTERNDEF SINTAB:WORD

FixedSin PROTO STDCALL angle:FXPT
FixedCos PROTO STDCALL angle:FXPT

FixedMultiply PROTO STDCALL a:FXPT, b:FXPT
FixedSubtract PROTO STDCALL a:FXPT, b:FXPT
FixedAdd PROTO STDCALL a:FXPT, b:FXPT
