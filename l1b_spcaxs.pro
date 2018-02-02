PRO L1B_SPCAXS, LUNL1B, SPH, WNOSPC, WNORES 
; VERSION 
;   17JUL13  AD  Original.
;
; DESCRIPTION
;   Procedure to determine spectral axis and resolution of L1B data
;
; ARGUMENTS
;   LONG      LUNL1B                 I  LUN for L1B file
;   STRUCTURE SPH                    I  Specific Product Header
;   DOUBLE WNOSPC(NSPC)              O  Spectral axis [cm-1]
;   DOUBLE WNORES                    O  Spectral resolution [cm-1]


WNORES = ( SPH.LAST_WAVENUM[0] - SPH.FIRST_WAVENUM[0] ) / $
         ( SPH.NUM_POINTS_PER_BAND[0] - 1 )

NSPC = TOTAL ( SPH.NUM_POINTS_PER_BAND )    ; Spectrum (all 5 bands)
WNOSPC = DBLARR(NSPC)

I2 = -1
NBND = N_ELEMENTS ( SPH.NUM_POINTS_PER_BAND )
FOR IBND = 0, NBND-1 DO BEGIN
  NPTS = SPH.NUM_POINTS_PER_BAND[IBND]
  I1 = I2 + 1
  I2 = I1 + NPTS - 1
  WNO1 = SPH.FIRST_WAVENUM[IBND]
  WNOSPC[I1:I2] = WNO1 + DINDGEN(NPTS)*WNORES
ENDFOR   

END
