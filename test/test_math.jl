module TestMath

using Base.Test
using RLEVectors

@testset begin

    x = RLEVector(["a","b","c","b"],[2,4,6,10])
    m = countmap(x)
    @test collect(m) == ["c" => 2, "b" => 6, "a" => 2]
    x = RLEVector([4,5,6,5],cumsum([10,5,3,6]))
    @test mode(x) == 5

end # testset

end # module
