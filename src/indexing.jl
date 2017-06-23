### Indexing

## Helper functions
## locate runs, get index of run corresponding to the i'th value in the expanded runs
function ind2run(rle::RLEVector, i::Integer)
  re = rle.runends
  n = length(re)
  run = searchsortedfirst(re,i,1,n)
  run <= n || throw(BoundsError())  # Can't be < 1
  return(run)
end

function ind2run(rle::RLEVector,i::UnitRange)
  re = rle.runends
  n = length(re)
  left_run = searchsortedfirst(re,first(i),1,n)
  right_run = searchsortedfirst(re,last(i),left_run,n)
  right_run <= n || throw(BoundsError())  # Can't be < 1
  return( left_run:right_run )
end

function ind2run(rle::RLEVector, i::AbstractArray)
  re = rle.runends
  n = length(re)
  runs = searchsortedfirst(re,i,1,n)
  maximum(runs) <= n || throw(BoundsError())  # Can't be < 1
  return(runs)
end

# get index of the run corresponding to the i'th value in the expanded runs, index in run and remainder of run
#  (runindex, index_in_run, values_in_run_after_i)
function ind2runcontext(rle::RLEVector, i::Integer)
  run = ind2run(rle, i)
  runend = rle.runends[run]
  ind_in_run = run == 1 ? i : i - rle.runends[run-1]
  (run, ind_in_run, runend - i)
end

function ind2runcontext(rle::RLEVector, i::UnitRange)
  s = start(i)
  e = last(i)
  n = length(rle)
  runs = ind2run(rle, i)
  left_run = start(runs)
  right_run = last(runs)
  runend = rle.runends[right_run]
  ind_in_run = left_run == 1 ? s : s - rle.runends[left_run-1]
  (left_run, right_run, ind_in_run, runend - e)
end

## Just enough for AbstractArray
if VERSION >= v"0.6.0"
    Base.linearindexing{T<:RLEVector}(::Type{T}) = Base.IndexLinear()
else
    Base.linearindexing{T<:RLEVector}(::Type{T}) = Base.LinearFast()
end


endof(rle::RLEVector) = length(rle)

function Base.getindex(rle::RLEVector, i::Int)
    run = ind2run(rle,i)
    return( rle.runvalues[run] )
end

function Base.setindex!(rle::RLEVector, value, i::Int)
  run = ind2run(rle,i)
  runvalue = rle.runvalues[run]
  runend = rle.runends[run]
  value == runvalue && return rle # replace with same value, no-op
  previous_run = run - 1
  next_run = run + 1
  at_start_of_run = (previous_run > 0 && i == rle.runends[previous_run] + 1) || i == 1
  at_end_of_run = i == runend
  match_left = run > 1 && rle.runvalues[previous_run] == value
  match_right = run < nrun(rle) && rle.runvalues[next_run] == value
  if at_end_of_run
    if at_start_of_run # in a run of length 1
      if match_right && match_left
        splice!(rle.runvalues, previous_run:run)
        splice!(rle.runends, previous_run:run)
      elseif match_right
        splice!(rle.runvalues,run)
        splice!(rle.runends,run)
      elseif match_left
        splice!(rle.runvalues,run)
        splice!(rle.runends,previous_run)
      else
        rle.runvalues[run] = value
      end
    else # end of a run longer than 1
      if match_right
        rle.runends[run] = runend - 1
      else
        insert!(rle.runvalues, next_run, value)
        insert!(rle.runends, run, runend - 1)
      end
    end
  elseif at_start_of_run
    if match_left
      rle.runends[previous_run] = rle.runends[previous_run] + 1
    else
      insert!(rle.runvalues, run, value)
      insert!(rle.runends, run, i)
    end
 else # middle of a run, average case
    splice!(rle.runvalues, run, [runvalue,value,runvalue])
    splice!(rle.runends, run, [i-1,i,runend])
  end
  return(rle)
end

function Base.getindex(rle::RLEVector, ind::Array{Bool, 1})
    rle[ find(ind) ]
end

function Base.setindex!(rle::RLEVector, value::AbstractArray, ind::Array{Bool, 1})
    rle[ find(ind) ] = value
end

## Indexing optimizations
function Base.getindex(rle::RLEVector, ind::UnitRange)
    runs = ind2run(rle,collect(ind)) # OPTIMIZE ME: ind2runcontext
    rv = rle.runvalues[runs]
    return(rv)
end

function Base.getindex(rle::RLEVector, ind::AbstractVector)
    run_indices = ind2run(rle, ind)
    return( RLEVector( rle.runvalues[ run_indices ] ) )
end

