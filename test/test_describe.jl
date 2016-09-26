module TestDescribe

using Base.Test
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

# isempty
@test isempty(x) == false
@test isempty( RLEVector(Int[], Int[]) ) == true

# ==
@test x == x

# isequal
@test isequal(x,x)

# ndims
@test ndims(x) == 1
    
end # testset

end # module
