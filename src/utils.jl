"""
    rep(x::Union{Any,Vector}; each::Union{Int,Vector{Int}} = ones(Int,length(x)), times::Int = 1)

Construct a vector of repeated values, just like R's `rep` function.
We do not have a `length_out` argument at this time.

## Examples

```julia
rep(["Go", "Fight", "Win"], times=2)

# output
6-element Array{String,1}:
 "Go"   
 "Fight"
 "Win"  
 "Go"   
 "Fight"
 "Win"  
```

```julia
rep(["A", "B", "C"], each=3)

# output
9-element Array{String,1}:
 "A"
 "A"
 "A"
 "B"
 "B"
 "B"
 "C"
 "C"
 "C"
```
"""
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
RLEVectors.jl define new methods for this binary search function. The method for two vectors is like R's findinterval. The index of the position of each `x` in `v` is
    determined searching within the index bounds `lo` and `hi`, inclusive. For the returned
    indices `i`, `v[i] <= x[i] < v[i+1]`.

This operation is helpful for finding the RLE run corresponding to each of a set of indices or
    general tasks such as binning values for empirical density functions.

## Examples
    
```julia
v = [2, 4, 6, 8, 10]
x = [1, 3, 4, 8, 11]
searchsortedfirst(v, x)
5-element Array{Int64,1}:
 1
 2
 2
 4
 6

```
"""
searchsortedfirst(v::AbstractVector, x::AbstractVector) = searchsortedfirst(v, x, 1, length(v))
function searchsortedfirst(v::AbstractVector, x::AbstractVector, lo::Int, hi::Int)
    indices = similar(x)
    min = lo - 1
    max = hi + 1
    @inbounds for (i,query) in enumerate(x)
        hi = hi + 1 # 2X speedup with this *inside* the loop for sorted x. Dunno why.
        # unsorted x, restart left side
        if lo <= min || query <= v[lo]
            lo = min
        end
        if hi >= max || query >= v[hi]
            hi = max
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
    end
    return(indices)
end

"""
The four argument version substitutes customized ordering for a hard-coded '<'.
    This is a is a silly optimization that I hope to get rid of soon.
"""
function searchsortedfirst(v::AbstractVector, x, lo::Int, hi::Int)
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

# Some familiar operations over matrix columns and rows, to match RLEDT
# Probably these are all a job for mapslice or slicedim. I need to RTM.
rowmap(x::Matrix,f::Function) = [ f( @view x[i,:] ) for i in 1:size(x)[1] ]
colmap(x::Matrix,f::Function) = [ f( @view x[:,j] ) for j in 1:size(x)[2] ]
rowMeans(x) = rowmap(x,mean)
rowMedians(x) = rowmap(x,median)
rowSums(x) = rowmap(x,sum)
colMeans(x) = colmap(x,mean)
colMedians(x) = colmap(x,median)
colSums(x) = colmap(x,sum)
