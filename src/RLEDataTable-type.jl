# A few things we want from DataTables

typealias DFIndex AxisArray{Int64,1,Vector{Int64},Tuple{AxisArrays.Axis{:row,Array{Symbol,1}}}}
typealias ColumnIndex Union{Symbol,Integer}

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
x = RLEDataTable( [RLEVector([1, 1, 2]), RLEVector([2, 2, 2])], [:a, :b]) 
y = RLEDataTable( [RLEVector([5])],[:a] )
z = RLEDataTable( a=RLEVector([5,2,2]), b=RLEVector([4,4,4])
```
"""
type RLEDataTable <: AbstractDataTable
    columns::Vector{RLEVector}
    colindex::DFIndex
    function RLEDataTable(columns,colnames::Vector{Symbol})
        ncol = length(columns)
        nval = length(colnames)
        if ncol != nval
            throw(ArgumentError("Incoming columns collection and column names must have the same length."))
        end
        if ncol > 0
            lens = map(length, columns)
            (min, max) = Base.extrema(lens)
            if min != max
                throw(ArgumentError("All incoming columns must be of equal length."))
            end
        end
        new(columns, AxisArray(collect(1:ncol),colnames))
    end
end

nrow(x::RLEDataTable) = length(x.columns[1])
ncol(x::RLEDataTable) = length(x.columns)
index(x::RLEDataTable) = x.colindex
columns(x::RLEDataTable) = x.columns
Base.names(x::RLEDataTable) = axisvalues(x.colindex)[1]

function Base.show(io::IO, x::RLEDataTable)
    t = typeof(x)
    show(io, t)
    println()
    for (c,v) in zip(names(x),columns(x))
        println(io,"Column: $c")
        println(io,v)
    end
end

function RLEDataTable(; kwargs...)
    cnames  = [k for (k,v) in kwargs]
    cvalues = [v for (k,v) in kwargs]
    RLEDataTable(cvalues,cnames)
end

Base.copy(x::RLEDataTable) = RLEDataTable( copy(columns(x)), copy(names(x)) )

### Get/set
## Just columns
Base.getindex(x::RLEDataTable,j::Colon) = copy(x)
Base.getindex(x::RLEDataTable,j::ColumnIndex) = columns(x)[index(x)[j]]
function Base.getindex(x::RLEDataTable,j::AbstractArray)
    inds = index(x)[j]
    RLEDataTable( columns(x)[inds], names(x)[inds] )
end

function Base.setindex!(x::RLEDataTable, value::AbstractVector, j::Integer)
    if length(value) != nrow(x)
        throw(ArgumentError("Length of incoming value must match existing columns."))
    end
    if j <= length(x)
        columns(x)[1] = value
    else
        throw(BoundsError())
    end
    x
end

function Base.setindex!(x::RLEDataTable, value::AbstractVector, j::Symbol)
    if length(value) != nrow(x)
        throw(ArgumentError("Length of incoming value must match existing columns."))
    end
    if j in names(x)
        columns(x)[1] = value
    else
        x.colindex = merge(index(x), AxisArray( [length(x) + 1], [j] ) )
        x.columns = push!(x.columns,value)
    end
    x
end

## just rows
function Base.getindex(x::RLEDataTable, i, j)
    
end


## rows and cols

### Familiar operations over rows or columns from R
#rowMeans(x::RLEDataTable) = rowSum(x) ./ ncol(x)
colSums(x::RLEDataTable) = map(sum, columns(x))
colMeans(x::RLEDataTable) = colSums(x) ./ nrow(x)
colMedians(x::RLEDataTable) = map(median, columns(x))
