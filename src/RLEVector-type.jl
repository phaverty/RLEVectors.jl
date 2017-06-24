### RLEVectors Type

"""
# RLEVectors
`RLEVectors` is an alternate implementation of the Rle type from Bioconductor's
IRanges package by H. Pages, P. Aboyoun and M. Lawrence. RLEVectors represent a
vector with repeated values as the ordered set of values and repeat extents. In
the field of genomics, data of various types measured across the ~3 billion
letters in the human genome can often be represented in a few thousand runs.
It is useful to know the bounds of genome regions covered by these runs, the
values associated with these runs, and to be able to perform various
mathematical operations on these values.

`RLEVectors` can be created from a single vector or a vector of values and a
vector of run ends. In either case runs of values or zero length runs will
be compressed out. RLEVectors can be expanded to a full vector with `collect`.

## Aliases
Several aliases are defined for specific types of RLEVector (or collections thereof).

    FloatRle              RLEVector{Float64,UInt32}
    IntegerRle            RLEVector{Int64,UInt32}
    BoolRle               RLEVector{Bool,UInt32}
    StringRle             RLEVector{String,UInt32}
    RLEVectorList{T1,T2}  Vector{ RLEVector{T1,T2} }

## Constructors
`RLEVector`s can be created by specifying a vector to compress or the runvalues and run ends.

    x = RLEVector([1,1,2,2,3,3,4,4,4])
    x = RLEVector([4,5,6],[3,6,9])

## Describing `RLEVector` objects
`RLEVector`s implement the usual descriptive functions for an array as well as some that are
specific to the type.

* `length(x)` The full length of the vector, uncompressed
* `size(x)` Same as `length`, as for any other vector
* `size(x,dim)` Returns `(length(x),1) for dim == 1`
* `starts(x)` The index of the beginning of each run
* `widths(x)` The width of each run
* `ends(x)` The index of the end of each run
* `values(x)` The data value for each run
* `isempty(x)` Returns boolean, as for any other vector
* `nrun(x)` Returns the number of runs represented in the array
* `eltype(x)` Returns the element type of the runs
* `endtype(x)` Returns the element type of the run ends

"""
immutable RLEVector{T1,T2 <: Integer} <: AbstractArray{T1, 1}
  runvalues::Vector{T1}
  runends::Vector{T2}
  function RLEVector(runvalues, runends)
    rle = new(runvalues,runends)
    return(rle)
  end
end

function RLEVector{T1,T2 <: Integer}(runvalues::Vector{T1}, runends::Vector{T2})
    ! issorted(runends) && throw(ArgumentError("RLEVector run ends must be sorted"))
    runvalues, runends = ree!(runvalues,runends)
    RLEVector{T1,T2}(runvalues, runends)
end

function RLEVector{T2 <: Integer}(runvalues::BitVector, runends::Vector{T2})
    ! issorted(runends) && throw(ArgumentError("RLEVector run ends must be sorted"))
    runvalues, runends = ree!(runvalues,runends)
    RLEVector{Bool,T2}(runvalues, runends)
end

function RLEVector(vec::Vector)
  runvalues, runends = ree(vec)
  RLEVector(runvalues, runends)
end

RLEVector{T1,T2 <: Integer}(runvalues::T1, runends::T2) = RLEVector{T1,T2}([runvalues], [runends])

#  Having specific types of Rle would be useful for lists of the same type, but Julia does a good job noticing that
#  Could also be useful for method definitions
const FloatRle = RLEVector{Float64,UInt32}
const IntegerRle = RLEVector{Int64,UInt32}
const BoolRle = RLEVector{Bool,UInt32}
const StringRle = RLEVector{String,UInt32}
const RLEVectorList{T1,T2} = Vector{ RLEVector{T1,T2} }
@doc (@doc RLEVector) FloatRle,  IntegerRle, BoolRle, StringRle, RLEVectorList

# similar
function similar(x::RLEVector, element_type::Type, dims::Dims)
    len = dims[1]
    if len == 0
        return( RLEVector(element_type[], eltype(x.runends)[]) )
    else
        return( RLEVector(zeros(element_type, 1), eltype(x.runends)[len]) )
    end
end

# show
function Base.show(io::IO, ::MIME"text/plain", x::RLEVector)
    t = typeof(x)::DataType
    show(io, t)
    n = nrun(x)
    write(io,"\n Run values: ")
    Base.show_vector(io,x.runvalues,"[", "]")
    write(io,"\n Run ends: ")
    Base.show_vector(io,x.runends,"[", "]")
end

function Base.show(io::IO, x::RLEVector)
    write(io,"Values: ")
    Base.show_vector(io,values(x),"[", "]")
    write(io," Ends: ")
    Base.show_vector(io,widths(x),"[", "]")
end

function ree!(x::RLEVector)
    ree!(x.runvalues,x.runends)
end

# conversions
convert(::Type{Vector}, x::RLEVector) = collect(x)
convert(::Type{Set}, x::RLEVector) = Set(values(x))
convert(::Type{RLEVector}, x::Vector) = RLEVector(x)
promote_rule(::Type{Set}, ::Type{RLEVector}) = Set

# the basics
function collect(x::RLEVector)
  inverse_ree(x.runvalues,x.runends)
end

function isequal(x::RLEVector, y::RLEVector)
isequal(x.runends,y.runends) && isequal(x.runvalues, y.runvalues)
end

Base.hash(a::RLEVector) = hash(a.runvalues, hash(a.runlengths, hash(:RLEVector)))
==(a::RLEVector, b::RLEVector) = isequal(a.runvalues, b.runvalues) && isequal(a.runends, b.runends) && true
