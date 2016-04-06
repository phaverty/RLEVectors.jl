"""
An RLEDataFrame extends DataFrame and contains a colection of like-length and like-type
    RLEVectors. In a way, this creates a type like an RLE matrix. But, we deliberately
    avoid the complexity of matrix operations, such as factorization. It is expected
    that most operations will be column-wise.

### Constructors

```julia
DataFrame(columns::Vector{RLEVector},  names::Vector{Symbol})
DataFrame(kwargs...)
```

### Examples
```julia
RLEDataFrame( [RLEVector([1, 1, 2]),  RLEVector([2, 2, 2])], [:a, :b] )
```

"""
type RLEDataFrame{T1, T2} <: AbstractDataFrame
    columns::Vector{RLEVector{T1, T2}}
    colindex::Index
#    function RLEDataFrame(columns, colindex)
#        new(columns, DataFrames.Index(colindex))
#    end
end

function RLEDataFrame{T1, T2}(rles::Array{RLEVector{T1, T2}}, names::Vector{Symbol})
    RLEDataFrame{T1, T2}(rles, names)
end

function rowSums(df::RLEDataFrame)
    sums = x[1]
    for i in 2:ncol(x)
        sums = sums + x[i]
    end
    return(sums)
end
rowMeans(df::RLEDataFrame) = rowSum(df) ./ ncol(df)
colSums(df::RLEDataFrame) = map(sum, df)
colMeans(df::RLEDataFrame) = colSums(df) ./ nrow(df)
