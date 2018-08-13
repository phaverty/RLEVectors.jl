const summary_group =[:range, :any, :all, :eltype, :unique, :minimum, :maximum, :extrema, :first, :last, :any, :all]

Base.broadcast(f, x::RLEVector, y...) = RLEVector( [f(el,y...) for el in x.runvalues], ends(x) )
function Base.broadcast(f, x::RLEVector, y::RLEVector)
    (runends, runvalues_x, runvalues_y) = disjoin(x, y)
    RLEVector( map(f,runvalues_x,runvalues_y), runends )
end
Base.map(f, x::RLEVector) = RLEVector( map(f,x.runvalues), ends(x) )

## Methods that take two arguments, delegate to rle.runvalues and return something other than an RLEVector
in(y::T1, x::RLEVector{T1,T2}) where {T1,T2<:Integer} = in(y, x.runvalues)

# Defaulting to fun(itr) for some things
for op in [:findmin, :findmax]
  @eval begin
    function ($op)(x::RLEVector)
      m = ($op)(x.runvalues)
      (m[1], starts(x,m[2]))
    end
  end
end

indexin(x::RLEVector,y::RLEVector) = RLEVector( indexin(x.runvalues,y), x.runends)
indexin(x::RLEVector,y::AbstractVector) = RLEVector( indexin(x.runvalues,y), x.runends )
indexin(x::AbstractVector,y::RLEVector) = Int[ i == 0 ? 0 : y.runends[i] for i in indexin(x,y.runvalues) ]

findall(in(y::RLEVector), x) = findall(in(y.runvalues), x)
function findall(in(y::RLEVector), x::RLEVector)
  runs = findall(in(y.runvalues), x.runvalues)
  re = x.runends
  vcat( [ starts(x,i):re[i] for i in runs ]... ) # hashing in above findin takes the vast majority of the time, don't sweat the time here
end

function findall(in(y::UnitRange), x::RLEVector) # ambig fix
  runs = findall(in(y), x.runvalues)
  re = x.runends
  vcat( [ starts(x,i):re[i] for i in runs ]... ) # hashing in above findin takes the vast majority of the time, don't sweat the time here
end

function findall(in(y), x::RLEVector)
  runs = findall(in(y), x.runvalues)
  re = x.runends
  vcat( [ starts(x,i):re[i] for i in runs ]... ) # hashing in above findin takes the vast majority of the time, don't sweat the time here
end

function median(x::RLEVector)
  len = length(x)
  len <= 2 && return(middle(x.runvalues))
  sorted = sort(x)
  mid = cld(len,2)
  mid_run = ind2run(sorted,mid)
  if mod(len,2) == 0 && mid == sorted.runends[mid_run] # even numbered and at end of run, avg with next value
    median = middle(sorted.runvalues[mid_run], sorted.runvalues[mid_run+1])
  else
    median = middle(sorted.runvalues[mid_run])
  end
  return(median)
end

function sum(x::RLEVector{T1,T2}) where {T1,T2}
  rval = zero(T1)
   @simd for i in 1:nrun(x)
    @inbounds rval = rval + (x.runvalues[i] * widths(x, i))
  end
  return(rval)
end

mean(x::RLEVector) = rval = sum(x) / length(x)
