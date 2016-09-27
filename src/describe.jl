## Dimensions and descriptions

isempty(x::RLEVector) = isempty(x.runends)
ndims(x::RLEVector) = 1
nrun(x::RLEVector) = length(x.runends)
size(x::RLEVector) =  (length(x),)

function size(x::RLEVector, dim::Integer)
  len = length(x)
  if dim == 1
    return(len)
  else
    return( (len,1) )
  end
end

function length{T1,T2<:Integer}(x::RLEVector{T1,T2})
  re = x.runends
  ind = endof(re)
  if (ind > 0)
    @inbounds len = re[ind]
  else
    len = zero(T2)
  end
  return(len)
end

function rfirst(x::RLEVector)
  re = x.runends
  rval = similar(re)
  prev = zero(eltype(re))
  @inbounds for i in eachindex(re)
        rval[i] = prev + 1
        prev = re[i]
  end
  return(rval)
end

function rfirst(x::RLEVector, run::Integer)
    num_one = one(eltype(x.runends))
    run == 1 ? num_one : x.runends[run-1] + num_one
end

function rwidth(x::RLEVector)
  re = x.runends
  rval = similar(re)
  prev = zero(eltype(re))
  @inbounds for i in eachindex(re)
      rei = re[i]
      rval[i] = rei - prev
      prev = rei
  end
  return(rval)
end

function rwidth(x::RLEVector, run::Integer)
  run == 1 ? x.runends[1] : x.runends[run] - x.runends[run-1]
end

rlast(x::RLEVector) =  x.runends
rvalue(x::RLEVector) = x.runvalues
endtype(x::RLEVector) = eltype(rlast(x))

"""
# Describing `RLEVector` objects
For an RLEVector `x = RLEVector([4,5,6],[3,6,9])`
* `length(x)` The full length of the vector, uncompressed
* `size(x)` Same as `length`, as for any other vector
* `size(x,dim)` Returns `(length(x),1) for dim == 1`
* `rfirst(x)` The index of the beginning of each run
* `rwidth(x)` The width of each run
* `rlast(x)` The index of the end of each run
* `rvalue(x)` The data value for each run
* `isempty(x)` Returns boolean, as for any other vector
* `nrun(x)` Returns the number of runs represented in the array
* `eltype(x)` Returns the element type of the runs
* `endtype(x)` Returns the element type of the run ends
"""
length, size, rfirst, rwidth, rlast, rvalue, isempty, nrun, endtype, ndims
