pro linevis, gas, unp, input, div, jac, no,$
 data=data

; LINEVIS.PRO is a script to visualise the results of line selections. It plots on the same graph
;   the RFM, the Jacobian/(RFM+1), the Jacobian, and optionally the MIPAS data, and the selected
;   line, with colour.
;   
;   Inputs:
;     gas - string of gas name, e.g. 'co2i1'. Doens't matter if upper or lower case.
;     unp - for the wavenumber axis
;     input - this is either majcoll or mincoll
;     div - Jacobian/(RFM+1)
;     jac - Jacobian
;     no - which selected peak (majcoll/mincoll index)
;     data - optional keyword, set to newapodise if MIPAS data is available.

;#################################################################################################
; Prepare indices to pass to plot functions

; Expand path to include coyote library
!PATH = Expand_Path('/home/ball4321/MPhysProject/coyote') + ':' + !PATH

; define start and finish wavenumbers
s=input[1,no]-0.8
f=input[1,no]+0.8

; calculate which index this requires for wavenumbers, i.e. unp.w
sw=where(abs(unp.w-s) lt 0.001)
fw=where(abs(unp.w-f) lt 0.001)

; if data is provided, do the same for it (this is necessary because newapodise has different
; indices)
if keyword_set(data) then begin
  sd=where(abs(data[0,*]-s) lt 0.001)
  fd=where(abs(data[0,*]-f) lt 0.001)
endif

; Now find all the peaks that lie within the specified range (though one peak is specified in
; the input, plot others that may be nearby)
sm=where(input[1,*] ge s)
fm=where(input[1,*] le f)

; cgsetintersection returns the wavenumbers within majcoll/mincoll that are within the specified
; range. This is always at least one, of course, since a peak is always specified.
set=cgsetintersection(sm,fm)
;#################################################################################################


;#################################################################################################

; plot unperturbed spectrum
p1=plot(unp.w(sw:fw),unp.r(sw:fw)/1000,$
  color='g',$
  name='RFM unperturbed spectrum * 10$^{-3}$',$
  xtitle='Wavenumbers of isotopic lines/cm$^{-1}$',$
  ytitle='Radiance/nW/(cm$^{2}$ sr cm$^{-1}$)',$
  title=name2iso(gas) + ' Visualisation of RFM, MIPAS data, Jacobian, Jacobian/(RFM+1), and selected lines')

; plot jacobian spectrum
p2=plot(unp.w(sw:fw),jac(sw:fw),$
  /overplot,$
  color='r',$
  name='Jacobian')

; plot jacobian/(RFM+1), amplified by 1000, to be able so visualise on the same scale.
p3=plot(unp.w(sw:fw),div(sw:fw)*1000,$
  /overplot,$
  name='Jacobian * 10$^{3}$ div by (RFM+1)')

; then plot all the lines that were detected
foreach a, input[1,set] do p4=plot([a,a],p2.yrange,$
  color='b',$
  /overplot,$
  linestyle='dash',$
  name='selected isotope lines')

; finally, if data was provided, plot it, and then plot the legend.
if keyword_set (data) then begin
  p5=plot(unp.w(sw:fw),data[1,sd:fd]/1000,/overplot,name='MIPAS data * 10$^{-3}$', color='purple')
  leg=legend(target=[p1,p2,p3,p4,p5], position=[0.1,0.9],/relative)
endif else begin
  leg=legend(target=[p1,p2,p3,p4], position=[0.1,0.9],/relative)
endelse
;#################################################################################################


end