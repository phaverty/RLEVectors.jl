using RLEVectors


function searchsortedfirst1(v::AbstractVector, x::AbstractVector, lo::Int, hi::Int)
    indices = similar(x)
    const n = hi
    const min = lo - 1
    const max = hi + 1
    hi = hi + 1
    @inbounds for (i,query) in enumerate(x)
        indices[i] = searchsortedfirst(v, query, 1, n)
    end
    return(indices)
end

function searchsortedfirst2(v::AbstractVector, x::AbstractVector, lo::Int, hi::Int)
    indices = similar(x)
    const min = lo - 1
    const max = hi + 1
    hi = hi + 1
    @inbounds for (i,query) in enumerate(x)
        # unsorted x, restart left side
        if lo <= min || query <= v[lo]
            lo = min
        end
        # cast out exponentially to get hi to the right of query
        jump = 1
        while true
            if hi >= max
                hi = max
                break
            end
            if query <= v[hi]
                break
            end
            lo = hi
            hi = hi + jump
            jump = jump * 2
        end
        # binary search for the exact bin
        while hi - lo > 1
            m = (lo+hi)>>>1
            if query > v[m]
                lo = m
            else
                hi = m
            end
        end
        indices[i] = hi
    end
    return(indices)
end

function searchsortedfirst3(v::AbstractVector, x::AbstractVector, lo::Int, hi::Int)
    indices = similar(x)
    min = lo - 1
    max = hi + 1
    @inbounds for (i,query) in enumerate(x)
        hi = hi + 1 # 2X speedup with this *inside* the loop for sorted x
        # unsorted x, restart left side
        if lo <= min || query <= v[lo]
            lo = min
        end
        if hi >= max || query >= v[hi]
            hi = max
        end
        # binary search for the exact bin
        while hi - lo > 1
            m = (lo+hi)>>>1
            if query > v[m]
                lo = m
            else
                hi = m
            end
        end
        indices[i] = hi
    end
    return(indices)
end

macro timeit(ex)
# like @time, but returning the timing rather than the computed value
  return quote
    #gc_disable()
    local val = $ex # compile
    local t0 = time()
    for i in 1:1e5 val = $ex end
    local t1 = time()
    #gc_enable()
    t1-t0
  end
end

foo = RLEVector(collect(1:1000), collect(5:5:5000))
re = rlast(foo)
x = rand(1:1000, 1000)
sx = sort(x)

@timeit searchsortedfirst1(re, x, 1, 1000)
@timeit searchsortedfirst1(re, sx, 1, 1000)

@timeit searchsortedfirst2(re, x, 1, 1000)
@timeit searchsortedfirst2(re, sx, 1, 1000)

@timeit searchsortedfirst3(re, x, 1, 1000)
@timeit searchsortedfirst3(re, sx, 1, 1000)

using ProfileView
searchsortedfirst3(re, sx, 1, 1000); Profile.clear(); @profile for i in 1:1e4 foo + foo end; ProfileView.view()


