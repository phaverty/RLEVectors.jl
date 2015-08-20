VERSION >= v"0.4.0-dev+6521" && __precompile__(true)
module RLEVectors

### Re-implementation of the Rle type from Bioconductor's IRanges package by H. Pages, P. Aboyoun and M.Lawrence

# types
export RLEVector, FloatRle, IntegerRle, BoolRle, StringRle, rfirst, rwidth, rlast, rvalue, nrun, similar, collect, similar
import Base: show, length, size, start, next, done, Forward, first, last, step, convert, similar, collect

# collections
import Base: eltype, unique, minimum, maximum, vcat, pop!, push!, shift!, unshift!, insert!, deleteat!, splice!, resize!, empty!, setdiff, symdiff, union, endof, maxabs, minabs, any, all, in
export       eltype, unique, minimum, maximum, vcat, pop!, push!, shift!, unshift!, insert!, deleteat!, splice!, resize!, empty!, setdiff, symdiff, union, endof, maxabs, minabs, any, all, in
export shove!, deleterun!, decrement_run!

# indexing
#import Base: getindex, setindex!
#import DataArrays: head, tail
export getindex, setindex!, ind2run, setrun!, ind2runcontext, head, tail
export getindex2

# describe
import Base: isempty, ndims
export ndims

# group_generics
import Base: +, -, *, /, ^, .+, .-, .*, ./, .^, div, mod, fld, rem
import Base: ==, >, <, !=, <=, >=, .==, .>, .<, .!=, .<=, .>=, &, |
import Base: abs, sign, sqrt, ceil, floor, trunc, cummax, cummin, cumprod, cumsum, log, log10, log2, log1p, acos, acosh, asin, asinh, atan, atanh
import Base: exp, expm1, cos, cosh, sin, sinh, tan, tanh, gamma, lgamma, digamma, trigamma
import Base: max, min, range, prod, sum, any, all, mean
import Base: setdiff, symdiff, issubset, in, union
import Base: indexin, findin, median, findmin, findmax
export .+, .-, .*, ./, .^, div, mod, fld, rem, ==, >, <, !=, <=, >=, .==, .>, .<, .!=, .<=, .>=, &, |
export abs, sign, sqrt, ceil, floor, trunc, cummax, cummin, cumprod, cumsum, log, log10, log2, log1p, acos, acosh, asin, asinh, atan, atanh
export exp, expm1, cos, cosh, sin, sinh, tan, tanh, gamma, lgamma, digamma, trigamma
export max, min, range, prod, sum, any, all, mean
export setdiff, symdiff, issubset, in, union
export indexin, findin, median, findmin, findmax
export findin2

# math
#import StatsBase: mode, countmap
export            mode, countmap

# ranges
export disjoin, disjoin_length, ree, inverse_ree, numruns

# utils
export rep

# sorting
import Base.Order: Ordering
import Base.Sort: QuickSortAlg
import Base: sort, sort!, issorted, reverse, reverse!, sortperm, Algorithm
export       sort, sort!, issorted, reverse, reverse!, sortperm

### Includes
include("utils.jl")
include("ranges.jl")
include("types.jl")
include("describe.jl")
include("indexing.jl")
include("group_generics.jl")
include("collections_api.jl")
include("math.jl")
include("sorting.jl")

end # Module RLEVectors
