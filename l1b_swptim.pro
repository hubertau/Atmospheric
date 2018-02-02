PRO L1B_SWPTIM, LUNL1B, TIME, SPH, ISWEEP
;
; VERSION 
;   17JUL13  AD  Original. Based on l1c_swptim.pro
;
; DESCRIPTION
; Procedure to find sweep# corresponding to Scan time 
; On input ISWEEP is the sweep# at which the search commences
; On output returns ISWEEP=-1 if no matching sweep found
;
; ARGUMENTS
;   LONG      LUNL1B   I  LUN for L1B file
;   LONG      TIME[3]  I  Time [ESA fmt] for sweep
;   STRUCTURE SPH      I  Specific Product Header
;   INTEGER   ISWEEP  I/O Sweep# (1:TOT_SWEEPS) for given time

IF ISWEEP LT 1 OR ISWEEP GT SPH.TOT_SWEEPS THEN MESSAGE, $
  'F-L1B_SWPTIM: argument ISWEEP = ' + STRTRIM ( STRING ( ISWEEP ), 2 ) + $
  ' outside valid range 1:' + STRTRIM ( STRING ( SPH.TOT_SWEEPS ), 2 ) 

SWEEP_TIME = LONARR(3)   ; 2nd integer, = time of day in seconds

WHILE NOT ARRAY_EQUAL ( SWEEP_TIME, TIME ) DO BEGIN
  POINT_LUN, LUNL1B, SPH.MDS_OFFSET + ( ISWEEP - 1 ) * SPH.MDS_SIZE
  READU, LUNL1B, SWEEP_TIME
  IF ISWEEP GT SPH.TOT_SWEEPS THEN BEGIN
    ISWEEP = -1
    RETURN
  ENDIF
  ISWEEP = ISWEEP + 1
ENDWHILE
ISWEEP = ISWEEP - 1

END
