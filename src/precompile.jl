function _precompile_()
    precompile( RLEVector, (Vector{UTF8String}, Vector{Int}) )
    precompile( RLEVector, (Vector{Real}, Vector{Int}) )
end
