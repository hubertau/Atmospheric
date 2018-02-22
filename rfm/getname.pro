pro getname, str, newstr
; GETNAME.PRO is a short script to take in a string - particularly a path, and return the
; name of the gas and its isotope that is being considered.
;
;   Input:
;     str - original string
;     
;   Output:
;     newstr - the shortened string
;     

;#################################################################################################
temp=strmid(str,27)
newstr=temp.remove(-4)
;#################################################################################################

  
end