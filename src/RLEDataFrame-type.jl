"""
An RLEDataFrame extends DataFrame and contains a colection of like-length and like-type
    RLEVectors. In a way, this creates a type like an RLE matrix. But, we deliberately
    avoid the complexity of matrix operations, such as factorization. It is expected
    that most operations will be column-wise. Based on RleDataFrame from Bioconductor's
    `genoset` package, also by Peter Haverty.

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
    columns::RLEVectorList{T1, T2}
    colindex::Index
    function RLEDataFrame(colindex, rvl)
        lens = map(length, rvl)
        (min, max) = extrema(lens)
        if min != max # Redundant with DataFrame
            throw(ArgumentError("All incoming columns must be of equal length."))
        end
        new(rvl, DataFrames.Index(colindex))
    end
end

function RLEDataFrame{T1, T2}(names::Vector{Symbol}, rles::Array{RLEVector{T1, T2}}...)
    rvl = RLEVectorList(rles)
    RLEDataFrame{T1, T2}(names, rvl)
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
