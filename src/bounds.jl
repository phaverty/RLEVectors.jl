Base.searchsortedlast(v::AbstractVector, x::AbstractVector) = searchsortedfirst(v, x, 1, length(x))
function Base.searchsortedlast(v::AbstractVector, x::AbstractVector, lo::Int, hi::Int)

#function leftBound(values, low, high, query)
#    # Right bound likely close to previous (low) so jump towards it exponentially
#    probe = low + 1
#    jump = 2
#    while probe <= high && values[probe] <= query
#        low = probe
#        probe = probe + jump
#        jump = jump << 1
#    end
#    high = probe > high ? high + 1 : probe # Don't go off the end
#    probe = (lo+hi) >>> 1
#    while (low < probe)
#        if (values[probe] > query) {
#            high = probe
#        else
#            low = probe
#        end
#        probe = (lo+hi)>>>1
#
#    end
#    return(low)
#end
