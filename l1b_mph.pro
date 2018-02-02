PRO L1B_MPH, LUNL1B, MPH
;
; VERSION 
;   03AUG17 AD Original. Based on l1c_inpmph
;
; DESCRIPTION
;   Read L1B Main Product Header 
;   Differs from l1c_inpmph in passing information as structure
;
; ARGUMENTS
;   LONG      LUNL1B    I  LUN for L1B file
;   STRUCTURE MPH       O  MPH data
;   containing
;     STRING  SOFTWARE_VER  Software version, eg 'MIPAS/5.02    ' (C*14)
;     LONG    ABS_ORBIT     Orbit Number, eg 10036
;     LONG    SPH_SIZE      Length [bytes] of Specific Product Header, 6760

; Main Product Header - 1247 bytes read as a single string
MPHBUF = STRING ( REPLICATE ( 32B, 1247 ) )
POINT_LUN, LUNL1B, 0
READU, LUNL1B, MPHBUF

; Find Software Version, extract as real number
J = STRPOS ( MPHBUF, 'SOFTWARE_VER=' )   ; eg ...="MIPAS/5.02    ",
SOFTWARE_VER = STRMID ( MPHBUF, J+14, 14 )

; Find Start Absolute orbit number
J = STRPOS ( MPHBUF, 'ABS_ORBIT=' )      ; eg ABS_ORBIT=+10036  
ABS_ORBIT = 0L
READS, STRMID ( MPHBUF, J+11, 5 ), ABS_ORBIT    ; omit '+' sign

; Find Length of Specific Product Header
J = STRPOS ( MPHBUF, 'SPH_SIZE=' )       ; eg SPH_SIZE=+0000006760<bytes>
SPH_SIZE = 0L
READS, STRMID ( MPHBUF, J+10, 11 ), SPH_SIZE    ; omit '+' sign

MPH = { SOFTWARE_VER:SOFTWARE_VER, ABS_ORBIT:ABS_ORBIT, SPH_SIZE:SPH_SIZE }

END
