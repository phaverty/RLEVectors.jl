# The RLEVectors Types and Methods

## Index

```@index
```

## Types
```@docs
RLEVector
RLEDataFrame
```

## Standard Vector API methods

## Working with runs
`RLEVectors.jl` has a collection of functions for working with runs in standard
vectors. These are mostly for internal use, but are exported as they may be of
general use.

```@docs
numruns
ree
inverse_ree
```

## Working with run boundaries / ranges
We define some functions for comparing bins defined by our run end values.

```@docs
disjoin
disjoin_length
```

## split and tapply -like operations
An RLEVector can be used like R's factor type to apply a function over (contiguous) sections of another
vector. For example, here we break a vector into 5 groups and take the average of each group. In the second
example, we also scale each mean by the RLE run value corresponding to each group.

```@docs
tapply
```

## Summaries on RLEVectors
Often we want to summarize sections of our RLEVectors. For example, if the RLEVector
represent data along a genome, what are the average values associated with each of
a set of regions/genes?

```@docs
rangeMeans
```

## Going back and forth to R
```julia
using RCall
x = RLEVector([1,1,2,2,1,1,3,4])
y = RObject(x)
@rput y
R"z = y + 2L"
@rget z
```

## Utility Functions
We also define some utility functions for working with repeated values and binary
searching in bins/sorted integers like our run end values.

```@docs
rep
searchsortedfirst(v::AbstractVector, x::AbstractVector)
searchsortedfirst(v::AbstractVector, x::AbstractVector, lo::Int, hi::Int)
```