function Base.setindex!{T1,T2}(rle::RLEVector{T1,T2}, value::T1, indices::UnitRange)
  runs = ind2run(rle,indices)
  left_run = first(runs)
  right_run = last(runs)
  left_runvalue = rle.runvalues[left_run]
  right_runvalue = rle.runvalues[right_run]
  left_runend = rle.runends[left_run]
  right_runend = rle.runends[right_run]
  left_i = start(indices)
  right_i = last(indices)
  previous_run = left_run - 1
  next_run = right_run + 1
  at_start_of_run = (previous_run > 0 && left_i == rle.runends[previous_run] + 1) || left_i == 1
  at_end_of_run = right_i == right_runend
  match_left = left_run > 1 && rle.runvalues[previous_run] == value
  match_right = right_run < nrun(rle) && rle.runvalues[next_run] == value
  adjusted_runvalues = similar(rle.runvalues,0)
  adjusted_runends = similar(rle.runends,0)
  if at_end_of_run
    if at_start_of_run # in a run of length 1
      if match_right && match_left
        left_run = previous_run
      elseif match_right
        # do nothing
      elseif match_left
        rle.runends[previous_run] = right_runend
      else
        rle.runvalues[right_run] = value
        right_run = right_run - 1
      end
    else
      if match_right
        rle.runends[left_run] = left_i - 1
        left_run = left_run + 1
      else
        adjusted_runvalues = [left_runvalue,value]
        adjusted_runends = [left_i-1,right_i]
      end
    end
  elseif at_start_of_run
    if match_left
      rle.runends[previous_run] = last(indices)
      right_run = right_run - 1
    else
      adjusted_runvalues = [value,right_runvalue]
      adjusted_runends = [right_i,right_runend]
    end
  else # middle of a run, average case
    adjusted_runvalues = [left_runvalue,value,right_runvalue]
    adjusted_runends = [left_i-1,right_i,right_runend]
  end
  adjusted_runs = left_run:right_run
  splice!(rle.runvalues,adjusted_runs,adjusted_runvalues)
  splice!(rle.runends,adjusted_runs,adjusted_runends)
  return(rle)
end

## Getter shortcuts
function head(x::RLEVector,l::Integer=6)
    collect(x[ 1:l ])
end

function tail(x::RLEVector,l::Integer=6)
    collect( x[ length(x)-(l-1):end ] )
end

## Iterators
function start(rle::RLEVector)
  (1,1)
end

function next(rle::RLEVector, state)
  if state[2] == rle.runends[ state[1] ]
    newstate = (state[1] + 1, state[2] + 1)
  else
    newstate = (state[1],state[2] + 1)
  end
  return( (rle.runvalues[state[1]], newstate) )
end

function done(rle::RLEVector, state)
  state[1] > nrun(rle)
end

# Iterator for ranges based on RLE e.g. (value, start, end)
immutable RLEEachRangeIterator{T1,T2}
    rle::RLEVector{T1,T2}
end
eachrange(x::RLEVector) = RLEEachRangeIterator(x)
@deprecate each(x::RLEVector) eachrange(x)

function start(x::RLEEachRangeIterator)
    1
end

function next(x::RLEEachRangeIterator, state)
    newstate = state + 1
    first = starts(x.rle,state)
    last = ends(x.rle)[state]
    ( (values(x.rle)[state], first:last ), newstate )
end

function done(x::RLEEachRangeIterator, state)
    state > nrun(x.rle)
end

function length(x::RLEEachRangeIterator)
    nrun(x.rle)
end

"""
    tapply(data_vector, rle, function)
    tapply(data_vector, factor_vector, function)

Map a function to blocks of vector, like `tapply` in R. The first and second argument must be of the same
    length. For the case of a standard vector as the second argument, this vector need not be sorted.

## Examples
    factor = repeat( ["a","b","c","d","e"], inner=20 )
    rle = RLEVector( factor )
    x = collect(1:100)
    tapply( x, factor, mean )
    tapply( x, rle, mean )
"""
function tapply(x::Vector, rle::RLEVector, fun::Function)
    length(x) == length(rle) || throw(ArgumentError("Arguments 'x' and 'rle' must have the same length."))
    [ fun(x[r]) for (v,r) in eachrange(rle) ]
end

function tapply(x::Vector, factor::Vector, fun::Function)
    length(x) == length(factor) || throw(ArgumentError("Arguments 'x' and 'factor' must have the same length."))
    ind = sortperm(factor)
    x = x[ind]
    rle = RLEVector( factor[ind] )
    [ fun(x[r]) for (v,r) in eachrange(rle) ]
end

