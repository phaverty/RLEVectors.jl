module TestTypes

using Test
using RLEVectors

@testset begin

    # Initialization
    expected_run_values = [1, 2, 3]
    expected_run_ends = [2, 4, 7]
    x = RLEVector([1, 1, 2, 2, 3, 3, 3])
    y = RLEVector(expected_run_values, expected_run_ends)
    @test isa(x, RLEVector)
    @test x.runvalues == expected_run_values
    @test x.runends == expected_run_ends
    x = RLEVector(["a", "b", "c", "d", "d", "d", "e", "f"], [3, 6, 9, 12, 15, 18, 21, 24])
    y = RLEVector(["a", "b", "c", "d", "e", "f"], [3, 6, 9, 18, 21, 24])
    @test x.runvalues == y.runvalues
    @test x.runends == y.runends
    x = RLEVector(BitVector(undef, 5), collect(1:5))
    y = RLEVector([false], [5])
    @test x.runvalues == y.runvalues
    @test x.runends == y.runends
    x = RLEVector([4, 5, 6], [2, 4, 6])
    y = RLEVector([4, 4, 5, 5, 6, 6])
    @test x.runvalues == y.runvalues
    @test x.runends == y.runends
    x = RLEVector(1:100 .< 50)
    @test x.runvalues == [true, false]
    @test x.runends == [49, 100]


    @test_throws ArgumentError RLEVector([1, 2, 3], [2, 4, 3]) # Sorted runends
    @test IntegerRle([1, 2, 3], [2, 4, 6]) == RLEVector([1, 2, 3], Int32[2, 4, 6])
    @test FloatRle([1, 2, 3], [2, 4, 6]) == RLEVector(Float64[1, 2, 3], Int32[2, 4, 6])
    @test BoolRle([true, false, true], [2, 4, 6]) == RLEVector([true, false, true], Int32[2, 4, 6])
    @test StringRle(["a", "bob", "joe"], [2, 4, 6]) ==
          RLEVector(["a", "bob", "joe"], Int32[2, 4, 6])

    @test RLEVector(5, 3) == RLEVector([5, 5, 5])

    sim = similar(RLEVector([1, 2, 3], [2, 4, 6]), Int32, (9))
    @test length(sim) == 9
    @test isa(values(sim), Vector{Int32}) == true

    # Conversion
    x = RLEVector([4, 4, 5, 5, 6, 7, 8])
    @test convert(Vector, x) == [4, 4, 5, 5, 6, 7, 8]
    @test convert(Set, x) == Set([4, 5, 6, 7, 8])
    @test convert(RLEVector, [1, 1, 2, 2]) == RLEVector([1, 2], [2, 4])
    x = RLEVector([4, 4, 5, 5, 6, 7, 8])
    y = convert(RLEVector{Float64,Int32}, x)
    @test typeof(y) == RLEVector{Float64,Int32}

    # Expanding
    @test collect(RLEVector([1, 1, 2, 2, 3, 3])) == [1, 1, 2, 2, 3, 3]
    @test convert(Vector, RLEVector([1, 1, 2, 2, 3, 3])) == [1, 1, 2, 2, 3, 3]

    ## Describing
    x = RLEVector(expected_run_values, expected_run_ends)
    @test eltype(x) == eltype(expected_run_values)
    io = IOBuffer()
    @test typeof(show(io, x)) == Nothing # At least test that show does not give error
    @test typeof(show(io, RLEVector(collect(1:100)))) == Nothing # At least test that show does not give error

    # Getters and setters
    x = RLEVector([1, 2, 3], [2, 9, 22])
    @test starts(x) == [1, 3, 10]
    @test starts(x, 1) == 1
    @test starts(x, 3) == 10
    @test widths(x) == [2, 7, 13]
    @test widths(x, 1) == 2
    @test widths(x, 2) == 7
    @test widths(x, 3) == 13
    @test ends(x) == [2, 9, 22]
    @test ends(x, 3) == 22
    @test values(x) == [1, 2, 3]
    @test widths!([2, 5, 9, 22]) == [2, 3, 4, 13]
    @test widths!([4]) == [4]
    @test widths!([]) == []

    # Hashing
    x = RLEVector([1, 1, 2, 2, 3, 3, 3])
    d = Dict("bob" => x)
    typeof(d["bob"]) == typeof(x)


end # testset

end # module
