## Dimensions and descriptions

desc = doc"
# Describing `RLEVector` Objects
For an RLEVector `x = RLEVector([4,5,6],[3,6,9])`
 * `length(x)` The full length of the vector, uncompressed
 * `size(x)` Same as `length`, as for any other vector
 * `size(x,dim)` Returns `(length(x),1) for dim == 1`
 * `rstart(x)` The index of the beginning of each run
 * `rwidth(x)` The width of each run
 * `rstop(x)` The index of the end of each run
 * `rlast(x)` The data value for each run
 * `isempty(x)` Returns boolean, as for any other vector
 * `nrun(x)` Returns the number of runs represented in the array

## See also
length, size, rstart, rwidth, rstop, rvalue, isempty, nrun
"

#@doc desc ->
#function ndims(x::RLEVector)
#    return(1)
#end
#
#@doc desc ->
function nrun(x::RLEVector)
  length(x.runends)
end

#@doc desc ->
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

#@doc desc->
function size(x::RLEVector)
  (length(x),)
end

#@doc desc->
function size(x::RLEVector, dim::Integer)
  len = length(x)
  if dim == 1
    return(len)
  else
    return( (len,1) )
  end
end

#@doc desc->
function isempty(x::RLEVector)
  isempty(x.runends)
end

### Getters
#@doc desc->
function rfirst(x::RLEVector)
  re = x.runends
  rval = similar(re)
  prev = zero(eltype(re))
  for i in 1:length(re)
    @inbounds rval[i] = prev + 1
    @inbounds prev = re[i]
  end
  return(rval)
end

#@doc desc->
function rfirst(x::RLEVector, run::Integer)
  run == 1 ? one(eltype(x.runends)) : x.runends[run-1] + 1
end

#@doc desc->
function rwidth(x::RLEVector)
  re = x.runends
  rval = Array(eltype(re),length(re))
  prev = zero(eltype(re))
  for i in 1:length(re)
    @inbounds rei = re[i]
    @inbounds rval[i] = rei - prev
    @inbounds prev = rei
  end
  return(rval)
end

function rwidth(x::RLEVector, run::Integer)
  run == 1 ? x.runends[1] : x.runends[run] - x.runends[run-1]
end

#@doc desc->
function rlast(x::RLEVector)
  x.runends
end

#@doc desc->
function rvalue(x::RLEVector)
  x.runvalues
end
