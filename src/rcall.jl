using .RCall

function RCall.sexp(f::RLEVector)
    RCall.R"library(GenomicRanges)"
    v = values(f)
    w = widths(f)
    RCall.R"Rle($v, $w)"
end

function rcopy(::Type{RLEVector}, s::Ptr{S4Sxp})
    RLEVector(Rcall.rcopy(s[:values]), cumsum(RCall.rcopy(s[:lengths])))
end

rcopytype(::Type{RCall.RClass{:Rle}}, s::Ptr{RCall.S4Sxp}) = RLEVector
