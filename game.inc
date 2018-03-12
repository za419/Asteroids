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
PI =  205887	            ;;  PI
TWO_PI	= 411774
ROTATION = 410166 ;; Threshold after which a rotation will be reset to zero (2*pi - pi/128)
EPSILON = 1608 ;; Threshold after which a rotation will be reset to zero (pi/128)
ROT_INC = 00000324h ;; Increment for rotation: PI/64
ACCEL = 00002000h ;; Increment for linear acceleration: one eighth-pixel per frame
MAX_RVELOCITY = 0000d000h ;; Maximum rotational velocity (be nice to the player and limit it to make control easier)
MIN_PAUSE = 5 ;; Minimum number of frames we can be paused for
BLAST_VELOCITY = 00100000h ;; Velocity a shot is fired at
BLAST_COOLDOWN = 30

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
    sprite DWORD 0 ;; Pointer to sprite representing this GameObject. Null if this is empty
    xcenter FXPT ?
    ycenter FXPT ?
    xvelocity FXPT ?
    yvelocity FXPT ?
    rotation FXPT ?
    rvelocity FXPT ?
    ;; Metadata
    flags WORD 0 ;; Checks on various conditions set - 0 is equivalent to "General".
    tag0 DWORD 0 ;; Extra data which can be used for storage related to this object
    tag1 DWORD 0 ;; More extra data
    pExtra DWORD 0 ;; Pointer to a structure containing even more data this object might need
    pRespawn DWORD 0 ;; Pointer to respawn target
    ;; Interpretation of the last 48 bits is entirely dependent on the 16 flag bits
    ;; For example, a (theoretical) object could specify that it requires scaling in the flags, store a fixed88 in the tag, and then use the extra pointer for mipmapping or specification of a scaling algorithm
    ;; Or, a black hole could store its radius in pixels in the tag, be identified by the flag bits, and use pExtra to store information on how to calculate forces with it
GameObject ENDS

;; GameObject flags
GRAVITATIONAL_OBJECT = 1 ;; Enables the application of gravity between all gameobjects in the array and this one (note that acceleration will not be applied to this object)
                         ;;             If this is set, pExtra must point to a GravitationalObject struct specifying how to calculate this acceleration
COLLISION_NODELETE = 2 ;; Prevents the object from being deleted upon collision with another object (The other object may be deleted, but this one will suffer no ill effect)
COLLISION_IGNORE = 4 ;; Prevents the object from participating in collisions at all (Collision checking will be skipped entirely on objects with this flag set)
COPY_TRANSFORMS = 8 ;; The object shall maintain the same rotation and location as the one pointed to by pExtra.
                    ;; I highly recommend also applying COLLISION_IGNORE, since, well...... Both colliding immediately is bad, unless for some reason you're using this to force a collision?
                    ;; Objects with this set will not have acceleration applied to them whatsoever (so if they precede their target by update order, they will lag it by a frame)
COLLISION_NONPLAYER = 16 ;; The object will only collide with non-player objects (a good option for transform copies on the player as well)
COLLISION_COLLECTIBLE = 32 ;; The object will ignore collisions with non-player objects. Collision with the player will invoke Collect, which shall attach the GameObject in pExtra to the player's powerup slot
RESPAWNING_OBJECT = 64 ;; When deleted, the object will have its tags incremented by the cycle count.
                       ;; When that cycle count is passed, the object will be "respawned" by copying the GameObject in pRespawn into its memory
                       ;; (Note that this means that, for respawning objects, if the object is alive, tag stores the respawn interval, or if it's dead, tag stores the respawn time)
                       ;; Also note that this means that the object can be respawned as an entirely different one after death (means of progression?)
KILL_SCORE = 128 ;; If set, will grant points equal to pExtra when killed

GravitationalObject STRUCT
    maxrad FXPT 00640000h ;; Optimization: Do not calculate acceleration of objects whose center is this many pixels from our own. Set to 0 to disable
    acceleration FXPT ONE ;; Product of mass and the universal gravitational constant G
    scaling FXPT ONE ;; Multiplied by acceleration after it is calculated. No effect on objects outside maxrad
    adjustment FXPT ZERO ;; Added to acceleration after scaling. Can effect objects outside maxrad
    ;; These last two allow unphysical objects, which can have some interesting effects - For example, an object which pulls everything on screen towards it equally, or a forcefield which repels objects
GravitationalObject ENDS
