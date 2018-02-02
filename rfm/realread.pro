; MIPAS spectra are organised in 'L1B' files containg 1 orbit of data, typically
; 14 orbits per day.
; From 2002-2004 MIPAS usually operated with about 74 scans per orbit, each
; scan consisting of 17 sweeps (=spectra) acquired at tangents points starting
; at 68km and descending in altitude to 6km
;
; L1B files are organised as
;   1 MPH record - main product header, common to all Envisat instruments
;   1 SPH record - specific product header, for MIPAS L1B data
;   n SCAN_ADS records - information on each scan
;   m MDS records - measurement data sets for each sweep, spectrum+location info
; There are other types of also records in the file which we don't need.

; Specify MIPAS L1B file containing spectra for complete orbit from 16Jan04
L1BFIL = '/network/aopp/minuit/mipas/dudhia/L1B/Jan04/' + $
  'MIP_NL__1PWDSI20040116_141126_000060272023_00254_09827_0001.N1'

; Open file, assigning logical unit#LUN, and reverse byte ordering
OPENR, LUN, L1BFIL, /GET_LUN, /SWAP_ENDIAN

; Read Main Product Header into structure MPH (type 'HELP MPH,/STR' to see
; contents)
L1B_MPH, LUN, MPH

; Read Special Product Header into structure SPH
L1B_SPH, LUN, MPH, SPH

; Print total number of (nominal, ie 17 sweeps) scans in file
PRINT, 'Tot.nominal scans=', SPH.TOT_NOM_SCANS

; Use SPH info to construct array WNOSPC containing wavenumber axis for spectra
L1B_SPCAXS, LUN, SPH, WNOSPC, WNORES     ; also WNORES, spectral resolution

; Select scan and read Annotation Data Set for scan as structure SCAN_ADS
ISCAN = 1
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
; Read spectrum from 15th sweep in selected scan (nominally ~12km) into
; structure MDS
L1B_MDS, LUN, ISWEEP+14, SPH, MDS

; Print tangent point information for spectrum
PRINT, 'Alt,Lat,Lon=', MDS.ALT, MDS.LAT, MDS.LON

; Plot spectrum
PLOT, WNOSPC, MDS.SPEC

; This can be compared with the spectral atlas on
; http://eodg.atm.ox.ac.uk/ATLAS/limb-radiance
; (note the 'Show Satellite Bands' option to superimpose the MIPAS bands)

end