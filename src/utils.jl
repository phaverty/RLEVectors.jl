# Like R's rep, repeat
#  No length_out arg at this time
function rep(x::Union{Any,Vector}; each::Union{Int,Vector{Int}} = ones(Int,length(x)), times::Int = 1)
  if !isa(x,Vector)
    x = [ x ]
  end
  if isa(each,Int)
    each = [ each for i in eachindex(x) ]
  end
  length(x) != length(each) && throw(ArgumentError("If the arguemnt 'each' is not a scalar, it must have the same length as 'x'."))
  length_out = sum(each * times)
  rval = similar(x,length_out)
  index = 0
  for i in 1:times
    for j in eachindex(x)
      for k in 1:each[j]
        index += 1
        rval[index] = x[j]
      end
    end
  end
  return(rval)
end

"""
The four argument version substitutes customized ordering for a hard-coded '<'.
"""
function Base.searchsortedfirst(v::AbstractVector, x, lo::Int, hi::Int)
    lo = lo - 1
    hi = min(length(v), hi) + 1
    @inbounds while lo < hi-1
        m = (lo+hi)>>>1
        if v[m] < x
            lo = m
        else
            hi = m
        end
    end
    return hi
end

"""
The method for two vectors is like R's findinterval.
"""
Base.searchsortedfirst(v::AbstractVector, x::AbstractVector) = searchsortedfirst(v, x, 1, length(v))
function Base.searchsortedfirst(v::AbstractVector, x::AbstractVector, lo::Int, hi::Int)
    indices = similar(x)
    const min = lo - 1
    const max = hi + 1
    hi = hi + 1
    @inbounds for (i,query) in enumerate(x)
#        println("starting, query: ", query, " lo ", lo, " hi ", hi)
#        indices[i] = searchsortedfirst(v, query, 1, n)
#    end
        # unsorted x, restart left side
        if lo <= min || query <= v[lo]
            lo = min
        end
        # cast out exponentially to get hi to the right of query
        jump = 1
        while true
            if hi >= max
                hi = max
                break
            end
            if query <= v[hi]
                break
            end
            lo = hi
            hi = hi + jump
            jump = jump * 2
        end
        # binary search for the exact bin
        while hi - lo > 1
            m = (lo+hi)>>>1
            if query > v[m]
                lo = m
            else
                hi = m
            end
        end
        indices[i] = hi
#        println("ending,   query: ", query, " lo ", lo, " hi ", hi)
    end
    return(indices)
end
# Debug code
#x = [2, 4, 6, 8]
#searchsortedfirst( x, [1, 2, 3] )
