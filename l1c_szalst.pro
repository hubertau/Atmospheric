PRO L1C_SZALST, TIME, LAT, LON, SZA, LST
;
; VERSION
;   27DEC17  AD  Change arguments - modified for new MIPAS_L1C
;   02NOV04  AD  Renamed from SZALST to L1C_SZALST
;   05JUN02  AD  Renamed from SZA to SZALST. Correct calculation of LST
;   06JUN02  CP  Original.
; 
; DESCRIPTION
;   Calculate Solar Zenith Angle [deg] & Local Solar Time [hours]
;   for specified time,location.
;   Adapted from general purpose ISAMSUTIL function CLCSZA
;   Involves solar declination & Eq.of time calculation based on formula of 
;   H.M. Nautical Almanac Office 1965.
;
; ARGUMENTS
;   INTEGER*2 IYEAR  I  Year eg 2002
;   INTEGER*2 IDAY   I  Day# within year (1:366)
;   INTEGER*4 ISEC   I  Seconds within day (1:86400)
;   REAL*4    LAT    I  Latitude [deg N]
;   REAL*4    LON    I  Longitude [deg E]
;   REAL*4    SZA    O  Solar Zenith Angle [deg] (0=sun overhead)
;   REAL*4    LST    O  Local Solar Time [hours] (12=noon)
;
; -----------------------------------------------------------------------------
; Physical Constants
  DGTORD = !DPI/180.0D0

; 12783 is no days from 1Jan1965 to 1Jan2000, which is the start of ESA timing
ISOFF = 12783 * 86400L   
 
ISTOT = ISOFF + TIME[1]    ; = Seconds elapsed since 1965 (ignore leap seconds)

DTOT = ISTOT/86400.0D0                   ; Days elapsed since 1965	
YTOT = DTOT/365.2423D0	                 ; Years elapsed since 1965

X = (279.4574D0+0.985647D0*DTOT)/57.29578D0  ; Angle [rad]

; Equation of time [rad] (= (EQTIME*1440)/(2*PI) [mins])
EQTIME = ((-102.5D0 - 0.142D0*YTOT)*SIN(X) + $
           (-429.8D0 + 0.033D0*YTOT)*COS(X) + $ 
           596.5D0*SIN(2.0D0*X) -  2.0D0*COS(2.0D0*X) + $
           4.2D0*SIN(3.0D0*X) + 19.3D0*COS(3.0D0*X) - $ 
           12.8D0*SIN(4.0D0*X))*7.272205D-5

ALPHA = X - EQTIME                     ; Angle [rad]
DELTA = ATAN(0.4336D0*SIN(ALPHA))        ; Solar declination [rad]

; Hour Angle [rad]
HRANGL = !DPI - EQTIME - LON*DGTORD - ISTOT*7.272205D-5

; LST = Local Solar Time [hours]
LST = 12.- FLOAT( (HRANGL MOD (2*!DPI))*24./(2*!DPI) )
LST = LST MOD 24.0

COSZ = COS(DELTA) * COS(LAT*DGTORD) * COS(HRANGL) + $
       SIN(DELTA) * SIN(LAT*DGTORD)

; SZA = Solar Zenith Angle [deg]  
SZA = FLOAT ( ACOS(COSZ) / DGTORD )

end      
