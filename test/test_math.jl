module TestMath

if VERSION >= v"0.5.0"
    using BaseTestNext
    const Test = BaseTestNext
else
    using Base.Test
end

using RLEVectors

@testset begin

# mode and implicitly countmap
x = RLEVector([4,5,6,5],cumsum([10,5,3,6]))
@test mode(x) == 5

end # testset

end # module
