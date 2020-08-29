module TestRanges

using Test
using RLEVectors

@testset begin

    # disjoin_length
    @test disjoin_length([], []) == 0
    @test disjoin_length([4, 5], []) == 2
    @test disjoin_length([], [9, 10, 12]) == 3
    @test disjoin_length([1, 2, 3], [4, 5, 6]) == 6
    @test disjoin_length([1, 2, 3], [3, 5, 6]) == 5
    @test disjoin_length([1, 3], [2, 5, 6]) == 5
    @test disjoin_length(RLEVector([1, 2], [1, 3]), RLEVector([3, 2, 1], [2, 5, 6])) == 5

    # disjoin
    @test disjoin([1, 3, 8, 10], [3, 4, 9, 10]) == [1, 3, 4, 8, 9, 10]
    @test disjoin([3, 4, 9, 10], [1, 3, 8, 10]) == [1, 3, 4, 8, 9, 10]

    @test disjoin(RLEVector([1, 2, 3, 4], [1, 3, 8, 10]), RLEVector([4, 5, 6, 7], [3, 4, 9, 10])) ==
          ([1, 3, 4, 8, 9, 10], [1, 2, 3, 3, 4, 4], [4, 4, 5, 6, 6, 7])
    @test disjoin(RLEVector([4, 5, 6, 7], [3, 4, 9, 10]), RLEVector([1, 2, 3, 4], [1, 3, 8, 10])) ==
          ([1, 3, 4, 8, 9, 10], [4, 4, 5, 6, 6, 7], [1, 2, 3, 3, 4, 4])

    # rangeMeans

    x = RLEVector(collect(2:2:20))
    y = RLEVector(collect(1:1:10))

    ranges = [1:1, 1:2, 2:3, 4:8, 1:10, 9:10, 10:10]
    @test [mean(x[r]) for r in ranges] == rangeMeans(ranges, x)

end # testset

end # module
