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
  ind_in_run = run == 1 ? i : i - rle.runends[run - 1]
  (run, ind_in_run, runend - i)
end

function ind2runcontext(rle::RLEVector, i::UnitRange)
  s = first(i)
  e = last(i)
  n = length(rle)
  runs = ind2run(rle, i)
  left_run = first(runs)
  right_run = last(runs)
  runend = rle.runends[right_run]
  ind_in_run = left_run == 1 ? s : s - rle.runends[left_run - 1]
  (left_run, right_run, ind_in_run, runend - e)
end

## Just enough for AbstractArray
Base.IndexStyle(::Type{<:RLEVector}) = IndexLinear()
Base.firstindex(rle::RLEVector) = 1
Base.lastindex(rle::RLEVector) = length(rle)

function Base.getindex(rle::RLEVector, i::Int)
    run = ind2run(rle,i)
    rle.runvalues[run]
end

function Base.setindex!(rle::RLEVector, value, i::Int)
  run = ind2run(rle,i)
  runvalue = rle.runvalues[run]
  runend = rle.runends[run]
  #value == runvalue && return rle # replace with same value, no-op
  isequal(value, runvalue) && return rle
  previous_run = run - 1
  next_run = run + 1
  at_start_of_run = (previous_run > 0 && i == rle.runends[previous_run] + 1) || i == 1
  at_end_of_run = i == runend
  match_left = run > 1 && isequal(rle.runvalues[previous_run], value)
  match_right = run < nrun(rle) && isequal(rle.runvalues[next_run], value)
  if at_end_of_run
    if at_start_of_run # in a run of length 1
      if match_right && match_left
        deleteat!(rle.runvalues, previous_run:run)
        deleteat!(rle.runends, previous_run:run)
      elseif match_right
        deleteat!(rle.runvalues,run)
        deleteat!(rle.runends,run)
      elseif match_left
        deleteat!(rle.runvalues,run)
        deleteat!(rle.runends,previous_run)
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
      rle.runends[run] = i - 1
      next_run = run + 1
      growat!(rle.runvalues, next_run, 2)
      growat!(rle.runends, next_run, 2)
      rle.runvalues[next_run] = value
      rle.runends[next_run] = i
      next_run = next_run + 1
      rle.runvalues[next_run] =  runvalue
      rle.runends[next_run] = runend
  end
  rle
end

## Indexing optimizations
# function Base.getindex(rle::RLEVector, i::Colon) # FIXME: delete?
#     copy(rle)
# end
#
# # FIXME: Bool methods can go if methods for ind == abstract array are tightened to AE of Integer
# function Base.getindex(x::RLEVector, ind::Array{Bool, 1}) # FIXME: delete?
#     x[ findall(ind) ]
# end
#
# function Base.setindex!(x::RLEVector, value::AbstractArray, ind::Array{Bool, 1}) # FIXME: delete?
#     x[ findall(ind) ] = value
#     x
# end
#
# function Base.getindex(x::RLEVector, indices::UnitRange)
#     (left_run, right_run, index_in_left_run, run_remainder_right) = ind2runcontext(x,indices)
#     n_run = (right_run - left_run) + 1
#     f = first(indices)
#     v = similar(x.runvalues, n_run)
#     e = similar(x.runends, n_run)
#     offset = f - 1
#     i = 1
#     @inbounds while left_run <= right_run
#         v[i] = x.runvalues[left_run]
#         e[i] = x.runends[left_run] - offset
#         left_run = left_run + 1
#         i = i + 1
#     end
#     e[end] = e[end] - run_remainder_right
#     RLEVector{eltype(x),endtype(x)}(v, e)
# end
#
# function Base.getindex(x::RLEVector, i::AbstractVector)
#     run_indices = ind2run(x, i)
#     RLEVector( x.runvalues[ run_indices ] )
# end
#
# function Base.setindex!(x::RLEVector, value::AbstractVector, indices::UnitRange)
#     setindex!(x, RLEVector(value), indices)
# end
#
# #function Base.setindex!(x::RLEVector, value, indices::UnitRange)
# #    setindex!(x, RLEVector(value, length(indices)), indices)
# #end
#
# function Base.setindex!(x::RLEVector, value::RLEVector, indices::UnitRange)
#     length(value) != length(indices) && throw(BoundsError())
#     i_left = first(indices)
#     i_right = last(indices)
#     if i_left == i_right
#         return(setindex!(x,ins,i_left))
#     end
#     nrun_x = nrun(x)
#     nrun_value = nrun(value)
#     (run_left, run_right, index_in_run_left, run_remainder_right) = ind2runcontext(x,indices)
#     # Move run markers to denote parts of original data that will be kept, accomodating completely filled runs or adjacent matches
#     # We will keep 1:run_left and run_right:end and fill in the middle with value
#     # FIXME: factor out these two expressions for something like ind2insertcontext
#     fix_partial_run_left = false
#     if x.runvalues[run_left] == first(value)
#         run_left = run_left - 1
#     elseif index_in_run_left == 1
#         run_left = run_left - 1
#         if run_left > 0 && first(value) == x.runvalues[run_left]
#             run_left = run_left - 1
#         end
#     else
#         fix_partial_run_left = true
#     end
#     if x.runvalues[run_right] == last(value)
#         nrun_value = nrun_value - 1
#     elseif run_remainder_right == 0
#         run_right = run_right + 1
#         if run_right <= nrun_x && last(value) == x.runvalues[run_right]
#             nrun_value = nrun_value - 1
#         end
#     end
#     nrun_out = run_left + nrun_value + ((nrun_x - run_right) + 1)
#     nrun_diff = nrun_out - nrun_x
#     # Resize and move
#     if nrun_diff > 0
#         growat!(x, run_right, nrun_diff)
#     elseif nrun_diff < 0
#         delete_range = (run_left + 1):(run_left - nrun_diff)
#         deleteat!(x.runvalues, delete_range)
#         deleteat!(x.runends, delete_range)
#     end
#     if fix_partial_run_left
#         x.runends[run_left] = i_left - 1
#     end
#     # Insert incoming values
#     value_runvalues = value.runvalues
#     value_runends = value.runends
#     bump = i_left - 1
#     @inbounds for i in 1:nrun_value
#         il = i + run_left
#         x.runvalues[il] = value_runvalues[i]
#         x.runends[il] = value_runends[i] + bump
#     end
#     x
# end

## Iterators
# Iterator for ranges based on RLE e.g. (value, start:end)
struct RLEEachRangeIterator{T1,T2}
    rle::RLEVector{T1,T2}
end
eachrange(x::RLEVector) = RLEEachRangeIterator(x)
length(x::RLEEachRangeIterator) = nrun(x.rle)
eltype(::RLEEachRangeIterator{T1,T2}) where {T1,T2} = Tuple{T1,UnitRange{T2}}

function iterate(x::RLEEachRangeIterator, state = 1)
    state > nrun(x.rle) && return nothing
    newstate = state + 1
    first = starts(x.rle,state)
    last = ends(x.rle,state)
    ( (_values(x.rle)[state], first:last ), newstate )
end

## New style iterator
## state is (run_index, overall_index)
## We will assume that this iterate method is the only source of `state` and
## the only invalid state possible is one past the end
eltype(::RLEVector{T1,T2}) where {T1,T2} = T1
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
