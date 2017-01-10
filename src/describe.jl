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


function starts(x::RLEVector)
  re = x.runends
  rval = similar(re)
  prev = zero(eltype(re))
  @inbounds for i in eachindex(re)
        rval[i] = prev + 1
        prev = re[i]
  end
  return(rval)
end
rfirst(x::RLEVector) = starts(x)

function starts(x::RLEVector, run::Integer)
    num_one = one(eltype(x.runends))
    run == 1 ? num_one : x.runends[run-1] + num_one
end
rfirst(x::RLEVector, run::Integer) = starts(x, run)

function widths(x::RLEVector)
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
rwidth(x::RLEVector) = widths(x)

function widths(x::RLEVector, run::Integer)
  run == 1 ? x.runends[1] : x.runends[run] - x.runends[run-1]
end
rwidth(x::RLEVector, run::Integer) = widths(x, run)

rlast(x::RLEVector) =  x.runends
ends(x::RLEVector) =  x.runends
rvalue(x::RLEVector) = x.runvalues
values(x::RLEVector) = x.runvalues
endtype(x::RLEVector) = eltype(rlast(x))

@doc (@doc RLEVector) starts, widths, ends, values, rfirst, rwidth, rlast, rvalue, nrun, endtype

@deprecate rwidth widths
@deprecate rstart starts
@deprecate rlast ends
@deprecate rvalue values
