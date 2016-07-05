## Range operations
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
disjoin_length(x::RLEVector, y::RLEVector) = disjoin_length(x.runends, y.runends)

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
    length(y) == 0 && return(x) # At least one value to work on
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

function disjoin(x::RLEVector, y::RLEVector)
    length(x) != length(y) && error("RLEVectors of unequal length.")
    runends = disjoin(x.runends, y.runends)
    runvalues_x = x.runvalues[ ind2run(x, runends) ]
    runvalues_y = y.runvalues[ ind2run(y, runends) ]
#    #nrun = disjoin_length(x.runends, y.runends) # Alternative
#    #nx = nrun(x)
#    #ny = nrun(y)
#    xv = x.runvalues
#    yv = y.runvalues
#    xe = x.runends
#    ye = y.runends
#    runends = disjoin(xe, ye)
#    nrun = length(runends)
#
#    runvalues_x = Array(eltype(x), nrun)
#    runvalues_y = Array(eltype(x), nrun)
#    runvalues_x[:] = 0 # debug
#    runvalues_y[:] = 0 # debug
#    i = j = 1
#    while true
#        if xe[i] > ye[j]
#            println("i bigger")
#            current_end = runends[runind] = xe[i]
##            runvalues_x[runind] = xv[i]
##            runvalues_y[runind] = yv[j]
##            i = i - 1
#        elseif xe[i] < ye[j]
#            println("j bigger")
#            runends[runind] = ye[j]
##            runvalues_x[runind] = xv[i]
##            runvalues_y[runind] = yv[j]
##            j = j - 1
#        else
#            println("tie")
#            runends[runind] = xe[i]
##            runvalues_x[runind] = xv[i]
##            runvalues_y[runind] = yv[j]
##            i = i - 1
##            j = j - 1
#        end
#        
#        runind = runind - 1
#        println(runvalues_x)
#        println(runvalues_y)
#    end
    return( (runends, runvalues_x, runvalues_y) )
end

# optimization opportunities: hoist rle element lookups and use the searchsortedfirst with all the args
function rangeMeans(ranges::Vector{UnitRange}, rle::RLEVector)
    res = similar(ranges, Float64)
    first_run = 1
    last_run = nrun(rle)
    @inbounds for (i, r) in enumerate(ranges)
        first_ind = r[1]
        last_ind = r[end]
        first_run = searchsortedfirst(rle.runends, first_ind)
        last_run = searchsortedlast(rle.runends, last_ind)
        if first_run == last_run  # Range all in one run, special case here allows simpler logic below
            res[i] = rle.runvalues[first_run]
        else
            # First run
            current_end = rle.runends[first_run]
            inner_n = (current_end - first_ind) + 1
            temp_sum = rle.runvalues[first_run] * inner_n
            # Inner runs
            for run_index in (first_run + 1):(last_run - 1)
                previous_end = current_end
                current_end = rle.runends[run_index]
      	        inner_n = current_end - previous_end
	        temp_sum = temp_sum + (rle.runvalues[run_index] * inner_n)
            end
            # Last run
            inner_n = last_ind - current_end
            temp_sum = temp_sum + (rle.runvalues[last_run] * inner_n)
            # Calculate mean
            res[i] = temp_sum / ((last_ind - first_ind) + 1)
        end
    end
    return(res)
end
