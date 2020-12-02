#format
#L:!!!!!-password-!!!!:password

#prepare input

/^$/b

s/2([0-9])/@@\1/g
s/1([0-9])/@\1/g
s/@/!!!!!!!!!!/g
s/0//g
s/1/!/g
s/2/!!/g
s/3/!!!/g
s/4/!!!!/g
s/5/!!!!!/g
s/6/!!!!!!/g
s/7/!!!!!!!/g
s/8/!!!!!!!!/g
s/9/!!!!!!!!!/g

s/^(!*)-(!*) (.): (.*)$/\3:\1\4-\2\4/

:process
t process
s/!![a-z]/!/g
t process

s/.!(.)[a-z]*/\1/g

:x; t x
s/^(.)\1./&/; t one
s/^(.).\1/&/; t one

b next

:one
s/^(.)\1\1/&/; t next

x
s/^/!/
x

:next
$b end
b

:end
x
s/!!!!!!!!!!/@/g
s/@@@@@@@@@@/#/g

:format
t format

s/!!!!!!!!!/9/; t tr
s/!!!!!!!!/8/; t tr
s/!!!!!!!/7/; t tr
s/!!!!!!/6/; t tr
s/!!!!!/5/; t tr
s/!!!!/4/; t tr
s/!!!/3/; t tr
s/!!/2/; t tr
s/!/1/; t tr
s/([#@])([0-9]*)$/\10\2/; t tr

:tr
y/#@!/@! /
/[#@!]/b format

p
