; FILESEARCH collects all files containing a specified string in the desired directory, and
;   splits it into the major and minor matrices.

;#################################################################################################

; process input variable 'altitude' into a string that can be appended to libdir
altitude=string(altitude)         ; convert to string
altitude=altitude.trim()          ; trim trailing and leading spaces

; append the relevant parts. * is necessary so that the file_search function knows to look for
; whatever is contained within the asterisks
alt='*rad_'+ altitude + '*'

flist = file_search ( libdir + alt )   ; search
flist=strmid(flist,32)  ; extract the relevant bits of the filename it can be displayed
main=flist[0]     ; unperturbed spectrum
major=flist[1:*]  ; major isotopes
minor=flist[1:*]  ; minor isotopes

; begin process to split the major and minor isotopes
for a=1,(n_elements(flist)-1),1 do begin
  ; stregex checks all the element flist[a] to see if it contains '1.asc'. If so, it is a major isotope
  pos=stregex(flist[a],'1.asc')
  ; use a simple if then clause to pick out the spectra that are of minor isotopes.
  if (pos eq -1) then major[a-1]='null'
endfor

temp=major
; delete all the entries that are null, i.e. the ones belonging to minor isotopes
major=major[where(temp ne 'null'),*]
; delete all the entries that are not null, i.e. the ones belonging to major isotopes
minor=minor[where(temp eq 'null'),*]
;#################################################################################################

