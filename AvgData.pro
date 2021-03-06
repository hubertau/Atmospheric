; AvgData
; 
; Last Edit 20/02/18
; 
; This is the script to average actual MIPAS data.
; 
; The script averages over all the spectra in the month specified in the first section (default
;   is Jan 04), and averages over the specified altitude and latitude bands specified in section
;   2.
; 
; The extracted data is stored in 'data', in m=number of spectra collected columns. Details about
;   each spectrum is stored in indices, which stores altitude, latitude, and longitude.

 
;#################################################################################################
; options:

; Latitude band
lat=[30,50]

; tangent height
alt=[29,31]

; day or ngt?
tim='day'
;#################################################################################################


;#################################################################################################
; set working and search directory. Also create relevant arrays to contain data to be read.
; 'data' will contain the actual radiances. 59605 because that's how many data points are in the
;   MIPAS bands from 685-2410 wavenumbers.
; 'indices' will store information about what each spectrum in 'data' corresponds to: what 
;   altitude, latitude, etc.

cd, '/home/ball4321/MPhysProject'

; First create list of files on date 16/01/2004.
; The file_search function allows for this
libdir = '/network/aopp/minuit/mipas/dudhia/L1B/Jan04/'
flist = file_search ( libdir + '*200401*' ) ; average over January 2004

; data is going to collect the data to be averaged
data=MAKE_ARRAY(n_elements(flist)*73,59605)

; indices is going to collect information about what each spectrum in 'data' corresponds to.
indices=MAKE_ARRAY(5,n_elements(flist)*73)

;#################################################################################################


;#################################################################################################
; begin the loop to read in data. flist contains all the files to read through, so loop through
; that.

for a=0,(n_elements(flist)-1) do begin
  L1BFIL=flist[a]

  ; Open file, assigning logical unit#LUN, and reverse byte ordering
  OPENR, LUN, L1BFIL, /GET_LUN, /SWAP_ENDIAN
  
  ; Read Main Product Header into structure MPH (type 'HELP MPH,/STR' to see
  ; contents)
  L1B_MPH, LUN, MPH
  
  ; Read Special Product Header into structure SPH
  L1B_SPH, LUN, MPH, SPH
  
  ; Print total number of (nominal, ie 17 sweeps) scans in file
  PRINT, 'Tot.nominal scans; file index=', SPH.TOT_NOM_SCANS, a
  
  FOR b=1,SPH.TOT_NOM_SCANS DO BEGIN
    ; Use SPH info to construct array WNOSPC containing wavenumber axis for spectra
    L1B_SPCAXS, LUN, SPH, WNOSPC, WNORES     ; also WNORES, spectral resolution
    
    ; Select scan and read Annotation Data Set for scan as structure SCAN_ADS
    ISCAN = b
    L1B_SCAN_ADS, LUN, ISCAN, SPH, SCAN_ADS
    ; Unfortunately the SCAN_ADS does not contain information to directly the
    ; set of 17 MDS records corresponding to this scan, it only contains the scan
    ; start time so we have to search through the full set of MDS records to find
    ; the MDS# that matches
    
    ; Find Sweep# within L1B file corresponding to start of selected scan
    ISWEEP = 1  ; initialise to start search from first sweep in file
    L1B_SWPTIM, LUN, SCAN_ADS.TIME_FIRST, SPH, ISWEEP
    
    ; ISWEEP is now the absolute sweep# from the start of the file
    ;
    ; Read spectrum from 9th sweep in selected scan (nominally ~30km) into
    ; structure MDS
    L1B_MDS, LUN, ISWEEP+8, SPH, MDS
    
    ; use L1C_SZALST, inputting MDS structure, to calculate Solar Zenith Angle.
    ; SZA<90 -> Day
    ; SZA>90 -> Night
    L1C_SZALST, MDS.MDS_TIME, MDS.LAT, MDS.LON, SZA, LST
    
    IF ((MDS.ALT GE alt(0)) && (MDS.ALT LT alt(1))) && $
      ((MDS.LAT GE lat(0)) && (MDS.LAT LT lat(1))) && $
      (((SZA GT 90) && (tim eq 'ngt')) || ((SZA LE 90) && (tim eq 'day'))) THEN BEGIN

      ; Print tangent point information for spectrum
      PRINT, 'b,Alt,Lat,Lon,SZA=', b, MDS.ALT, MDS.LAT, MDS.LON, SZA
      INDICES[0,b-1+a*73]=a+1         ; store file index as fileindex+1, so that the where 
                                      ;   function later doesn't delete the flist[0] contributions
      INDICES[1,b-1+a*73]=b           ; b is scan number
      INDICES[2,b-1+a*73]=MDS.ALT     ; altitude of scan
      INDICES[3,b-1+a*73]=MDS.LAT     ; latitude of scan
      INDICES[4,b-1+a*73]=MDS.LON     ; longitude of scan
      
      DATA[b-1+a*73,*]=MDS.SPEC
    ENDIF
    
  ENDFOR

  FREE_LUN, LUN

endfor
;#################################################################################################

;#################################################################################################
; Process collected data

; use x to store array of where no data is stored for a spectrum (i.e. to be deleted)
x=where(indices[0,*])

; get rid of the rows that are 0. the where function returns indices of nonzero elements
indices=indices(*,x)

; get rid of zero entries in data as well.
data=data[x,*]

avgreal=mean(data,dimension=1)
varreal=variance(data,dimension=1)
;#################################################################################################


;#################################################################################################
;store everything in structures
dcon=create_struct(name='Data Options','LAT', lat, 'ALT', alt, 'TIM', tim, 'f', flist)

ddat=create_struct(name='Data', 'w', wnospc, 'raw', data, 'label', indices, 'avg', avgreal, $
   'var', varreal)
;#################################################################################################


;#################################################################################################
; save the data to pass to compare.pro
name=strmid(libdir,38,5)
name='saves/'+name+tim
save, filename=name, ddat, dcon
;#################################################################################################

delvar, lat, alt, tim, flist, wnospc, data, indices, avgreal, varreal, lun, lst, libdir, l1bfil, $
  name, SZA, WNORES, x, a, b, iscan, isweep

end
