
"""
The method for two vectors is like R's findinterval.
"""
searchsortedfirst2(v::AbstractVector, x::AbstractVector) = searchsortedfirst2(v, x, 1, length(x))
function searchsortedfirst2(v::AbstractVector, x::AbstractVector, lo::Int, hi::Int)
    indices = similar(x)
    n = hi = hi + 1
    @inbounds for (i,query) in enumerate(x)
        # unsorted x, restart left side
        if lo < 1 || query <= v[lo]
            lo = 0
        end
        # cast out exponentially to get hi to the right of query
        jump = 1
        while hi <= n && query > v[hi]
            lo = hi
            hi = hi + jump
            jump = jump * 2
        end
        hi > n ? n : hi
        # binary search for the exact bin
        while lo < hi-1
            m = (lo+hi)>>>1
            if query > v[m]
                lo = m
            else
                hi = m
            end
        end
        indices[i] = hi
        lo = hi - 1
    end
    return(indices)
end
