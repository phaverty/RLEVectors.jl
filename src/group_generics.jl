# Groups of functions with a shared signature defined for vectors
# https://stat.ethz.ch/R-manual/R-patched/library/methods/html/S4groupGeneric.html
# Translated to julia, adding scalar versions of operators
# Arith
# "+", "-", "*", "^", "%%", "%/%", "/"
#const arith_group = [:(+), :(-), :(*), :(/), :(^), :(.+), :(.-), :(.*), :(./), :(.^), :(div), :(mod), :(fld), :(rem)]
const arith_group = [:(+), :(-), :(.+), :(.-), :(.*), :(./), :(.^), :(div), :(mod), :(fld), :(rem)] # Just scalar arith for vectors

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

### Operators, methods that take two arguments and return a modified RLEVector
function ^(x::RLEVector,y::Integer) # Necessary to prevent an ambiguity warning
  rv = ^(x.runvalues,y)
  RLEVector(rv,x.runends)
end

.^(x::Base.Irrational{:e}, y::RLEVectors.RLEVector) = .^(x,y) # Ambig fix
for op in ops_group
    @eval begin
        # Rle, Rle
        function ($op)(x::RLEVector, y::RLEVector)
            (runends, runvalues_x, runvalues_y) = disjoin(x, y)
            runvalues = $(op)(runvalues_x, runvalues_y)
            RLEVector{eltype(runvalues), eltype(runends)}(runvalues, runends)
        end
        # Rle, Number
        ($op){T<:Integer}(x::RLEVector{Bool,T},y::Bool) = RLEVector{eltype(x), endtype(x)}( ($op)(x.runvalues,y), x.runends ) # Ambig fix
        ($op)(x::RLEVector,y::Number) = RLEVector{eltype(x), endtype(x)}( ($op)(x.runvalues,y), x.runends )
        # Number, Rle
        ($op){T<:Integer}(y::Bool, x::RLEVector{Bool,T}) = RLEVector{eltype(x), endtype(x)}( ($op)(y,x.runvalues), x.runends ) # Ambig fix
        ($op)(y::Number, x::RLEVector) = RLEVector{eltype(x), endtype(x)}( ($op)(y,x.runvalues), x.runends )
    end
end

## Methods that delegate to the runvalues and return an RLEVector
## Methods that take one argument, an RLEVector, and delegate to rle.runvalues and return an RLEVector
for op in math_group
  @eval ($op)(x::RLEVector) = RLEVector( ($op)(x.runvalues), x.runends )
end

## Methods that take one argument, an RLEVector, and delegate to rle.runvalues and return something other than an RLEVector
for op in setdiff(summary_group,[:sum,:prod])
  @eval ($op)(x::RLEVector) = ($op)(x.runvalues)
end

## Methods that take two arguments, delegate to rle.runvalues and return something other than an RLEVector
in{T1,T2<:Integer}(y::T1, x::RLEVector{T1,T2}) = in(y, x.runvalues)

# Defaulting to fun(itr) for some things
for op in [:findmin, :findmax]
  @eval begin
    function ($op)(x::RLEVector)
      m = ($op)(x.runvalues)
      (m[1], rfirst(x,m[2]))
    end
  end
end

indexin(x::RLEVector,y::RLEVector) = RLEVector( indexin(x.runvalues,y), x.runends)
indexin(x::RLEVector,y::AbstractVector) = RLEVector( indexin(x.runvalues,y), x.runends )
indexin(x::AbstractVector,y::RLEVector) = Int[ i == 0 ? 0 : y.runends[i] for i in indexin(x,y.runvalues) ]

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

function median(x::RLEVector)
    # Superfluous x / 1.0 is to always return a Float64
  len = length(x)
  len < 2 && return(x.runvalues[1] / 1.0)
  sorted = sort(x)
  mid = fld(len,2)
  mid_run = ind2run(sorted,mid)
  if mod(len,2) == 0 && mid == sorted.runends[mid_run] # even numbered and at end of run, avg with next value
    median = (sorted.runvalues[mid_run] + sorted.runvalues[mid_run+1]) / 2
  else
    median = sorted.runvalues[mid_run] / 1.0
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
