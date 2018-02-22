pro gettagname, input, tag, index
; GETTAGNAME.PRO takes in a struct, a particular string that is a name of a tag in the struct,
;   and returns the tag index in the struct, so the struct can be references as struct.(index).
;   
;   Inputs:
;     input - the struct
;     tag - the string with the tag name in the struct
;     
;   Output:
;     index - tag index that you can index the struct using struct.(index) for the desired tag

;#################################################################################################
tnames=TAG_NAMES(input)
index=WHERE(STRCMP(tnames,strupcase(tag)) EQ 1)

;#################################################################################################


end