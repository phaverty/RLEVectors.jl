function _precompile_()
    precompile( RLEVector, (Vector{String}, Vector{Int}) )
    precompile( RLEVector, (Vector{Real}, Vector{Int}) )
    precompile( RLEVector, (Vector{Int}, Vector{Int}) )
end
