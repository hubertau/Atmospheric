pro gettagname, input, tag, index

tnames=TAG_NAMES(input)
index=WHERE(STRCMP(tnames,strupcase(tag)) EQ 1)

end