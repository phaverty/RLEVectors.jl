const ColumnIndex = Union{Symbol,Integer}

"""
An RLEDataFrame extends DataFrame and contains a colection of like-length and like-type
    RLEVectors. In a way, this creates a type like an RLE matrix. But, we deliberately
    avoid the complexity of matrix operations, such as factorization. It is expected
    that most operations will be column-wise. Based on RleDataFrame from Bioconductor's
    `genoset` package (also by Peter Haverty).
### Examples
```julia
x = RLEDataFrame( [RLEVector([1, 1, 2]), RLEVector([2, 2, 2])], [:a, :b])
y = RLEDataFrame( [RLEVector([5])],[:a] )
z = RLEDataFrame( a=RLEVector([5,2,2]), b=RLEVector([4,4,4])
```
"""
mutable struct RLEDataFrame <: AbstractDataFrame
    columns::Vector{RLEVector}
    colindex::NamedTuple # FIXME: get length info in RLEDataFrame parametric type
    function RLEDataFrame(columns,colnames::Vector{Symbol})
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
        c = Tuple( Symbol(x) for x in colnames )
        new(column, NamedTuple{c}(1:ncol))
    end
end

nrow(x::RLEDataFrame) = length(x.columns[1])
ncol(x::RLEDataFrame) = length(x.columns)
index(x::RLEDataFrame) = x.colindex
columns(x::RLEDataFrame) = x.columns
Base.names(x::RLEDataFrame) = keys(x.colindex)

function Base.show(io::IO, x::RLEDataFrame)
    t = typeof(x)
    show(io, t)
    println()
    for (c,v) in zip(names(x),columns(x))
        println(io,"Column: $c")
        println(io,v)
    end
end

function RLEDataFrame(; kwargs...)
    cnames  = [k for (k,v) in kwargs]
    cvalues = [v for (k,v) in kwargs]
    RLEDataFrame(cvalues,cnames)
end

Base.copy(x::RLEDataFrame) = RLEDataFrame( copy(columns(x)), copy(names(x)) )

### Get/set
## Just columns
Base.getindex(x::RLEDataFrame,j::Colon) = copy(x)
Base.getindex(x::RLEDataFrame,j::ColumnIndex) = columns(x)[index(x)[j]]
function Base.getindex(x::RLEDataFrame,j::AbstractArray)
    inds = index(x)[j]
    RLEDataFrame( columns(x)[inds], names(x)[inds] )
end

function Base.setindex!(x::RLEDataFrame, value::AbstractVector, j::Integer)
    if length(value) != nrow(x)
        throw(ArgumentError("Length of incoming value must match existing columns."))
    end
    if j <= length(x)
        columns(x)[j] = value
    else
        throw(BoundsError())
    end
    x
end

function Base.setindex!(x::RLEDataFrame, value::AbstractVector, j::Symbol)
    if length(value) != nrow(x)
        throw(ArgumentError("Length of incoming value must match existing columns."))
    end
    if j in names(x)
        columns(x)[index(x)[j]] = value
    else
        x.colindex = merge(index(x), NamedTuple{j}( Tuple(length(x) + 1) ))
        x.columns = push!(x.columns,value)
    end
    x
end

## with rows
function Base.getindex(x::RLEDataFrame, i, j)
    j_inds = index(x)[j]
    cols = [ x.columns[j_ind][i] for j_ind in j_inds ]
    RLEDataFrame( cols, names(x)[j_inds] )
end
Base.getindex(x::RLEDataFrame, i::Integer, j) = x[ [i], j ]
Base.getindex(x::RLEDataFrame, i::Integer, j::ColumnIndex) = x[j][i]

function Base.setindex!(x::RLEDataFrame, value, i, j)
    for j_ind in index(x)[j]
        x.columns[j_ind][i] = value
    end
    x
end
Base.setindex!(x::RLEDataFrame, value, i::Integer, j) = setindex!(x,value,[i],j)
Base.setindex!(x::RLEDataFrame, value, i::Integer, j::ColumnIndex) = setindex!(x.columns[j],value,i)

### Familiar operations over rows or columns from R

# Probably these are all a job for mapslice or slicedim. I need to RTM.
rowmap(x::Matrix,f::Function) = [ f( @view x[i,:] ) for i in 1:size(x)[1] ]
colmap(x::Matrix,f::Function) = [ f( @view x[:,j] ) for j in 1:size(x)[2] ]
rowMeans(x) = rowmap(x,mean)
rowMedians(x) = rowmap(x,median)
rowSums(x) = rowmap(x,sum)
colMeans(x) = colmap(x,mean)
colMedians(x) = colmap(x,median)
colSums(x) = colmap(x,sum)

#rowMeans(x::RLEDataFrame) = rowSum(x) ./ ncol(x)
colSums(x::RLEDataFrame) = map(sum, columns(x))
colMeans(x::RLEDataFrame) = colSums(x) ./ nrow(x)
colMedians(x::RLEDataFrame) = map(median, columns(x))
