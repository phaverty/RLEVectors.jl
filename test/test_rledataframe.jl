module TestRLEDF

using Test
using RLEVectors

@testset begin

    # Initialization
    x = RLEDataFrame([RLEVector([1, 1, 2]), RLEVector([2, 2, 2])], [:a, :b])
    @test isa(x, RLEDataFrame)
    @test length(x) == 2
    @test names(x) == [:a, :b]
    io = IOBuffer()
    @test typeof(show(io, x)) == Nothing # At least test that show does not give error
    z = RLEDataFrame(a = RLEVector([5, 2, 2]), b = RLEVector([4, 4, 4]), c = RLEVector([3, 2, 1]))
    @test isa(z, RLEDataFrame)
    @test length(z) == 3
    @test names(z) == [:a, :b, :c]
    @test columns(z) == [RLEVector([5, 2, 2]), RLEVector([4, 4, 4]), RLEVector([3, 2, 1])]
    @test names(z) == [:a, :b, :c]
    @test_throws ArgumentError RLEDataFrame([RLEVector([1])], [:a, :b])
    @test_throws ArgumentError RLEDataFrame([RLEVector([1]), RLEVector([2, 3])], [:a, :b])

    # Getting and setting
    z = RLEDataFrame(a = RLEVector([5, 2, 2]), b = RLEVector([4, 4, 4]), c = RLEVector([3, 2, 1]))
    @test z[:] == z
    @test z[2] == RLEVector([4, 4, 4])
    @test z[:c] == RLEVector([3, 2, 1])
    @test z[2:3] == RLEDataFrame(b = RLEVector([4, 4, 4]), c = RLEVector([3, 2, 1]))
    @test z[[:b, :c]] == RLEDataFrame(b = RLEVector([4, 4, 4]), c = RLEVector([3, 2, 1]))
    @test z[[2], [:b, :c]] == RLEDataFrame(b = RLEVector([4]), c = RLEVector([2]))
    @test z[2, [:b, :c]] == RLEDataFrame(b = RLEVector([4]), c = RLEVector([2]))
    @test z[2, 3] == 2
    z = RLEDataFrame(a = RLEVector([5, 2, 2]), b = RLEVector([4, 4, 4]), c = RLEVector([3, 2, 1]))
    @test z[1, 3] == 3

    z = RLEDataFrame(a = RLEVector([5, 2, 2]), b = RLEVector([4, 4, 4]), c = RLEVector([3, 2, 1]))
    z[2] = RLEVector([9, 8, 9])
    @test z ==
          RLEDataFrame(a = RLEVector([5, 2, 2]), b = RLEVector([9, 8, 9]), c = RLEVector([3, 2, 1]))
    z = RLEDataFrame(a = RLEVector([5, 2, 2]), b = RLEVector([4, 4, 4]), c = RLEVector([3, 2, 1]))
    z[:b] = RLEVector([7, 2, 1])
    @test z ==
          RLEDataFrame(a = RLEVector([5, 2, 2]), b = RLEVector([7, 2, 1]), c = RLEVector([3, 2, 1]))
    z[:b] = RLEVector([7, 2, 1])
    @test z ==
          RLEDataFrame(a = RLEVector([5, 2, 2]), b = RLEVector([7, 2, 1]), c = RLEVector([3, 2, 1]))
    z[:d] = RLEVector([2, 1, 2])
    @test z == RLEDataFrame(
        a = RLEVector([5, 2, 2]),
        b = RLEVector([7, 2, 1]),
        c = RLEVector([3, 2, 1]),
        d = RLEVector([2, 1, 2]),
    )
    @test_throws ArgumentError z[1] = RLEVector([2])
    @test_throws BoundsError z[14] = RLEVector([2, 2, 1])
    @test_throws ArgumentError z[:a] = RLEVector([2, 4, 5, 4, 3, 4])

    z = RLEDataFrame(a = RLEVector([5, 2, 2]), b = RLEVector([4, 4, 4]), c = RLEVector([3, 2, 1]))
    z[1:2, :b] = [5, 5]
    @test z ==
          RLEDataFrame(a = RLEVector([5, 2, 2]), b = RLEVector([5, 5, 4]), c = RLEVector([3, 2, 1]))

    z = RLEDataFrame(a = RLEVector([5, 2, 2]), b = RLEVector([4, 4, 4]), c = RLEVector([3, 2, 1]))
    z[1:2, [2]] = [5, 5]
    @test z ==
          RLEDataFrame(a = RLEVector([5, 2, 2]), b = RLEVector([5, 5, 4]), c = RLEVector([3, 2, 1]))

    z = RLEDataFrame(a = RLEVector([5, 2, 2]), b = RLEVector([4, 4, 4]), c = RLEVector([3, 2, 1]))
    z[1, 3] = 12
    @test z == RLEDataFrame(
        a = RLEVector([5, 2, 2]),
        b = RLEVector([4, 4, 4]),
        c = RLEVector([12, 2, 1]),
    )

    z = RLEDataFrame(a = RLEVector([5, 2, 2]), b = RLEVector([4, 4, 4]), c = RLEVector([3, 2, 1]))
    z[1, [2, 3]] = 12
    @test z == RLEDataFrame(
        a = RLEVector([5, 2, 2]),
        b = RLEVector([12, 4, 4]),
        c = RLEVector([12, 2, 1]),
    )

    z = RLEDataFrame(a = RLEVector([5, 2, 2]), b = RLEVector([4, 4, 4]), c = RLEVector([3, 2, 1]))
    #@test rowMeans(z) == [7,8/3,7/3]
    #@test rowSums(z) == [12,8,7]
    #@test rowMedians(z) == [5,4,4]
    @test colMeans(z) == [3, 4, 2]
    @test colSums(z) == [9, 12, 6]
    @test colMedians(z) == [2.0, 4.0, 2.0]

    zm = convert(Matrix, z)
    @test rowMeans(zm) == [12 / 3, 8 / 3, 7 / 3]
    @test rowSums(zm) == [12, 8, 7]
    @test rowMedians(zm) == [4, 2, 2]
    @test colMeans(zm) == [3, 4, 2]
    @test colSums(zm) == [9, 12, 6]
    @test colMedians(zm) == [2.0, 4.0, 2.0]

end # testset
end # module
