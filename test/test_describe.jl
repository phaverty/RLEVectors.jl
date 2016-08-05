module TestDescribe

if VERSION >= v"0.5.0"
    using Base.Test
else
    using BaseTestNext
    const Test = BaseTestNext
end

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

end # testset

end # module
