module RLEVectors

using DataFrames
using AxisArrays
using StatsBase
using RCall

# RLEVector type
export RLEVector, FloatRle, IntegerRle, BoolRle, StringRle, RLEVectorList, rfirst, rwidth, rlast, rvalue, nrun, similar, collect, similar, starts, widths, widths!, ends, values
import Base: show, length, size, start, next, done, Forward, first, last, step, convert, similar, collect, isequal, values, copy

# collections
import Base: eltype, unique, minimum, maximum, vcat, pop!, push!, popfirst!, pushfirst!, insert!, deleteat!, splice!, resize!, empty!, endof, maxabs, minabs, any, all, in, intersect, append!
export       eltype, unique, minimum, maximum, vcat, pop!, push!, popfirst!, pushfirst!, insert!, deleteat!, splice!, resize!, growat!, empty!, endof, maxabs, minabs, any, all, in, intersect, append!
export deleterun!, decrement_run!

# indexing
import Base: getindex, setindex!
#import Base: iterate
export getindex, setindex!, ind2run, setrun!, ind2runcontext, head, tail, RLERangesIterator, eachrange, tapply, iterate

# describe
import Base: isempty
export endtype

# group_generics
import Base: broadcast, map
import Base: +, -, *, /, ^, .+, .-, .*, ./, .^, div, mod, fld, rem
import Base: ==, >, <, !=, <=, >=, .==, .>, .<, .!=, .<=, .>=, &, |
import Base: abs, sign, sqrt, ceil, floor, trunc, cummax, cummin, cumprod, cumsum, log, log10, log2, log1p, acos, acosh, asin, asinh, atan, atanh
import Base: exp, expm1, cos, cosh, sin, sinh, tan, tanh, gamma, lczgamma, digamma, trigamma
import Base.Statistics: max, min, range, prod, sum, any, all, mean
import Base: in
import Base: indexin, findin, median, findmin, findmax
export .+, .-, .*, ./, .^, div, mod, fld, rem, ==, >, <, !=, <=, >=, .==, .>, .<, .!=, .<=, .>=, &, |
export abs, sign, sqrt, ceil, floor, trunc, cummax, cummin, cumprod, cumsum, log, log10, log2, log1p, acos, acosh, asin, asinh, atan, atanh
export exp, expm1, cos, cosh, sin, sinh, tan, tanh, gamma, lgamma, digamma, trigamma
export max, min, range, prod, sum, any, all, mean
export in
export indexin, findin, median, findmin, findmax
export findin2

# math
#import StatsBase: mode, countmap
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
import DataFrames: AbstractDataFrame, DataFrame, Index, head, tail, index, columns, nrow, ncol
export RLEDataFrame, nrow, ncol, columns, index, names
export rowSums, rowMeans, rowMedians, colSums, colMeans, colMedians

# RCall
#import RCall: sexp, rcopy, RClass, rcopytype, @R_str, S4Sxp

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
