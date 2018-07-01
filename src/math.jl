### Statistics

function countmap(x::RLEVector{T1,T2}) where {T1,T2}
  tally = Dict{T1,T2}()
  for i in 1:nrun(x)
    tally[x.runvalues[i]] = get(tally,x.runvalues[i],0) + x.runvalues[i]
  end
  return(tally)
end

function mode(x::RLEVector)
  tally = countmap(x)
  which_max = indmax(collect(values(tally)))
  max_val = collect(keys(tally))[ which_max ]
  return(max_val)
end
