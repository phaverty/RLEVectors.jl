### Vector/Collections API

function vcat(x::RLEVector, y::RLEVector)
  RLEVector( vcat(x.runvalues, y.runvalues), vcat(x.runends, y.runends + length(x)))
end

function pop!(x::RLEVector)
  runcount = nrun(x)
  isempty(x) && throw(ArgumentError("array must be non-empty"))
  item = x.runvalues[end]
  x.runends[end] -= 1
  if x.runends[end] == 0
    deleteat!(x.runvalues,runcount)
    deleteat!(x.runends,runcount)
  end
  return(item)
end

function push!{T,T2 <: Integer}(x::RLEVector{T,T2},item)
  item = convert(T,item) # Copying how base does it for arrays
  if !isempty(x) && (item == x.runvalues[end])
    x.runends[end] += 1
  else
    push!(x.runvalues,item)
    push!(x.runends, (isempty(x) ? 0 : x.runends[end]) + 1)
  end
  return(x)
end

function shift!(x::RLEVector)
  isempty(x) && throw(ArgumentError("array must be non-empty"))
  item = x.runvalues[1]
  x.runends[:] = x.runends - 1
  if x.runends[1] == 0
    deleteat!(x.runvalues,1)
    deleteat!(x.runends,1)
  end
  return(item)
end

function shove!{T,T2 <: Integer}(x::RLEVector{T,T2},item)
  item = convert(T,item) # Copying how base does it for arrays
  x.runends[:] = x.runends + 1
  if item != x.runvalues[1]
    unshift!(x.runvalues,item)
    unshift!(x.runends,1)
  end
  return(x)
end
unshift!{T,T2 <: Integer}(x::RLEVector{T,T2},item) = shove!(x,item) # Does unshift come from perl? Isn't Larry Wall a linguist? C'mon!

function deleterun!(x::RLEVector,i::Integer)
  x.runends[i:end] -= widths(x,i)
  if (i > 1 && i < nrun(x) && x.runvalues[i-1] == x.runvalues[i+1])
    splice!(x.runvalues,(i-1):i)
    splice!(x.runends,(i-1):i)
  else
    deleteat!(x.runvalues,i)
    deleteat!(x.runends,i)
  end
  return(x)
end

function decrement_run!(x::RLEVector,run::Integer)
  if widths(x,run) == 1
    deleterun!(x,run)
  else
    x.runends[run:end] -= 1
  end
  return(x)
end

function deleteat!(x::RLEVector,i::Integer)
  run = ind2run(x,i)
  decrement_run!(x,run)
end

function insert!{T,T2 <: Integer}(x::RLEVector{T,T2},i::Integer,item)
    if i == length(x) + 1
        splice!(x,length(x),[x[end],item])
    else
        splice!(x,i,[item,x[i]])
    end
    x
end

_default_splice = RLEVector(Union{}[],Int64[])
function splice!(x::RLEVector, i::Integer, ins::RLEVector=_default_splice)
  if i < 1 || i > length(x)
    throw(BoundsError())
  end
  if length(ins) == 0
    run = ind2run(x,i)
    current = x.runvalues[run]
    decrement_run!(x,run)
  else
    (run, index_in_run, run_remainder) = ind2runcontext(x,i)
    current = x.runvalues[run]
    right_shift = length(ins) - length(i)
    x.runends[run:end] += right_shift
    ins.runends += (i-1)
    if index_in_run == 1
      ins_vals = [ins.runvalues; x.runvalues[run]]
      ins_ends = [ins.runends; x.runends[run]]
    else
      ins_vals = [x.runvalues[run]; ins.runvalues; x.runvalues[run]]
      ins_ends = [i-1; ins.runends; x.runends[run]]
    end
    x.runvalues = vcat( x.runvalues[1:run-1], ins_vals, x.runvalues[run+1:end] )
    x.runends = vcat( x.runends[1:run-1], ins_ends, x.runends[run+1:end])
    ree!(x.runvalues,x.runends)
  end
  return(current)
end

function splice!(x::RLEVector, index::Range, ins::RLEVector=_default_splice) # Can I do index::Union(Integer,UnitRange) here to have just one method?
  i_left = start(index)
  i_right = last(index)
  if i_left < 1 || i_right > length(x)
    throw(BoundsError())
  end
  if length(index) == 0
  current = similar(x,0)
  (run_right, index_in_run_right, run_remainder_right) = (run_left, index_in_run_left, run_remainder_left) = ind2runcontext(x,i_left)
  else
    current = x[index]
    (run_left, index_in_run_left, run_remainder_left) = ind2runcontext(x,i_left)
    (run_right, index_in_run_right, run_remainder_right) = ind2runcontext(x,i_right)
  end
  ins.runends += (i_left - 1)
  right_shift = nrun(ins) - length(index)
  x.runends[run_right:end] += right_shift
  if index_in_run_left == 1
    ins_vals = [ins.runvalues; x.runvalues[run_right]]
    ins_ends = [ins.runends; x.runends[run_right]]
  else
    ins_vals = [x.runvalues[run_left]; ins.runvalues; x.runvalues[run_right]]
    ins_ends = [i_left-1; ins.runends; x.runends[run_right]]
  end
  x.runvalues = vcat( x.runvalues[1:run_left-1], ins_vals, x.runvalues[run_right+1:end] )
  x.runends = vcat( x.runends[1:run_left-1], ins_ends, x.runends[run_right+1:end] )
  ree!(x.runvalues,x.runends)
  return(current)
end

function splice!(x::RLEVector, i::Integer, ins::AbstractArray)
  splice!(x,i,RLEVector(ins))
end

function splice!(x::RLEVector, i::Range, ins::AbstractArray)
  splice!(x,i,RLEVector(ins))
end

# Appended space initialized with zero unlike base array
function resize!(x::RLEVector, nl::Integer) # Based on base version for array
    l = length(x)
    if nl > l
        push!(x.runends,nl)
        push!(x.runvalues,0)
    else
        nl < 0 && throw(ArgumentError("new length must be ≥ 0"))
        (run, index_in_run, run_remainder) = ind2runcontext(x,nl)
        resize!(x.runends,run)
        resize!(x.runvalues,run)
        x.runends[end] = x.runends[end] - run_remainder
    end
    return(x)
end

function empty!(x::RLEVector)
  empty!(x.runvalues)
  empty!(x.runends)
  return(x)
end

### Set API
# Mostly handled by convert and promote rules in RLEVector-type.jl

function intersect(x::RLEVector, sets...)
    ok = trues(length(x.runvalues))
    for (i, v) in enumerate(x.runvalues)
        for s in sets
            if !in(v, s)
                ok[i] = false
                break
            end
        end
    end
    RLEVector( x.runvalues[ ok ], cumsum( widths(x)[ ok ] ) )
end
