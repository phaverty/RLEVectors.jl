## Run operations

"""
    numruns(x)

Count the number of runs of repeated values present in a vector.
"""
function numruns(re::AbstractVector)
  n = 1
  current = re[1]
  for i in 2:length(re)
    if re[i] != current
      n += 1
      current = re[i]
    end
  end
  return(n)
end


"""
    ree(x)

Run End Encode a vector

Like RLE, but returns (runvalues,runends) rather than (runvalues,runlengths)
"""
function ree{T}(x::AbstractVector{T})
  xlen = length(x)
  xlen < 2 && return( (x,[xlen]) )
  nrun = numruns(x)
  runvalues = similar(x,nrun)
  runends = Vector{Int}(nrun)
  run = 1
  current = x[1]
  for i in 2:xlen
    if x[i] != current
      runvalues[run] = current
      runends[run] = i-1
      current = x[i]
      run = run + 1
    end
  end
  runvalues[nrun] = current
  runends[nrun] = xlen
  return( (runvalues,runends) )
end

"""
    numruns(runvalues, runends)

Given run values and run ends for a RLEVector, determine the number of runs that would
    be present if it were re-compressed. RLEVectors.jl does this operation after modifying
    an RLEVector, for example.
"""
function numruns(runvalues, runends)
  len = length(runends)
  length(runends) != len && throw(ArgumentError("runvalues and runends must be the same length."))
  len < 2 && return(len)
  n = 1
  current_val = runvalues[1]
  current_end = runends[1]
    @inbounds for i in 2:len
        rv = runvalues[i]
        re = runends[i]
    if rv != current_val && re != current_end
      n = n + 1
      re < current_end && throw(ArgumentError("The provided runends were not sorted, please use cumsum(runlengths) to get the right values."))
      current_val = rv
      current_end = re
    end
  end
  return(n)
end

"""
    ree(runvalues, runends)
        
Tidy up an existing (mostly) Run End Encoded vector, dropping zero length runs and fixing
        any adjacent identical values. `RLEVectors.jl` does this operation after modifying an
     RLEVector, for example.
"""
function ree(runvalues, runends)
  ree(runvalues, runends, numruns(runvalues, runends))
end

function ree(runvalues, runends, nrun)
  newv = similar(runvalues,nrun)
  newe = similar(runends,nrun)
  current_val = runvalues[1]
  current_end = runends[1]
  n = 1
    @inbounds for i in 2:length(runvalues)
        rv = runvalues[i]
        re = runends[i]
    if runends[i] != current_end
      if rv != current_val
        newv[n] = current_val
        newe[n] = current_end
        n = n + 1
        current_val = rv
      end
      current_end = re
    end
  end
  @inbounds newv[n] = current_val
  @inbounds newe[n] = current_end
  return( (newv,newe))
end

function ree(x)
  return( ([x],[1]) )
end

"""
    inverse_ree(rle)

Uncompress the runs and runends of an RLEVector.

## Examples
    collect(rle)
    inverse_ree( runvalues(rle), runends(rle) )
"""
function inverse_ree(runvalues,runends)
  len = length(runvalues)
  len != length(runends) && throw(ArgumentError("runvalues and runends must be of the same length."))
  len == 0 && return(similar(runvalues,0))
  n = runends[end]
  rval = Array(eltype(runvalues),n)
  j=1
  @inbounds for i in 1:n
    rval[i] = runvalues[j]
    if runends[j] == i
      j = j + 1
    end
  end
  return(rval)
end
