### RleVectors Type

@doc """
# RleVectors
`RleVectors` is an alternate implementation of the Rle type from Bioconductor's
IRanges package by H. Pages, P. Aboyoun and M. Lawrence. RleVectors represent a
vector with repeated values as the ordered set of values and repeat extents. In
the field of genomics, data of various types measured across the ~3 billion
letters in the human genome can often be represented in a few thousand runs.
It is useful to know the bounds of genome regions covered by these runs, the
values associated with these runs, and to be able to perform various
mathematical operations on these values.

`RleVectors` can be created from a single vector or a vector of values and a
vector of run ends. In either case runs of values or zero length runs will
be compressed out. RleVectors can be expanded to a full vector like a
`Range` with `collect`.

### Examples
 * `x = RleVector([1,1,2,2,3,3,4,4,4])`
 * `x = RleVector([4,5,6],[3,6,9])`
 * `collect(x)`
""" ->

## Types and constructors

type RleVector{T1,T2 <: Integer} # <: Vector{T1} # Subtyping Vector is nothing but trouble at this point
    runvalues::Vector{T1}
  runends::Vector{T2}
  function RleVector(runvalues, runends)
    rle = new(runvalues,runends)
    return(rle)
  end
end

function RleVector{T1,T2 <: Integer}(runvalues::Vector{T1}, runends::Vector{T2})
  nrun = numruns(runvalues,runends)
  if nrun != length(runends)
    runvalues, runends = ree(runvalues,runends,nrun)
  end
  RleVector{T1,T2}(runvalues, runends)
end

function RleVector{T2 <: Integer}(runvalues::BitVector, runends::Vector{T2})
  nrun = numruns(runvalues,runends)
  if nrun != length(runends)
    runvalues, runends = ree(runvalues,runends,nrun)
  end
  RleVector{Bool,T2}(runvalues, runends)
end

function RleVector(vec::Vector)
  runvalues, runends = ree(vec)
  RleVector(runvalues, runends)
end

#  Having specific types of Rle would be useful for lists of the same type, but Julia does a good job noticing that
#  Could also be useful for method definitions
typealias FloatRle RleVector{Float64,Uint32}
typealias IntegerRle RleVector{Int64,Uint32}
typealias BoolRle RleVector{Bool,Uint32}
typealias StringRle RleVector{String,Uint32}

# similar
function similar(x::RleVector,length=0)
  if length == 0
    return( RleVector(eltype(x.runvalues)[], eltype(x.runends)[]) )
  else
    return( RleVector(zeros(eltype(x.runvalues), 1), eltype(x.runends)[length]) )
  end
end

# show
function show(io::IO, x::RleVector)
    t = typeof(x)::DataType
    show(io, t)
    print("\n")
    n = nrun(x)
    if n > 10
        rv = x.runvalues
        re = x.runends
        print("run values: [$(rv[1]),$(rv[2]),$(rv[5]) \u2026 $(rv[n-4]),$(rv[n-1]),$(rv[n])]\n")
        print("run ends:   [$(re[1]),$(re[2]),$(re[5]) \u2026 $(re[n-4]),$(re[n-1]),$(re[n])]")
    else
        println("run values: ", x.runvalues)
        println("run ends:   ", x.runends)
    end
end

# conversions
convert(::Type{Vector}, x::RleVector) = collect(x)
convert(::Type{Set}, x::RleVector) = Set(x.runvalues)

# collect
# way faster than inverse_rle(x.runvalues, rwidth(x)) (50X)
function collect(x::RleVector)
  inverse_ree(x.runvalues,x.runends)
end

function ==(x::RleVector, y::RleVector)
  x.runends == y.runends && x.runvalues == y.runvalues
end

function isequal(x::RleVector, y::RleVector)
  isequal(x.runends,y.runends) && isequal(x.runvalues, y.runvalues)
end


## Stuff that really should be in ranges.jl except that I need them here because of load order drama

function disjoin(x::RleVector, y::RleVector)
  disjoin(x.runends,y.runends)
end

