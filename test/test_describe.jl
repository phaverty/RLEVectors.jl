module TestDescribe

using Test
using RLEVectors

@testset begin

x = RLEVector([4,5,6],[3,6,9])

# nrun
@test nrun(x) == 3
    
# length
@test length(x) == 9

# size
@test size(x) == (9,)
@test size(x,1) == 9
@test size(x,2) == (9, 1)
    
# isempty
@test isempty(x) == false
@test isempty( RLEVector(Int[], Int[]) ) == true

# ==
@test x == x

# isequal
@test isequal(x,x)

# eltype, endtype
@test endtype(x) == Int64
@test eltype(x) == Int64


end # testset

end # module
