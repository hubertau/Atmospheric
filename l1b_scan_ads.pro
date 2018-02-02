PRO L1B_SCAN_ADS, LUNL1B, ISCAN, SPH, SCAN_ADS
;
; VERSION 
;   17JUL13  AD  Original. Based on l1c_inpscan.pro
;
; DESCRIPTION
; Procedure to extract Scan ADS information from L1B file.
; Since the SCAN Information ADS DSRs are of variable length, the earlier
; procedure l1b_sph has already constructed an array of starting positions
; for the Scan ADS information for each scan.
;
; ARGUMENTS
;   LONG      LUNL1B     I  LUN for L1B file
;   INTEGER   ISCAN      I  Scan# (1 = 1st scan in L1B file)
;   STRUCTURE SPH        I  Specific Product Header
;   STRUCTURE SCAN_ADS   O  Scan ADS 
;   containing
;     LONG    TIME_FIRST[3] Time [ESA 3 element arr] of 1st sweep in scan
;     INTEGER NUM_SWEEPS   No. sweeps in scan
;     FLOAT   LST          tangent point local solar time [hrs]
;     FLOAT   SAT_AZI      sat to target azimuth [deg]
;     FLOAT   SUN_AZI      target to sun azimuth [deg]
;     FLOAT   SUN_ELE      target to sun elevation [deg]
;     FLOAT   NESR_DATA[*,*]  NESR data [nW/(cm2 sr cm-1)] 

IF ISCAN LT 1 OR ISCAN GT SPH.TOT_SCANS THEN MESSAGE, $
  'F-L1B_SCAN_ADS: argument ISCAN = ' + STRTRIM ( STRING ( ISCAN ), 2 ) + $
  ' outside valid range 1:' + STRTRIM ( STRING ( SPH.TOT_SCANS ), 2 ) 

TIME_FIRST = LONARR(3)                   ; time code for 1st sweep in scan
DSR_LENGTH = 0L

POINT_LUN, LUNL1B, SPH.SCAN_ADS_OFFSET[ISCAN-1]

DUM19 = BYTARR(19)
NUM_SWEEPS = 0    

; original ignored CFI and just read as combined 161 bytes
DUM22 = BYTARR(22)
CFI = LONARR(4)
DUM123 = BYTARR(123)

NUM_PK_FIT = 0
DUM46 = BYTARR(46)  

READU, LUNL1B, TIME_FIRST, ADS_LENGTH, DUM19, NUM_SWEEPS, DUM22, CFI, DUM123, $
       NUM_PK_FIT, DUM46 
LST = FLOAT ( CFI[0] ) * 1.0E-6            ; hours
SAT_AZI = FLOAT ( CFI[1] ) * 1.0E-6        ; degrees
SUN_AZI = FLOAT ( CFI[2] ) * 1.0E-6        ; degrees
SUN_ELE = FLOAT ( CFI[3] ) * 1.0E-6        ; degrees

DUM32 = BYTARR(32)

; The next piece of the L1B record is of variable length which has to be 
; evaluated from NUM_PK_FIT and NUM_COADD_SCENE read from the data
NUM_COADD_SCENE = 0                  ;   2 bytes Number of coadded scene meas.
FOR IPEAK = 1, NUM_PK_FIT DO BEGIN
  READU, LUNL1B, DUM32, NUM_COADD_SCENE
  NSKIP1 = BYTARR(2*NUM_COADD_SCENE)       ; 2*K bytes to be skipped
  READU, LUNL1B, NSKIP1
ENDFOR

NESR_DATA = FLTARR ( SPH.NUM_NESR_PNTS, NUM_SWEEPS ) 
READU, LUNL1B, NESR_DATA
NESR_DATA = NESR_DATA * 1.0E9     

SCAN_ADS = { TIME_FIRST:TIME_FIRST, $   ; i(3) time of first sweep in scan
             NUM_SWEEPS:NUM_SWEEPS, $   ; number of sweeps in scan
                    LST:LST, $          ; tangent point local solar time [hrs]
                SAT_AZI:SAT_AZI, $      ; sat to target azimuth [deg]
                SUN_AZI:SUN_AZI, $      ; target to sun azimuth [deg]
                SUN_ELE:SUN_ELE, $      ; target to sun elevation [deg]
              NESR_DATA:NESR_DATA }     ; NESR data [nW/(cm2 sr cm-1)] 

END
