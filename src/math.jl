### Statistics

function countmap(x::RLEVector{T1,T2}) where {T1,T2}
    tally = Dict{T1,T2}()
    for (v, w) in zip(values(x), widths(x))
        tally[v] = get(tally, v, 0) + w
    end
    tally
end

function mode(x::RLEVector)
    tally = countmap(x)
    which_max = argmax(collect(values(tally)))
    max_val = collect(keys(tally))[which_max]
    max_val
end
