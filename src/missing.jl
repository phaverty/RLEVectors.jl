# Functions for working with missings in RLE values

# Using implementations matching those in Missings.jl for AbstractArray
Missings.allowmissing(x::RLEVector{T1,T2}) where {T1,T2} = convert(RLEVector{Union{T1, Missing},T2}, x)
Missings.disallowmissing(x::RLEVector{T1,T2}) where {T1,T2} = convert(RLEVector{nonmissingtype(T1),T2}, x)
