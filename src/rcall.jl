import RCall: sexp, rcopy, RClass, rcopytype, @R_str, S4Sxp

function sexp(f::RLEVector)
    R"library(GenomicRanges)"
    v = values(f)
    w = widths(f)
    R"Rle($v, $w)"
end

function rcopy(::Type{RLEVector}, s::Ptr{S4Sxp})
    RLEVector(rcopy(s[:values]), cumsum(rcopy(s[:lengths])))
end

rcopytype(::Type{RClass{:Rle}}, s::Ptr{S4Sxp}) = RLEVector
