## Range operations
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

# Run End Encode: Like RLE, but return (runvalues,runends) rather than (runvalues,runlengths)
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

# Recompress runvalues and runends for an RLEVector
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

# Tidy up an existing (mostly) Run End Encoded vector pair, dropping zero length runs and fixing any runvalue runs
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

# Take two runends vectors (strictly increasing uints) and find the number of unique values for the disjoin operation
function disjoin_length(x::Vector, y::Vector)
  i = length(x)
  j = length(y)
  nrun = i + j
  @inbounds while i > 0 && j > 0
    if x[i] > y[j]
      i = i - 1
    elseif x[i] < y[j]
      j = j - 1
    else
      i = i - 1
      j = j - 1
      nrun = nrun - 1
    end
  end
  return(nrun)
end

"""
Takes runends from two RLEVectors, make one new runends breaking the pair into non-overlapping runs.
Basically, this is an optimized `sort!(unique([x,y])))`. This is useful when comparing two RLEVector
objects. The values corresponding to each disjoint run in `x` and `y` can then be compared directly.

## Returns
An integer vector, of a type that is the promotion of the eltypes of the runends of x and y.

## Examples
x = RLEVector([1,1,2,2,3,3])
y = RLEVector([1,1,1,2,3,4])
for (i,j) in disjoin(x,y)
  println(x[i] + y[j])
end
"""
function disjoin(x::Vector,  y::Vector)
    length(x) == 0 && return(y) # At least one value to work on
    nrun = disjoin_length(x, y)
    i = length(x)
    j = length(y)
    runends = Array(promote_type(eltype(x), eltype(y)), nrun)
    @inbounds while true
        xi = x[i]
        yj = y[j]
        if xi > yj
            runends[nrun] = xi
            i = i - 1
        elseif xi < yj
            runends[nrun] = yj
            j = j - 1
        else
            runends[nrun] = xi
            i = i - 1
            j = j - 1
        end
        nrun = nrun - 1
        if i == 0
            for r in 1:j runends[r] = y[r] end
            break
        elseif j == 0
            for r in 1:i runends[r] = x[r] end
            break
        end
    end
    return(runends)
end

