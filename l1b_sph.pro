PRO L1B_SPH, LUNL1B, MPH, SPH
;
; VERSION 
;   15AUG17 AD Original. Derived from l1c_inpsph.
;
; DESCRIPTION
;   Read L1B Specific Product Header 
;   Differs from l1c_inpsph.pro in passing all variables as a single structure
;   rather than individually
;
; ARGUMENTS
;   LONG      LUNL1B                 I  LUN for L1B file
;   STRUCTURE MPH                    I  Main Product Header
;   containing
;     LONG    SPH_SIZE               Length [bytes] of SPH 
;   STRUCTURE SPH                    O  SPH data
;   containing
;     LONG    TOT_SWEEPS             No. sweeps in file
;     LONG    TOT_SCANS              No. scans in file
;     LONG    TOT_NOM_SCANS          No. nominal scans in file
;     LONG    NUM_SWEEPS_PER_SCAN    No. sweeps per scan
;     LONG    NUM_POINTS_PER_BAND[5] No. spectral data points per band
;     DOUBLE  FIRST_WAVENUM[5]       Lower wavenumber boundary of each band
;     DOUBLE  LAST_WAVENUM[5]        Upper wavenumber boundary of each band
;     LONG    NUM_NESR_PNTS          No. points for which NESR is tabulated
;     DOUBLE  NESR_FIRST_WAVENUM     Lower wavenumber for NESR tabulation
;     DOUBLE  NESR_LAST_WAVENUM      Upper wavenumber for NESR tabulation
;     LONG    SCAN_ADS_OFFSET[TOT_SCANS]  Offset [bytes] for each SCAN ADS
;     LONG    GEO_ADS_OFFSET         Offset [bytes] for first GEO ADS
;     LONG    GEO_ADS_SIZE           Length [bytes] for each GEO ADS
;     LONG    MDS_OFFSET             Offset [bytes] for 1st MDS record
;     LONG    MDS_SIZE               Length [bytes] of MDS records

; Specific Product Header - 6760 bytes read as a single string 
MPH_SIZE = 1247 ; assume fixed

SPHBUF = STRING ( REPLICATE ( 32B, MPH.SPH_SIZE ) )
POINT_LUN, LUNL1B, MPH_SIZE
READU, LUNL1B, SPHBUF

; Find number of sweeps in file
J = STRPOS ( SPHBUF, 'TOT_SWEEPS=' )
TOT_SWEEPS = 0L
READS, STRMID ( SPHBUF, J+12, 5 ), TOT_SWEEPS

; Find number of limb scan sequences in file
J = STRPOS ( SPHBUF, 'TOT_SCANS=' )
TOT_SCANS = 0L
READS, STRMID ( SPHBUF, J+11, 5), TOT_SCANS

; Find number of nominal limb scan sequences in file
J = STRPOS ( SPHBUF, 'TOT_NOM_SCANS=' )
TOT_NOM_SCANS = 0L
READS, STRMID ( SPHBUF, J+15, 5), TOT_NOM_SCANS

; Find number of sweeps per nominal elevation scan
; 17 = Number of sweeps required for a complete nominal scan
J = STRPOS ( SPHBUF, 'NUM_SWEEPS_PER_SCAN=' )
NUM_SWEEPS_PER_SCAN = 0L
READS, STRMID ( SPHBUF, J+21, 5), NUM_SWEEPS_PER_SCAN

; Find number of points per band (assume 5 bands is fixed)
J = STRPOS ( SPHBUF, 'NUM_POINTS_PER_BAND=' )
NUM_POINTS_PER_BAND = LONARR(5)
READS, STRMID ( SPHBUF, J+21, 55 ), FORMAT='(5I11)', NUM_POINTS_PER_BAND

; Find lower wavenumber limits of each band
J = STRPOS ( SPHBUF, 'FIRST_WAVENUM=' )
FIRST_WAVENUM = DBLARR(5)
READS, STRMID ( SPHBUF, J+15, 125 ), FORMAT='(5D25.17)', FIRST_WAVENUM
J = STRPOS ( SPHBUF, 'LAST_WAVENUM=' )
LAST_WAVENUM = DBLARR(5)
READS, STRMID ( SPHBUF, J+14, 125 ), FORMAT='(5D25.17)', LAST_WAVENUM

; Find number of points used for tabulating NESR 
J = STRPOS ( SPHBUF, 'NUM_NESR_PNTS=' )
NUM_NESR_PNTS = 0L
READS, STRMID ( SPHBUF, J+15, 11), NUM_NESR_PNTS

; Find first frequency used for the NESR 
J = STRPOS ( SPHBUF, 'NESR_FIRST_WAVENUM=' )
NESR_FIRST_WAVENUM = 0.0D0
READS, STRMID ( SPHBUF, J+19, 25 ), NESR_FIRST_WAVENUM

