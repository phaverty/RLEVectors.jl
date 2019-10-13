module TestMissing

using Test
using RLEVectors

standard_rle = RLEVector(["a","d","c","b"],[2,4,6,8])
missing_ok_rle = RLEVector(Vector{Union{Missing, String}}(["a","d","c","b"]), [2,4,6,8])
with_missing_rle = RLEVector{Union{Missing,String},Int64}(Vector{Union{Missing, String}}(["a",missing,"c","b"]), [2,4,6,8])
#with_missing_rle = RLEVector(Vector{Union{Missing, String}}(["a",missing,"c","b"]), [2,4,6,8])

@testset "Staring with simple vector" begin
    x = standard_rle
    @test disallowmissing(x) == standard_rle
    @test allowmissing(x) == missing_ok_rle
end

@testset "Staring with missings possible but not present" begin
    x = missing_ok_rle
    @test allowmissing(x) == x
    @test disallowmissing(x) == standard_rle
end

@testset "Staring with missing possible" begin
    x = with_missing_rle
    @test_throws MethodError disallowmissing(x)
    x = with_missing_rle
    @test typeof(allowmissing(x)) == typeof(x)
end

end # module
