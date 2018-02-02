PRO L1B_MDS, LUNL1B, ISWEEP, SPH, MDS 
;
; VERSION 
;   03AUG17 AD Add MDS_TIME to MDS structure 
;   17JUL13 AD Original. Based on l1c_inpmds.pro
;
; DESCRIPTION
;   Procedure to input MIPAS L1B MDS data for one sweep
;   Only sets SPEC for bands where BAND_VAL=0
;
; ARGUMENTS
;   LONG      LUNL1B                 I  LUN for L1B file
;   INTEGER   ISWEEP                 I  Sweep# in file
;   STRUCTURE SPH                    I  Specific Product Header
;   STRUCTURE MDS                    O  Measurement Data Set
;   Containing
;     LONG    MDS_TIME(3)            Time of sweep [Days,HHMMSS,.tttt]
;     DOUBLE  ALT                    Tangent altitude [km]
;     DOUBLE  ALT_ERR                Tangent altitude error [km]
;     FLOAT   LAT                    Latitude [deg]
;     FLOAT   LON                    Longitude [deg]
;     DOUBLE  RAD_EARTH              Earth Radius of Curvature [km]
;     BYTE    BAND_VAL(5)            Band Validity (0=OK)
;     FLOAT   SPEC(NSPC)             Radiance spectrum [nW/(cm2.sr.cm-1)]


IF ISWEEP LT 1 OR ISWEEP GT SPH.TOT_SWEEPS THEN MESSAGE, $
  'F-L1B_MDS: argument ISWEEP = ' + STRTRIM ( STRING ( ISWEEP ), 2 ) + $
  ' outside valid range 1:' + STRTRIM ( STRING ( SPH.TOT_SWEEPS ), 2 ) 

POINT_LUN, LUNL1B, SPH.MDS_OFFSET + ( ISWEEP - 1 ) * SPH.MDS_SIZE


MDS_TIME = LONARR(3)          ; 12 bytes days from 1-JAN-2000, hh:mm:ss, .tttt
DUM43 = BYTARR(43)            ; 43 bytes to be skipped
ALT   = 0.0D0                 ;  8 bytes tangent point altitude [km]
ALT_ERR = 0.0D0               ;  8 bytes altitude error [km]
ILAT  = 0L                    ;  4 bytes latitude [deg*1E-6]
ILON  = 0L                    ;  4 bytes longitude [deg*1E-6]
RAD_EARTH = 0.0D0             ;  8 bytes radius of curvature [km]
DUM54 = BYTARR(54)            ; 54 bytes to be skipped
SWEEP_ID = 0                  ;  2 bytes Sweep# within scan
DUM1347 = BYTARR(1347)        ; 1347 bytes to be skipped
DUM1912 = BYTARR(1912)        ; 1912 bytes to be skipped
BAND_VAL = BYTARR(5)          ;  5 bytes band validity (0=OK)
DUM26 = BYTARR(26)            ; 26 bytes to be skipped
NSPC = TOTAL ( SPH.NUM_POINTS_PER_BAND )    ; Spectrum (all 5 bands)
SPEC = FLTARR(NSPC)

READU, LUNL1B, MDS_TIME, DUM43, ALT, ALT_ERR, ILAT, ILON, RAD_EARTH,$ 
    DUM54, SWEEP_ID, DUM1347, BAND_VAL, DUM26, DUM1912, SPEC 
; old L1B format without DUM1912
;  READU, LUNL1B, MDS_TIME, DUM43, ALT, ALT_ERR, ILAT, ILON, RAD_EARTH,$
;    DUM54, SWEEP_ID, DUM1347, BAND_VAL, DUM26, L1BSPEC

LAT = ILAT * 1.0E-6          ; convert from deg*1E-6 to deg
LON = ILON * 1.0E-6
SPEC = SPEC * 1.0E9          ; convert from W/cm2... to nW/cm2...

FOR IBAND = 0, 4 DO BEGIN
  IF BAND_VAL[IBAND] THEN BEGIN  ; value=1 means invalid spectrum
    IF IBAND EQ 0 THEN I1 = 0 $
                  ELSE I1 = TOTAL ( SPH.NUM_POINTS_PER_BAND[0:IBAND-1] )
    I2 = TOTAL ( SPH.NUM_POINTS_PER_BAND[0:IBAND] ) - 1
    SPEC[I1:I2] = 0.0
  ENDIF
ENDFOR

MDS = { MDS_TIME:MDS_TIME, $ ; Time
          ALT:ALT, $         ; tangent altitude [km]
      ALT_ERR:ALT_ERR, $     ; tangent altitude error [km] 
          LAT:LAT, $         ; tangent point lat [deg]
          LON:LON, $         ; tangent point lon [deg]
    RAD_EARTH:RAD_EARTH, $   ; tp Earth radius of curvature [km]
     BAND_VAL:BAND_VAL, $    ; band validity (0=OK, 1=not valid)
         SPEC:SPEC }         ; radiance spectrum [nW/(cm2 sr cm-1)]

END