; Find last frequency used for the NESR 
J = STRPOS ( SPHBUF, 'NESR_LAST_WAVENUM=' )
NESR_LAST_WAVENUM = 0.0D0
READS, STRMID ( SPHBUF, J+18, 25 ), NESR_LAST_WAVENUM

; Find position of the Geolocation ADS (for the first scan) and size
J = STRPOS ( SPHBUF, 'GEOLOCATION ADS' )
GEO_ADS_OFFSET = 0L
READS, STRMID ( SPHBUF, J+125, 20 ), GEO_ADS_OFFSET
I = STRPOS ( SPHBUF, 'NUM_DSR', J )   ; look for next 'NUM_DSR'
NUM_DSR = 0L
READS, STRMID ( SPHBUF, I+9, 10 ), NUM_DSR   ; should match TOT_SCANS
IF NUM_DSR NE TOT_SCANS THEN MESSAGE, 'F-L1B_SPH: No. Geo ADS = ' + $
   STRTRIM ( STRING ( NUM_DSR ), 2 ) + ' NE Tot Scans = ' + $
   STRTRIM ( STRING ( TOT_SCANS ), 2 ) 
I = STRPOS ( SPHBUF, 'DSR_SIZE', J )       ; look for next 'DSR_SIZE'
GEO_ADS_SIZE = 0L
READS, STRMID ( SPHBUF, I+10 ), GEO_ADS_SIZE

; Find position of the first Scan Information ADS
J = STRPOS ( SPHBUF, 'SCAN INFORMATION ADS' )
SCAN_ADS_OFFSET = 0L
READS, STRMID ( SPHBUF, J+125, 20 ), SCAN_ADS_OFFSET

I = STRPOS ( SPHBUF, 'NUM_DSR', J )   ; look for next 'NUM_DSR'
NUM_DSR = 0L
READS, STRMID ( SPHBUF, I+9, 10 ), NUM_DSR   ; should match TOT_SCANS
IF NUM_DSR NE TOT_SCANS THEN MESSAGE, 'F-L1B_SPH: No. Scan ADS = ' + $
   STRTRIM ( STRING ( NUM_DSR ), 2 ) + ' NE Tot Scans = ' + $
   STRTRIM ( STRING ( TOT_SCANS ), 2 ) 
SAO = LONARR ( TOT_SCANS )
SAO[0] = SCAN_ADS_OFFSET
DUM12 = BYTARR(12)
DSR_LENGTH = 0L
FOR ISCAN = 1, TOT_SCANS-1 DO BEGIN
  POINT_LUN, LUNL1B, SAO[ISCAN-1]
  READU, LUNL1B, DUM12, DSR_LENGTH
  SAO[ISCAN] = SAO[ISCAN-1] + DSR_LENGTH
ENDFOR
SCAN_ADS_OFFSET = SAO

; Find position of first MDS 
I = STRPOS ( SPHBUF, 'MIPAS LEVEL-1B MDS' ) 
MDS_OFFSET = 0L
READS, STRMID ( SPHBUF, I+125, 20 ) , MDS_OFFSET   

; Find length of each MDS record
MDS_SIZE = 0L
READS, STRMID ( SPHBUF, I+219, 11 ), MDS_SIZE    ; 239441 for 0.025cm-1 resln

SPH = {    TOT_SWEEPS:TOT_SWEEPS, $          ; No. sweeps in file
            TOT_SCANS:TOT_SCANS, $           ; No. scans in file
        TOT_NOM_SCANS:TOT_NOM_SCANS, $       ; No. nominal scans in file
  NUM_SWEEPS_PER_SCAN:NUM_SWEEPS_PER_SCAN, $ ; No. sweeps per scan
  NUM_POINTS_PER_BAND:NUM_POINTS_PER_BAND, $ ; No. spectral data points per band
        FIRST_WAVENUM:FIRST_WAVENUM, $       ; Lower wno boundary of each band
         LAST_WAVENUM:LAST_WAVENUM, $        ; Upper wno boundary of each band
        NUM_NESR_PNTS:NUM_NESR_PNTS, $       ; No. pts for NESR tabulation
   NESR_FIRST_WAVENUM:NESR_FIRST_WAVENUM, $  ; Lower wno for NESR tabulation
    NESR_LAST_WAVENUM:NESR_LAST_WAVENUM, $   ; Upper wno for NESR tabulation
      SCAN_ADS_OFFSET:SCAN_ADS_OFFSET, $     ; Offset [bytes] for each SCAN ADS
       GEO_ADS_OFFSET:GEO_ADS_OFFSET, $      ; Offset [bytes] for 1st GEO ADS
         GEO_ADS_SIZE:GEO_ADS_SIZE, $        ; Length [bytes] of GEO ADS recs
           MDS_OFFSET:MDS_OFFSET, $          ; Offset [bytes] for 1st MDS record
             MDS_SIZE:MDS_SIZE }             ; Length [bytes] of MDS records

END
