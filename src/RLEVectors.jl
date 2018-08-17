module RLEVectors

using StatsBase
using RCall
using Statistics

# RLEVector type
export RLEVector, FloatRle, IntegerRle, BoolRle, StringRle, RLEVectorList, rfirst, rwidth, rlast, rvalue, nrun, similar, collect, similar, starts, widths, widths!, ends, values
import Base: show, length, size, first, last, step, convert, similar, collect, isequal, values, copy

# collections
import Base.==
import Base: eltype, unique, minimum, maximum, vcat, pop!, push!, popfirst!, pushfirst!, insert!, deleteat!, splice!, resize!, empty!, lastindex, any, all, in, intersect, append!
export       eltype, unique, minimum, maximum, vcat, pop!, push!, popfirst!, pushfirst!, insert!, deleteat!, splice!, resize!, growat!, empty!, lastindex, any, all, in, intersect, append!
export deleterun!, decrement_run!

# indexing
import Base: getindex, setindex!
import Base: iterate
export getindex, setindex!, ind2run, setrun!, ind2runcontext, head, tail, RLERangesIterator, eachrange, tapply, iterate

# describe
import Base: isempty
export endtype

# group_generics
import Base: broadcast, map
import Statistics: max, min, range, prod, sum, any, all, mean, median
import Base: in, indexin, findmin, findmax, findall
import Base: range, prod, sum, any, all, eltype, unique, minimum, maximum, extrema, first, last, any, all
export range, prod, sum, any, all, eltype, unique, minimum, maximum, extrema, first, last, any, all
export max, min, range, prod, sum, any, all, mean, median
export indexin, findin, findmin, findmax, findall, in

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
export       sort, sort!, issorted, reverse, reverse!, sortperm, permute_runs

# data frames
#import DataFrames: AbstractDataFrame, DataFrame, Index, head, tail, index, columns, nrow, ncol
export RLEDataFrame, nrow, ncol, columns, index, names
export rowSums, rowMeans, rowMedians, colSums, colMeans, colMedians

# RCall
import RCall: sexp, rcopy, RClass, rcopytype, @R_str, S4Sxp

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
include("rcall.jl")
include("precompile.jl")
_precompile_()

end # Module RLEVectors
