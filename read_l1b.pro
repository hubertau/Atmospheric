;
; DESCRIPTION
;   Read L1B file and average spectra

; see http://www.stcorp.nl/beat/documentation/beatl2-data/records/MIPAS_L1.html
; for BEATL2_INGEST options

L1BFIL = '/home/minuit/mipas/dudhia/L1B/Mar09/' + $
'MIP_NL__1PRDPA20090301_004356_000060152076_00475_36601_1964.N1'

L1B = BEATL2_INGEST ( L1BFIL, $
 'LATITUDE_MIN=-5; LATITUDE_MAX=5, ALTITUDE_MIN=30; ALTITUDE_MAX=32' )

IF BEATL2_IS_ERROR ( L1B ) THEN MESSAGE, 'Stopped: BEATL2 error'

NPTS = N_ELEMENTS ( L1B.WAVENUMBER_PER_FILE )
NSPC = N_ELEMENTS ( L1B.ALTITUDE )
AVGSPC = DBLARR(NPTS)
STDSPC = DBLARR(NPTS)
FOR IPTS = 0, NPTS-1 DO BEGIN
  AVGSPC[IPTS] = MEAN ( L1B.SPECTRAL_RADIANCE[*,IPTS] ) * 1E9
  STDSPC[IPTS] = STDDEV (  L1B.SPECTRAL_RADIANCE[*,IPTS] ) * 1E9
ENDFOR

END