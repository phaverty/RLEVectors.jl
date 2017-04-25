"""
An RLEDataFrame extends DataFrame and contains a colection of like-length and like-type
    RLEVectors. In a way, this creates a type like an RLE matrix. But, we deliberately
    avoid the complexity of matrix operations, such as factorization. It is expected
    that most operations will be column-wise. Based on RleDataFrame from Bioconductor's
    `genoset` package (also by Peter Haverty).

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
    function RLEDataFrame(rvl, names)
        lens = map(length, rvl)
        (min, max) = Base.extrema(lens)
        if min != max # Redundant with DataFrame
            throw(ArgumentError("All incoming columns must be of equal length."))
        end
        new(rvl, DataFrames.Index(names))
    end
end

function RLEDataFrame{T1, T2}(names, x::RLEVector{T1, T2}... )
    rvl = RLEVectorList{T1,T2}()
    for rle in x
        push!(rvl, rle)
    end
    RLEDataFrame{T1, T2}(rvl, names)
end

Base.show(io::IO, ::MIME"text/plain",  a::RLEDataFrame) = show(io, a)
function show(io::IO, x::RLEDataFrame)
    show(io, names(x))
end
function show(x::RLEDataFrame)
    println(names(x))
end


nrow(x::RLEDataFrame) = length(x.columns[1])
index(x::RLEDataFrame) = x.colindex

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


