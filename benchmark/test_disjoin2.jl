using RLEVectors

function disjoinA(x::RLEVector, y::RLEVector)
    length(x) != length(y) && error("RLEVectors of unequal length.")
    runends = disjoin(x.runends, y.runends)
    runvalues_x = x[runends]
    runvalues_y = y[runends]
    return( (runends, runvalues_x, runvalues_y ) )
end

function disjoinB(x::RLEVector, y::RLEVector)
    length(x) != length(y) && error("RLEVectors of unequal length.")
    runends = disjoin(x.runends, y.runends)
    #nrun = disjoin_length(x.runends, y.runends) # Alternative
    #nx = nrun(x)
    #ny = nrun(y)
    xv = x.runvalues
    yv = y.runvalues
    xe = x.runends
    ye = y.runends
    runends = disjoin(xe, ye)
    nrun = length(runends)

    runvalues_x = Array(eltype(x), nrun)
    runvalues_y = Array(eltype(x), nrun)
    i = j = 1
    while true
        if xe[i] > ye[j]
            println("i bigger")
            current_end = runends[runind] = xe[i]
#            runvalues_x[runind] = xv[i]
#            runvalues_y[runind] = yv[j]
#            i = i - 1
        elseif xe[i] < ye[j]
            println("j bigger")
            runends[runind] = ye[j]
#            runvalues_x[runind] = xv[i]
#            runvalues_y[runind] = yv[j]
#            j = j - 1
        else
            println("tie")
            runends[runind] = xe[i]
#            runvalues_x[runind] = xv[i]
#            runvalues_y[runind] = yv[j]
#            i = i - 1
#            j = j - 1
        end
        
        runind = runind - 1
        println(runvalues_x)
        println(runvalues_y)
    end
    return( (runends, runvalues_x, runvalues_y ) )
end

function disjoinC(x::RLEVector, y::RLEVector)
    length(x) != length(y) && error("RLEVectors of unequal length.")
    runends = disjoin(x.runends, y.runends)
    runvalues_x = x[runends]
    runvalues_y = y[runends]
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
    return( (runends, runvalues_x, runvalues_y ) )
end


foo = IntegerRle(Vector{Int32}(collect(1:1000)), Vector{Int32}(collect(5:5:5000)))

