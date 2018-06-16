### Indexing

## Helper functions

"""
    ind2run(rle::RLEVector, i::Integer) -> run_index
    ind2run(rle::RLEVector, i::UnitRange) -> range_of_first_to_last_overlap
    ind2run(rle::RLEVector, i::AbstractArray) -> vector_of_runs

Locate runs, get index of run corresponding to the i-th value in the expanded runs
"""
function ind2run(rle::RLEVector, i::Integer)
  re = rle.runends
  n = length(re)
  0 < i <= last(re) || throw(BoundsError())
  run = searchsortedfirst(re,i,1,n)
  run
end

function ind2run(rle::RLEVector,i::UnitRange)
    re = rle.runends
    n = length(re)
    left_run = searchsortedfirst(re,first(i),1,n)
    right_run = searchsortedfirst(re,last(i),left_run,n)
    right_run <= n || throw(BoundsError())  # Can't be < 1
    left_run:right_run
end

function ind2run(rle::RLEVector, i::AbstractArray)
  re = rle.runends
  n = length(re)
  runs = searchsortedfirst(re,i,1,n)
  maximum(runs) <= n || throw(BoundsError())  # Can't be < 1
  runs
end

"""
    ind2runcontext(rle::RLEVector, i::Integer) -> (runindex, index_in_run, values_in_run_after_i)
    ind2runcontext(rle::RLEVector, i::UnitRange) -> (runindex, index_in_run, values_in_run_after_i)

Index of the run corresponding to the i'th value in the expanded runs, index in run and remainder of run
"""
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
Base.IndexStyle(::Type{<:RLEVector}) = IndexLinear()
Base.endof(rle::RLEVector) = length(rle)
#Base.firstindex(rle::RLEVector) = 1
#Base.lastindex(rle::RLEVector) = length(rle)
#Base.axes(rle::RLEVector) = (Base.OneTo(length(rle)),)

function Base.getindex(rle::RLEVector, i::Int)
    run = ind2run(rle,i)
    rle.runvalues[run]
end

function Base.setindex!(rle::RLEVector, value, i::Int)
  # FIXME: do not use splice because it allocates a return vector
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
  rle
end

function Base.getindex(rle::RLEVector, ind::Array{Bool, 1})
    RLEVector(rle[ find(ind) ])
end

function Base.setindex!(rle::RLEVector, value::AbstractArray, ind::Array{Bool, 1})
    rle[ find(ind) ] = value
    RLEVector(rle)
end

## Indexing optimizations
function Base.getindex(rle::RLEVector{T1,T2} where {T1,T2}, ind::UnitRange)
    run_indices = ind2run(rle, ind)
    v = rle.runvalues[run_indices]
    e = rle.runends[run_indices]
    e[end] = last(ind)
    e = e - (first(ind) - 1)
    RLEVector{T1,T2}(v, e)
end

function Base.getindex(x::RLEVector, i::AbstractVector)
    run_indices = ind2run(x, i)
    RLEVector( x.runvalues[ run_indices ] )
end

function Base.setindex!(x::RLEVector, value::AbstractVector, indices::UnitRange)
    setindex!(x, RLEVector(value), indices)
end

function Base.setindex!(x::RLEVector, value::RLEVector, indices::UnitRange)
    length(value) != length(indices) && throw(BoundsError())
    i_left = first(indices)
    i_right = last(indices)
    if i_left == i_right
        return(setindex!(x,ins,i_left))
    end
    nrun_x = nrun(x)
    nrun_value = nrun(value)
    (run_left, run_right, index_in_run_left, run_remainder_right) = ind2runcontext(x,indices)
    # Move run markers to denote parts of original data that will be kept, accomodating completely filled runs or adjacent matches
    # We will keep 1:run_left and run_right:end and fill in the middle with value
    if run_remainder_right == 0
        run_right = run_right + 1
        if run_right < nrun_x && last(value) == x.runvalues[run_right + 1]
            run_right = run_right + 1
        end
    end
    if index_in_run_left == 1
        run_left = run_left - 1
        if run_left > 0 && first(value) == x.runvalues[run_left]
            run_left = run_left - 1
        end
    end
    nrun_out = run_left + nrun_value + ((nrun_x - run_right) + 1)
    nrun_diff = nrun_out - nrun_x
    # Resize and move
    if nrun_diff > 0
        resize!(x.runvalues, nrun_out)
        resize!(x.runends, nrun_out)
        run_right_range = run_right:nrun_x
        x.runvalues[run_right_range + nrun_diff] = x.runvalues[run_right_range]
        x.runends[run_right_range + nrun_diff] = x.runends[run_right_range]
    elseif nrun_diff < 0
        delete_range = (run_left + 1):(run_left - nrun_diff)
        deleteat!(x.runvalues, delete_range)
        deleteat!(x.runends, delete_range)
    end
    # Insert incoming values
    insert_range = (run_left + 1):(run_left + length(value.runvalues))
    x.runvalues[insert_range] = value.runvalues
    x.runends[insert_range] = value.runends + (i_left - 1)
    if run_left > 0 && index_in_run_left != 1
        x.runends[run_left] = i_left - 1
    end
    x
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

## New style iterator
## state is (run_index, overall_index)
## We will assume that this iterate method is the only source of `state` and
## the only invalid state possible is one past the end
eltype{T1,T2}(::RLEVector{T1,T2}) = T1
function iterate(x::RLEVector, state = (1,1))
    (run_index, overall_index) = state
    if overall_index > length(x) # run_index > nrun(x) || overall_index > length(x)
        out = nothing
    else
        this_end = ends(x)[run_index]
        if overall_index > this_end
            run_index = run_index + 1
        end
        out = (values(x)[run_index], (run_index, overall_index + 1))
    end
    out
end



# FIXME: add reverse iterator, see https://docs.julialang.org/en/latest/manual/interfaces/#man-interface-array-1

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
    allunique(rle.runvalues) || throw(ArgumentError("The values in an `RLEVector` must be unique when used as a factor with `tapply`."))
    Dict( (v,fun(x[r])) for (v,r) in eachrange(rle) ) # Note: using view on x[r] is not faster
end

function tapply(x::Vector{T1}, factor::Vector{T2}, fun::Function) where T1 where T2
    length(x) == length(factor) || throw(ArgumentError("Arguments 'x' and 'factor' must have the same length."))
    if ! issorted(factor)
        ind = sortperm(factor)
        y = x[ind]
        rle = RLEVector( factor[ind] )
    else
        rle = RLEVector( factor )
        y = x
    end
    Dict( (v,fun(x[r])) for (v,r) in eachrange(rle) )
end
