PRO RFMRD, FILNAM, WNOARR, DATARR, BINSGL=BINSGL, BINDBL=BINDBL
; VERSION
;   26MAR16 AD local mod: Assume always 3 comment records in binary files
;   10MAR16 AD Rewritten, with extra optional arguments
;              Use POINT_LUN for reading binary files.
;              Allow for irregular spectral grids
;              Allow for DP or SP binary files
;   10DEC10 AD Use /get_lun
;   25AUG03 AD Change NWIDEMESH from INTARR to LONARR
;   20DEC00 VJ Add capability to read binary files
;   28NOV00 AD Original
;
; DESCRIPTION
;   IDL procedure for reading RFM output spectra
;   Should work for ASCII or binary files, regular or irregular grids
;   Binary files are identified by presence of '.bin' string in filename
;
; ARGUMENTS
;   STRING  FILNAM  I  Name of RFM  spec. file (eg 'rad_01000.asc')
;   DBLARR  WNOARR  O  Spectral axis [cm-1 or GHz]
;   DBLARR  DATARR  O  Data array
;   INTEGER BINSGL  I  (Optional) non zero=binary file, single precision
;   INTEGER BINDBL  I  (Optional) non zero=binary file, double precision
;

; establish if this is a binary file
SBIN = KEYWORD_SET ( BINSGL ) OR STRPOS ( FILNAM, '.bin' ) GT 0  ; SP binary
DBIN = KEYWORD_SET ( BINDBL )          ; DP binary
ASCFIL = NOT ( SBIN OR DBIN )

; define and initialise header variables
WNO1  = 0.0D0
WNOD  = 0.0D0   
NWNO  = 0L
COMMNT = '!'

; read file header
IF ASCFIL THEN BEGIN
  OPENR, LUN, FILNAM, /GET_LUN                   ; skip header records
  WHILE STRMID ( COMMNT, 0, 1 ) EQ '!' DO READF, LUN, COMMNT
  READS, COMMNT, NWNO, WNO1, WNOD
ENDIF ELSE BEGIN
  OPENR, LUN, FILNAM, /F77_UNFORMATTED, /GET_LUN
;  WHILE STRMID ( COMMNT, 0, 1 ) EQ '!' DO BEGIN  ; skip header records
;    POINT_LUN, -LUN, IPT
;    READU, LUN, COMMNT
;  ENDWHILE
;  POINT_LUN, LUN, IPT
  for irec = 1, 3 do readu, lun, commnt     ; local mod
  READU, LUN, NWNO, WNO1, WNOD
ENDELSE

; set output array sizes
NWNO = ABS ( NWNO )        ; could be -ve, indicating GHz.
WNOARR = DBLARR(NWNO)
IF SBIN THEN DATARR = FLTARR(NWNO) ELSE DATARR = DBLARR(NWNO)

IF WNOD GT 0 THEN BEGIN                             ; regular grid
  WNOARR = WNO1 + DINDGEN(NWNO) * WNOD 
  IF ASCFIL THEN BEGIN
    READF, LUN, DATARR
  ENDIF ELSE BEGIN
    I = 0L
    NPTREC = 0L
    WHILE NOT EOF(LUN) DO BEGIN
      POINT_LUN, -LUN, IPT          ; save pointer location
      READU, LUN, NPTREC            ; no points in record
      IF SBIN THEN DATREC = FLTARR(NPTREC) $
              ELSE DATREC = DBLARR(NPTREC)
      POINT_LUN, LUN, IPT           ; reset to start of record
      READU, LUN, NPTREC, DATREC
      DATARR(I:I+NPTREC-1) = DATREC
      I = I + NPTREC
    ENDWHILE
  ENDELSE
;
ENDIF ELSE BEGIN                    ; irregular grid
  IF ASCFIL OR DBIN THEN BEGIN
    D2ARR = DBLARR(2,NWNO)
    IF ASCFIL THEN READF, LUN, D2ARR ELSE READU, LUN, D2ARR
    WNOARR = D2ARR[0,*]
    DATARR = D2ARR[1,*]
  ENDIF ELSE BEGIN                  ; SP binary
    R = 0.0
    DW = 0.0D0
    FOR I = 0L, NWNO-1 DO BEGIN
      READU, LUN, DW, R
      WNOARR(I) = DW
      DATARR(I) = R
    ENDFOR
  ENDELSE
ENDELSE  

FREE_LUN, LUN

END
