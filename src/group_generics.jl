summary_group = [:range, :any, :all, :eltype, :unique, :minimum, :maximum, :extrema, :first, :last]

for op in summary_group
    @eval begin
        function ($op)(x::RLEVector)
            ($op)(x.runvalues)
        end
    end
end

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

function indexin(a, b::RLEVector)
    inds = starts(b)
    bdict = Dict{eltype(b),eltype(inds)}()
    for (val, ind) in zip(b.runvalues, inds)
        get!(bdict, val, ind)
    end
    return Union{eltype(inds), Nothing}[
        get(bdict, i, nothing) for i in a
    ]
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
