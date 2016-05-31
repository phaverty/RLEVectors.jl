## Sorting

function issorted(x::RLEVector, order::Ordering)
  issorted(x.runvalues)
end

function reverse(x::RLEVector, start=1, stop=length(x))
  rle = RLEVector(reverse(x.runvalues), cumsum(reverse(rwidth(x))))
  return(rle)
end

function reverse!(x::RLEVector, start=1, stop=length(x))
  reverse!(x.runvalues)
  x.runends = cumsum(reverse(rwidth(x)))
  return(x)
end

function permute_runends(x::RLEVector, indices)
  # Assuming equal length
  rval = similar(x.runends)
  sum = zero(eltype(rval))
  for i in indices
    rw = rwidth(x,i)
    @inbounds sum = rval[i] = rw + sum
  end
  return(rval)
end

function sort{T1,T2}(x::RLEVector{T1,T2})
  ord = sortperm(x.runvalues)
  rle = RLEVector{T1,T2}( x.runvalues[ord], cumsum(rwidth(x)[ord]) )
  return(rle)
end

function sort!(x::RLEVector)
  ord = sortperm(x.runvalues)
  x.runvalues = x.runvalues[ord]
  x.runends = cumsum(rwidth(x)[ord])
  return(x)
end

function sortperm(x::RLEVector)
  ord = sortperm(x.runvalues)
  RLEVector(ord, cumsum(rwidth(x)[ord]))
end
