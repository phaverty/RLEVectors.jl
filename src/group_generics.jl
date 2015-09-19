# Groups of functions with a shared signature defined for vectors
# https://stat.ethz.ch/R-manual/R-patched/library/methods/html/S4groupGeneric.html
# Translated to julia, adding scalar versions of operators
# Arith
# "+", "-", "*", "^", "%%", "%/%", "/"
const arith_group = [:(+), :(-), :(*), :(/), :(^), :(.+), :(.-), :(.*), :(./), :(.^), :(div), :(mod), :(fld), :(rem)]

# Compare
# "=="), ">"), "<"), "!="), "<="), ">="
const compare_group = [:(.==), :(.>), :(.<), :(.!=), :(.<=), :(.>=)]

# Logic
# "&"), "|".
const logic_group = [:(&), :(|)]

# Ops
# "Arith", "Compare", "Logic"
const ops_group = vcat( arith_group, compare_group, logic_group )

# Math
# "abs", "sign", "sqrt", "ceiling", "floor", "trunc", "cummax", "cummin", "cumprod", "cumsum", "log", "log10", "log2", "log1p", "acos", "acosh", "asin", "asinh", "atan", "atanh", "exp", "expm1", "cos", "cosh", "sin", "sinh", "tan", "tanh", "gamma", "lgamma", "digamma", "trigamma"
const math_group = [:abs, :sign, :sqrt, :ceil, :floor, :trunc, :cummax, :cummin, :cumprod, :cumsum, :log, :log10, :log2, :log1p, :acos, :acosh, :asin, :asinh, :atan, :atanh, :exp, :expm1, :cos, :cosh, :sin, :sinh, :tan, :tanh, :gamma, :lgamma, :digamma, :trigamma]

# Math2
# "round", "signif"
# leaving out for now

# Summary
# "max", "min", "range", "prod", "sum", "any", "all"
const summary_group =[:maximum, :minimum, :range, :prod, :sum, :any, :all, :eltype, :unique, :minimum, :maximum, :extrema, :first, :last, :maxabs, :minabs, :any, :all] # sum and prod special

# Complex
# "Arg", "Conj", "Im", "Mod", "Re"
# leaving out for now

const set_group = [:setdiff, :symdiff, :issubset, :in, :union]

const set_group_w_splat = [:union]

### Operators, methods that take two arguments and return a modified RLEVector
function ^(x::RLEVector,y::Integer) # Necessary to prevent an ambiguity warning
  rv = ^(x.runvalues,y)
  RLEVector(rv,x.runends)
end

for op in ops_group
    @eval begin
        # Rle, Rle
        function ($op)(x::RLEVector, y::RLEVector)
            length(x) != length(y) && error("RLEVectors must be of the same length for this operation.")
            runends = disjoin(x,y)
            @inbounds runvals = [ ($op)(x[i], y[i]) for i in runends]
            RLEVector( runvals, runends )
        end
        # Rle, scalar
        function ($op)(x::RLEVector,y::Number)
            rv = ($op)(x.runvalues,y)
            RLEVector(rv,x.runends)
        end
        # Number, Rle
        function ($op)(y::Number, x::RLEVector)
            rv = ($op)(y,x.runvalues)
            RLEVector(rv,x.runends)
        end
    end
end

## Methods that delegate to the runvalues and return an RLEVector
## Methods that take one argument, an RLEVector, and delegate to rle.runvalues and return an RLEVector
for op in math_group
  @eval begin
    function ($op)(x::RLEVector)
      rv = ($op)(x.runvalues)
      RLEVector(rv, x.runends)
    end
  end
end

## Methods that take one argument, an RLEVector, and delegate to rle.runvalues and return something other than an RLEVector
for op in setdiff(summary_group,[:sum,:prod])
  @eval begin
    ($op)(x::RLEVector) = ($op)(x.runvalues)
  end
end

## Methods that take two arguments, delegate to rle.runvalues and return something other than an RLEVector
# for op in set_group
#   @eval begin
#     ($op){T1,T2<:Integer,T3,T4<:Integer}(x::RLEVector{T1,T2}, y::RLEVector{T3,T4}) = ($op)(x.runvalues,y.runvalues)
#     ($op)(x::RLEVector, y::Any) = ($op)(x.runvalues,y)
#     ($op)(y::Any, x::RLEVector) = ($op)(y, x.runvalues)
#   end
# end

# Defaulting to fun(itr) for prod, sumabs, sumabs2, count
for op in [:findmin, :findmax]
  @eval begin
    function ($op)(x::RLEVector)
      m = ($op)(x.runvalues)
      (m[1], rfirst(x,m[2]))
    end
  end
end

function indexin(x::RLEVector,y::RLEVector)
   RLEVector( indexin(x.runvalues,y), x.runends)
end

function indexin(x::RLEVector,y)
  RLEVector( indexin(x.runvalues,y), x.runends )
end

function indexin(x,y::RLEVector)
  rval = Int[ i == 0 ? 0 : y.runends[i] for i in indexin(x,y.runvalues) ]
end

function findin(x::RLEVector,y::RLEVector)
  runs = findin(x.runvalues,y.runvalues)
  re = x.runends
  vcat( [ collect( rfirst(x,i):re[i] ) for i in runs ]... )  # hashing in above findin takes the vast majority of the time, don't sweat the time here
end

function findin(x::RLEVector,y::UnitRange)
  runs = findin(x.runvalues,y)
  re = x.runends
  vcat( [ collect( rfirst(x,i):re[i] ) for i in runs ]... ) # hashing in above findin takes the vast majority of the time, don't sweat the time here
end

function findin(x::RLEVector,y)
  runs = findin(x.runvalues,y)
  re = x.runends
  vcat( [ collect( rfirst(x,i):re[i] ) for i in runs ]... )  # hashing in above findin takes the vast majority of the time, don't sweat the time here
end

function findin(x,y::RLEVector)
  findin(x,y.runvalues)
end

function median(x::RLEVector; checknan::Bool=true)
  len = length(x)
  len < 2 && return(x.runvalues)
  sorted = sort(x)
  if checknan && isnan(sorted[end])
    return(NaN)
  end
  mid = fld(len,2)
  mid_run = ind2run(sorted,mid)
  if mod(len,2) == 0 && mid == sorted.runends[mid_run] # even numbered and at end of run, avg with next value
    median = (x.runvalues[mid_run] + x.runvalues[mid_run+1]) / 2
  else
    median = x.runvalues[mid_run + 1]
  end
  return(median)
end

function sum{T1,T2}(x::RLEVector{T1,T2})
  rval = zero(T1)
   @simd for i in 1:nrun(x)
    @inbounds rval = rval + (x.runvalues[i] * x.runends[i])
  end
  return(rval)
end

function mean{T1,T2}(x::RLEVector{T1,T2})
  rval = sum(x) / length(x)
end
