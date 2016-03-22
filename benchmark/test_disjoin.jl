using RLEVectors

function disjoin(x::RLEVector, y::RLEVector)
    i = nrun(x)
    j = nrun(y)
    length(x) != length(y) && error("RLEVectors of unequal length.")
    runind = disjoin_length(x.runends, y.runends)
    xv = x.runvalues
    yv = y.runvalues
    xe = x.runends
    ye = y.runends
    runends = Array(promote_type(eltype(x), eltype(y)), runind)
    runvalues_x = Array(eltype(x), runind)
    runvalues_y = Array(eltype(x), runind)
    @inbounds while true
        if xe[i] > ye[j]
            runends[runind] = xe[i]
            runvalues_x[runind] = xv[i]
            runvalues_y[runind] = yv[j]
            i = i - 1
        elseif xe[i] < ye[j]
            runends[runind] = ye[j]
            runvalues_x[runind] = xv[i]
            runvalues_y[runind] = yv[j]
            j = j - 1
        else
            runends[runind] = xe[i]
            runvalues_x[runind] = xv[i]
            runvalues_y[runind] = yv[j]
            i = i - 1
            j = j - 1
        end
        runind = runind - 1
        if i == 0
            for r in 1:j
                runends[r] = ye[r]
                runvalues_x[r] = xv[i]
                runvalues_y[r] = yv[r]
            end
            break
        elseif j == 0
            for r in 1:i
                runends[r] = xe[r]
                runvalues_x[r] = xv[r]
                runvalues_y[r] = yv[j]
            end
            break
        end
    end
    return( (runends, runvalues_x, runvalues_y ) )
end


foo = RLEVector([1, 1, 2, 3, 4])
#goo = RLEVector([1, 2, 3, 4])
goo = RLEVector([1, 1, 2, 3, 3])
disjoin2(foo, goo)
