## Sorting

issorted(x::RLEVector) = issorted(x.runvalues)

reverse(x::RLEVector) = RLEVector(reverse(x.runvalues), cumsum(reverse(widths(x))))

function reverse!(x::RLEVector)
    reverse!(x.runvalues)
    x.runends[:] = cumsum(reverse(widths(x)))
    return x
end

function permute_runs(x::RLEVector, indices)
    RLEVector(rvalue(x)[indices], cumsum(widths(x)[indices]))
end

function sort(x::RLEVector{T1,T2}) where {T1,T2}
    ord = sortperm(x.runvalues)
    rle = RLEVector{T1,T2}(x.runvalues[ord], cumsum(widths(x)[ord]))
    return (rle)
end

function sort!(x::RLEVector)
    ord = sortperm(x.runvalues)
    x.runvalues[:] = x.runvalues[ord]
    x.runends[:] = cumsum(widths(x)[ord])
    return (x)
end

function sortperm(x::RLEVector)
    ord = sortperm(x.runvalues)
    RLEVector(ord, cumsum(widths(x)[ord]))
end
