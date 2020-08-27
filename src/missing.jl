# Functions for working with missings in RLE values

# Using implementations matching those in Missings.jl for AbstractArray
Missings.allowmissing(x::RLEVector{T1,T2}) where {T1,T2} =
    convert(RLEVector{Union{T1,Missing},T2}, x)
Missings.disallowmissing(x::RLEVector{T1,T2}) where {T1,T2} =
    convert(RLEVector{nonmissingtype(T1),T2}, x)

# RLEVector methods on functions for arrays that may have missings
# see https://github.com/JuliaLang/julia/blob/c6da87ff4bc7a855e217856757ad3413cf6d1f79/base/missing.jl
