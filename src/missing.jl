# Functions for working with missings in RLE values

Missings.allowmissing(x::RLEVector) = RLEVector(allowmissing(values(x)), ends(x))
#Missings.allowmissing!(x::RLEVector) = RLEVector(allowmissing!(values,x), runends(x))
Missings.disallowmissing(x::RLEVector) = RLEVector(disallowmissing(values(x)), ends(x))
#Missings.disallowmissing!(x::RLEVector) = RLEVector(disallowmissing!(values,x), runends(x))
