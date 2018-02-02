PRO L1B_GEO_ADS, LUNL1B, ISCAN, SPH, GEO_ADS
;
; VERSION 
;   17JUL13  AD  Original. Based on l1c_inpscan.pro
;
; DESCRIPTION
; Procedure to extract Geolocation ADS information from L1B file.
;
; ARGUMENTS
;   LONG      LUNL1B     I  LUN for L1B file
;   INTEGER   ISCAN      I  Scan# (1 = 1st scan in L1B file)
;   STRUCTURE SPH        I  Specific Product Header
;   STRUCTURE GEO_ADS    O  Scan ADS 
;   containing
;      LONG  TIME_FIRST(3)  time of first sweep
;      LONG  TIME_SCAN(3)   time of mid scan
;      LONG  TIME_LAST(3)   time of last sweep
;      FLOAT LAT_FIRST      Lat [deg] of first sweep
;      FLOAT LON_FIRST      Lon [deg] of first sweep
;      FLOAT LAT_SCAN       Lat [deg] of mid scan
;      FLOAT LON_SCAN       Lon [deg] of mid scan
;      FLOAT LAT_LAST       Lat [deg] of last sweep
;      FLOAT LON_LAST       Lon [deg] of last sweep


IF ISCAN LT 1 OR ISCAN GT SPH.TOT_SCANS THEN MESSAGE, $
  'F-L1B_SCAN_ADS: argument ISCAN = ' + STRTRIM ( STRING ( ISCAN ), 2 ) + $
  ' outside valid range 1:' + STRTRIM ( STRING ( SPH.TOT_SCANS ), 2 ) 

TIME_FIRST = LONARR(3)                   ; time code for 1st sweep in scan
DUM1 = BYTARR(1)
TIME_SCAN = LONARR(3)                     ; time for mid sweep
TIME_LAST = LONARR(3)                   ; time for last sweep

LATLON = LONARR(6)

POINT_LUN, LUNL1B, SPH.GEO_ADS_OFFSET + ( ISCAN - 1 ) * SPH.GEO_ADS_SIZE
READU, LUNL1B, TIME_FIRST, DUM1, TIME_SCAN, TIME_LAST, LATLON

LAT_FIRST = LATLON[0] * 1.0E-6
LON_FIRST = LATLON[1] * 1.0E-6
LAT_SCAN  = LATLON[2] * 1.0E-6
LON_SCAN  = LATLON[3] * 1.0E-6
LAT_LAST  = LATLON[4] * 1.0E-6
LON_LAST  = LATLON[5] * 1.0E-6

GEO_ADS = { TIME_FIRST:TIME_FIRST, $     ; i(3) time of first sweep
             TIME_SCAN:TIME_SCAN, $      ; i(3) time of mid scan
             TIME_LAST:TIME_LAST, $      ; i(3) time of last sweep
             LAT_FIRST:LAT_FIRST, $      ; Lat [deg] of first sweep
             LON_FIRST:LON_FIRST, $      ; Lon [deg] of first sweep
              LAT_SCAN:LAT_SCAN, $       ; Lat [deg] of mid scan
              LON_SCAN:LON_SCAN, $       ; Lon [deg] of mid scan
              LAT_LAST:LAT_LAST, $       ; Lat [deg] of last sweep
              LON_LAST:LON_LAST }        ; Lon [deg] of last sweep

END
