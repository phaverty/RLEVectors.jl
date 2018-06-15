### Vector/Collections API

function append!(x::RLEVector, y::RLEVector)
    last_x_run = nrun(x)
    length_x = length(x)
    if last(x) == first(y)
        last_x_run = last_x_run - 1
    end
    new_nrun = last_x_run + nrun(y)
    resize!(x.runvalues, new_nrun)
    resize!(x.runends, new_nrun)
    x.runvalues[(last_x_run + 1:end)] = y.runvalues
    x.runends[(last_x_run + 1:end)] = y.runends + length_x
    x
end

function vcat(x::RLEVector, y::RLEVector...)
    out = copy(x)
    for yi in y
        append!(out, yi)
    end
    out
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

function popfirst!(x::RLEVector)
  isempty(x) && throw(ArgumentError("array must be non-empty"))
  item = x.runvalues[1]
  x.runends[:] = x.runends - 1
  if x.runends[1] == 0
    deleteat!(x.runvalues,1)
    deleteat!(x.runends,1)
  end
  return(item)
end
shift!(x::RLEVector) = popfirst!(x)

function pushfirst!{T,T2 <: Integer}(x::RLEVector{T,T2},item)
  item = convert(T,item) # Copying how base does it for arrays
  x.runends[:] = x.runends + 1
  if item != x.runvalues[1]
    unshift!(x.runvalues,item)
    unshift!(x.runends,1)
  end
  return(x)
end
shove!{T,T2 <: Integer}(x::RLEVector{T,T2},item) = pushfirst!(x,item)
unshift!{T,T2 <: Integer}(x::RLEVector{T,T2},item) = pushfirst!(x,item)
@deprecate shove! pushfirst!
@deprecate unshift! pushfirst!
@deprecate shift! popfirst!

function deleterun!(x::RLEVector,i::Integer)
    x.runends[i:end] -= widths(x,i)
    if (i > 1 && i < nrun(x) && x.runvalues[i-1] == x.runvalues[i+1])
        deleteat!(x.runvalues,(i-1):i)
        deleteat!(x.runends,(i-1):i)
    else
        deleteat!(x.runvalues,i)
        deleteat!(x.runends,i)
    end
    x
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

function insert!(x::RLEVector{T1,T2}, i::Integer, item) where {T1,T2 <: Integer}
    if i == 1
        unshift!(x,item)
    elseif i == length(x) + 1
        push!(x,item)
    else
        _item = convert(T1, item)
        (run, index_in_run, run_remainder) = ind2runcontext(x,i)
        if x.runvalues[run] == _item
            x.runends[run:end] = x.runends[run:end] + 1
        else
            new_nrun = nrun(x) + 2
            resize!(x.runvalues, new_nrun)
            resize!(x.runends, new_nrun)
            x.runvalues[(run + 2):end] = x.runvalues[run:(end-2)]
            x.runvalues[run + 1] = _item
            x.runends[(run + 2):end] = x.runends[run:(end-2)] + 1
            x.runends[run + 1] = i
            x.runends[run] = i - 1
        end
    end
    x
end

_default_splice = RLEVector(Union{}[],Int64[])
function splice!(x::RLEVector, i::Integer, ins::RLEVector=_default_splice)
    nrun_x = nrun(x)
    (1 <= i <= length(x)) || throw(BoundsError())
    if length(ins) == 0
        run = ind2run(x,i)
        current = x.runvalues[run]
        decrement_run!(x,run)
    else
        (run, index_in_run, run_remainder) = ind2runcontext(x,i)
        current = x.runvalues[run]
        # Splice ins into adjusted x
        widths!(x.runends)
        x.runends[run] = run_remainder
        nrun_out = run + nrun(ins) + ((nrun_x - run) + 1)
        resize!(x.runvalues, nrun_out)
        resize!(x.runends, nrun_out)
        x.runvalues[(run + (nrun_out - nrun_x)):nrun_out] = x.runvalues[run:nrun_x]
        x.runends[(run + (nrun_out - nrun_x)):nrun_out] = x.runends[run:nrun_x]
        x.runvalues[(run + 1):(run + nrun(ins))] = ins.runvalues
        x.runends[(run + 1):(run + nrun(ins))] = widths(ins)
        x.runends[run] = index_in_run - 1
        cumsum!(x.runends, x.runends)
        ree!(x.runvalues,x.runends)
    end
    return(current)
end

function splice!(x::RLEVector, index::UnitRange, ins::RLEVector=_default_splice)
    nrun_x = nrun(x)
    i_left = first(index)
    i_right = last(index)
    if i_left == i_right
        return(splice!(x,i_left,ins))
    end
    (run_left, run_right, index_in_run_left, run_remainder_right) = ind2runcontext(x,index)
    run_range = run_left:run_right
    if i_left > i_right # Insert without removing
        current = similar(x,0)
    else
        current = RLEVector(x.runvalues[run_range], x.runends[run_range] - (i_left - 1))
        current.runends[end] = current.runends[end] - run_remainder_right
    end
    # Splice ins into adjusted x
    widths!(x.runends)
    x.runends[run_right] = run_remainder_right
    nrun_out = run_left + nrun(ins) + ((nrun_x - run_right) + 1)
    resize!(x.runvalues, nrun_out)
    resize!(x.runends, nrun_out)
    x.runvalues[(run_right + (nrun_out - nrun_x)):nrun_out] = x.runvalues[run_right:nrun_x]
    x.runends[(run_right + (nrun_out - nrun_x)):nrun_out] = x.runends[run_right:nrun_x]
    x.runvalues[(run_left + 1):(run_left + nrun(ins))] = ins.runvalues
    x.runends[(run_left + 1):(run_left + nrun(ins))] = widths(ins)
    x.runends[run_left] = index_in_run_left - 1
    cumsum!(x.runends, x.runends)
    ree!(x.runvalues,x.runends)
    return(current)
end

function splice!(x::RLEVector, i::Union{Integer,UnitRange}, ins::AbstractArray)
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
