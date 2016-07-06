### Implements a list of RLEVectors like Bioconductor's RLEList
### Not doing compressed versions where the latter concatenates the underlying
###   data into one vector for cheap vectorization

type RLEVectorList{T1,T2 <: Integer} <: AbstractArray{T1, 1}
    els::Vector{ RLEVector{T1,T2} }
    function RLEVectorList(rles...)
        rvl = ""
        return(rvl)
    end
end
    
