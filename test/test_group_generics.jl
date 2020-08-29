module TestGroupGenerics

using Test
using RLEVectors

@testset begin

    # compare group
    vec = [1, 1, 2, 2, 4, 4]
    x = RLEVector(vec)
    @test (x .< 3) == RLEVector([true, false], [4, 6])

    # math group
    vec = [1, 1, 2, 2, 4, 4]
    x = RLEVector(vec)
    @test x .+ 5 == 5 .+ x
    @test x .+ 4 == RLEVector([5, 5, 6, 6, 8, 8])
    @test div.(vec, 2) == collect(div.(x, 2))
    @test median(RLEVector([1, 2, 3, 2, 1, 5, 4])) == median([1, 2, 3, 2, 1, 5, 4])
    @test median(RLEVector([1, 2, 3, 2, 1, 5])) == median([1, 2, 3, 2, 1, 5])
    @test median(RLEVector([3, 2, 1])) == 2.0
    @test median(RLEVector([2, 2, 2, 3, 3, 3])) == 2.5 # median is average of end of run and next value
    @test sum(RLEVector([4, 4, 5, 5, 6, 6])) == 30
    @test mean(RLEVector([4, 4, 5, 5, 6, 6])) == 5.0
    @test x .^ 2 == RLEVector([1, 1, 4, 4, 16, 16])
    @test x .^ 3 == RLEVector([1, 1, 8, 8, 64, 64])
    @test x + x == RLEVector([2, 2, 4, 4, 8, 8])
    @test x - x == RLEVector([0, 0, 0, 0, 0, 0])
    rle = RLEVector([4, 4, 9, 9, 16, 16])
    @test sqrt.(rle) == RLEVector([2, 2, 3, 3, 4, 4])

    # math on bools
    vec = [1, 1, 2, 2, 4, 4]
    x = RLEVector(vec)
    @test x .+ true == x .+ 1
    @test x .+ false == x
    vec = [1, 1, 2, 2, 4, 4]
    x = RLEVector(vec)
    @test x .+ true == x .+ 1
    @test x .+ false == x

    # broadcast with different sizes
    x = RLEVector([1, 1, 3])
    @test x .+ 4 == RLEVector([5, 5, 7])
    @test x .+ [4 5 6] == [[5 6 7]; [5 6 7]; [7 8 9]]
    @test x .+ [4, 5, 6] == RLEVector([5, 6, 9])
    @test x .+ [[2 2 2]; [4 4 4]]' == [[3 3 5]; [5 5 7]]'

    # findmax, findmin
    @test findmin(RLEVector([1, 2, 3, 4, 1, 1])) == findmin([1, 2, 3, 4, 1, 1])
    @test findmax(RLEVector([1, 2, 3, 4, 1, 1])) == findmax([1, 2, 3, 4, 1, 1])

    # indexin
    foo = IntegerRle(collect(1:1000), collect(5:5:5000))
    x = RLEVector([2, 2, 4, 4, 3, 3])
    y = RLEVector([0, 0, 0, 3, 3, 3, 4, 4])
    @test indexin(x, y) == indexin(collect(x), collect(y))
    @test indexin(x, collect(3:11)) == indexin(collect(x), collect(3:11))
    @test indexin([200, 200, 1, 1, 5, 5], foo) == indexin([200, 200, 1, 1, 5, 5], foo)

    @test findall(in(RLEVector(collect(3:10))), RLEVector([1, 1, 2, 2, 3, 3])) == collect(5:6)
    @test findall(in(3:10), RLEVector([1, 1, 2, 2, 3, 3])) == collect(5:6)
    @test findall(in(collect(3:10)), RLEVector([1, 1, 2, 2, 3, 3])) == collect(5:6)
    @test findall(in(RLEVector(collect(1:4))), [3, 4, 5]) == [1, 2]

    # in
    @test in(3, RLEVector([1, 2, 2, 3])) == true
    @test in(4, RLEVector([1, 2, 2, 3])) == false
    @test setdiff(Set([1, 2, 3, 4, 5]), RLEVector([1, 1, 2, 2, 4, 4, 5, 5])) == Set([3])

end # testset

end # module
