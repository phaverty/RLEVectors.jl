__precompile__()

module RLEVectors

using Compat
import Compat.String
using Reexport
@reexport using DataFrames


# RLEVector type
export RLEVector, FloatRle, IntegerRle, BoolRle, StringRle, RLEVectorList, rfirst, rwidth, rlast, rvalue, nrun, similar, collect, similar
import Base: show, length, size, start, next, done, Forward, first, last, step, convert, similar, collect, isequal

# collections
import Base: eltype, unique, minimum, maximum, vcat, pop!, push!, shift!, unshift!, insert!, deleteat!, splice!, resize!, empty!, endof, maxabs, minabs, any, all, in, intersect
export       eltype, unique, minimum, maximum, vcat, pop!, push!, shift!, unshift!, insert!, deleteat!, splice!, resize!, empty!, endof, maxabs, minabs, any, all, in, intersect
export shove!, deleterun!, decrement_run!

# indexing
import Base: getindex, setindex!
export getindex, setindex!, ind2run, setrun!, ind2runcontext, head, tail, RLERangesIterator, each

# describe
import Base: isempty, ndims
export ndims, endtype

# group_generics
import Base: +, -, *, /, ^, .+, .-, .*, ./, .^, div, mod, fld, rem
import Base: ==, >, <, !=, <=, >=, .==, .>, .<, .!=, .<=, .>=, &, |
import Base: abs, sign, sqrt, ceil, floor, trunc, cummax, cummin, cumprod, cumsum, log, log10, log2, log1p, acos, acosh, asin, asinh, atan, atanh
import Base: exp, expm1, cos, cosh, sin, sinh, tan, tanh, gamma, lgamma, digamma, trigamma
import Base: max, min, range, prod, sum, any, all, mean
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
import StatsBase: mode, countmap
export mode, countmap

# ranges
export disjoin, disjoin_length, ree, inverse_ree, numruns, rangeMeans

# utils
import Base: searchsortedfirst
export rep, searchsortedfirst

# sorting
import Base.Order: Ordering
import Base.Sort: QuickSortAlg
import Base: sort, sort!, issorted, reverse, reverse!, sortperm, Algorithm
export       sort, sort!, issorted, reverse, reverse!, sortperm, permute_runs

# data frames
import DataFrames: AbstractDataFrame, DataFrame, Index, head, tail
export RLEDataFrame

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

if VERSION >= v"0.4.0"
    include("precompile.jl")
    _precompile_()
end

end # Module RLEVectors
