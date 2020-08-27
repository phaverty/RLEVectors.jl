module RLEVectors

using Base.Broadcast
using Requires
using Statistics
using StatsBase
using DataFrames
using Reexport
@reexport using Missings

# RLEVector type
export RLEVector,
    FloatRle,
    IntegerRle,
    BoolRle,
    StringRle,
    RLEVectorList,
    rfirst,
    rwidth,
    rlast,
    rvalue,
    nrun,
    similar,
    collect,
    similar,
    starts,
    widths,
    widths!,
    ends,
    values
import Base: show, length, size, first, last, step, convert, similar, collect, isequal, values, copy

# collections
import Base.==
import Base:
    eltype,
    vcat,
    pop!,
    push!,
    popfirst!,
    pushfirst!,
    insert!,
    deleteat!,
    splice!,
    resize!,
    empty!,
    lastindex,
    intersect,
    append!
export eltype,
    vcat,
    pop!,
    push!,
    popfirst!,
    pushfirst!,
    insert!,
    deleteat!,
    splice!,
    resize!,
    growat!,
    empty!,
    lastindex,
    intersect,
    append!
export deleterun!, decrement_run!

# indexing
import Base.Broadcast: BroadcastStyle, Broadcasted
import Base: getindex, setindex!
import Base: iterate
export getindex,
    setindex!, ind2run, setrun!, ind2runcontext, RLERangesIterator, eachrange, tapply, iterate

# describe
import Base: isempty
export endtype

# group_generics
import Base: broadcast, map
import Base: in, indexin, findmin, findmax
import Base: range, any, all, sum, eltype, unique, minimum, maximum, extrema, first, last
export range, any, all, eltype, sum, unique, minimum, maximum, extrema, first, last
export in, indexin, findmin, findmax
import Statistics: mean, median
export mean, median

# math
import StatsBase: mode, countmap
export mode, countmap

# ranges
export disjoin, disjoin_length, ree, ree!, inverse_ree, numruns, rangeMeans

# utils
export rep

# sorting
import Base.Order: Ordering
import Base.Sort: QuickSortAlg
import Base: sort, sort!, issorted, reverse, reverse!, sortperm, Algorithm
export sort, sort!, issorted, reverse, reverse!, sortperm, permute_runs

# DataFrames
import DataFrames: AbstractDataFrame, DataFrame, Index, index, nrow, ncol
export RLEDataFrame, nrow, ncol, columns, index, names
export rowSums, rowMeans, rowMedians, colSums, colMeans, colMedians

# Missings
import Missings: allowmissing, disallowmissing
export allowmissing, disallowmissing

### Includes
include("utils.jl")
include("runs.jl")
include("RLEVector-type.jl")
include("RLEDataFrame-type.jl")
include("ranges.jl")
include("describe.jl")
include("indexing.jl")
include("group_generics.jl")
include("collections_api.jl")
include("math.jl")
include("sorting.jl")
include("missing.jl")
include("precompile.jl")
_precompile_()

function __init__()
    @require RCall = "6f49c342-dc21-5d91-9882-a32aef131414" include("rcall.jl")
end

end # module RLEVectors
