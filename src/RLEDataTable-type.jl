"""
An RLEDataTable extends DataTable and contains a colection of like-length and like-type
    RLEVectors. In a way, this creates a type like an RLE matrix. But, we deliberately
    avoid the complexity of matrix operations, such as factorization. It is expected
    that most operations will be column-wise. Based on RleDataTable from Bioconductor's
    `genoset` package (also by Peter Haverty).

### Constructors

```julia
DataTable(columns::Vector{RLEVector},  names::Vector{Symbol})
DataTable(kwargs...)
```

### Examples
```julia
RLEDataTable( [RLEVector([1, 1, 2]),  RLEVector([2, 2, 2])], [:a, :b] )
RLEDataTable( [RLEVector([5])],[:a] )
# RLEDataTable( a=RLEVector([5,2,2]), b=RLEVector([4,4,4])
```

"""
type RLEDataTable <: AbstractDataTable
    columns::Vector{RLEVector}
    colindex::Index
    function RLEDataTable(columns,colindex)
        if length(columns) != length(colindex)
            throw(ArgumentError("Incoming columns collection and column names must have the same length."))
        end
        if length(columns) > 0
            lens = map(length, columns)
            (min, max) = Base.extrema(lens)
            if min != max
                throw(ArgumentError("All incoming columns must be of equal length."))
            end
        end
        new(columns, colindex)
    end
end

function RLEDataTable(columns, cnames::Vector{Symbol})
    return RLEDataTable(columns, Index(cnames))
end

DataTables.nrow(x::RLEDataTable) = length(x.columns[1])
DataTables.ncol(x::RLEDataTable) = length(x.columns)
DataTables.index(x::RLEDataTable) = x.colindex
DataTables.columns(x::RLEDataTable) = x.columns

function Base.show(io::IO, x::RLEDataTable)
    t = typeof(x)
    show(io, t)
    write(io,"\n Names: ")
    Base.show_vector(io,names(x.colindex),"[", "]")
    write(io,"\n Columns: \n")
    print(io,x.columns)
end

function RLEDataTable(; kwargs...)
    result = RLEDataTable(RLEVector[], Index())
    for (k, v) in kwargs
        result[k] = v
    end
    return result
end

### Need getindex, setindex!


function rowSums(df::RLEDataTable)
    sums = x[1]
    for i in 2:ncol(x)
        sums = sums + x[i]
    end
    return(sums)
end
rowMeans(df::RLEDataTable) = rowSum(df) ./ ncol(df)
colSums(df::RLEDataTable) = map(sum, df)
colMeans(df::RLEDataTable) = colSums(df) ./ nrow(df)


