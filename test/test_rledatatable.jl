module TestRLEDT

using Base.Test
using RLEVectors
using AxisArrays

@testset begin

    # Initialization
    x = RLEDataTable( [RLEVector([1, 1, 2]), RLEVector([2, 2, 2])], [:a, :b])
    @test isa(x,RLEDataTable)
    @test length(x) == 2
    @test names(x) == [:a, :b]
    io = IOBuffer()
    @test typeof(show(io,x)) == Void # At least test that show does not give error
    z = RLEDataTable( a=RLEVector([5,2,2]), b=RLEVector([4,4,4]), c=RLEVector([3,2,1]) )
    @test isa(z,RLEDataTable)
    @test length(z) == 3
    @test names(z) == [:a, :b, :c]
    @test x == copy(x)
    @test index(z) == AxisArray(collect(1:3),[:a,:b,:c])
    @test columns(z) == [ RLEVector([5,2,2]), RLEVector([4,4,4]), RLEVector([3,2,1]) ]
    @test names(z) == [:a,:b,:c]
                      
    # Getting and setting
    z = RLEDataTable( a=RLEVector([5,2,2]), b=RLEVector([4,4,4]), c=RLEVector([3,2,1]) )
    @test z[:] == z
    @test z[2] == RLEVector([4,4,4])
    @test z[:c] == RLEVector([3,2,1])
    @test z[2:3] == RLEDataTable( b=RLEVector([4,4,4]), c=RLEVector([3,2,1]) )
    @test z[ [:b,:c] ] == RLEDataTable( b=RLEVector([4,4,4]), c=RLEVector([3,2,1]) )
    @test z[ [2], [:b,:c] ] == RLEDataTable( b=RLEVector([4]), c=RLEVector([2]) )
    @test z[ 2, [:b,:c] ] == RLEDataTable( b=RLEVector([4]), c=RLEVector([2]) )
    @test z[2,3] == 2
    z = RLEDataTable( a=RLEVector([5,2,2]), b=RLEVector([4,4,4]), c=RLEVector([3,2,1]) )
    @test z[1,3] == 3

    z = RLEDataTable( a=RLEVector([5,2,2]), b=RLEVector([4,4,4]), c=RLEVector([3,2,1]) )
    z[2] = RLEVector([9,8,9])
    @test z == RLEDataTable( a=RLEVector([5,2,2]), b=RLEVector([9,8,9]), c=RLEVector([3,2,1]) )
    z = RLEDataTable( a=RLEVector([5,2,2]), b=RLEVector([4,4,4]), c=RLEVector([3,2,1]) )
    z[:b] = RLEVector([7,2,1])
    @test z == RLEDataTable( a=RLEVector([5,2,2]), b=RLEVector([7,2,1]), c=RLEVector([3,2,1]) )
    z[:b] = RLEVector([7,2,1])
    @test z == RLEDataTable( a=RLEVector([5,2,2]), b=RLEVector([7,2,1]), c=RLEVector([3,2,1]) )
    z[:d] = RLEVector([2,1,2])
    @test z == RLEDataTable( a=RLEVector([5,2,2]), b=RLEVector([7,2,1]), c=RLEVector([3,2,1]), d=RLEVector([2,1,2]) )
    @test_throws ArgumentError z[1] = RLEVector([2])
    @test_throws BoundsError z[14] = RLEVector([2,2,1])
    @test_throws ArgumentError z[:a] = RLEVector([2,4,5,4,3,4])

    z = RLEDataTable( a=RLEVector([5,2,2]), b=RLEVector([4,4,4]), c=RLEVector([3,2,1]) )
    z[ 1:2, :b ] = [5,5]
    @test z == RLEDataTable( a=RLEVector([5,2,2]), b=RLEVector([5,5,4]), c=RLEVector([3,2,1]) )

    z = RLEDataTable( a=RLEVector([5,2,2]), b=RLEVector([4,4,4]), c=RLEVector([3,2,1]) )
    z[ 1:2, [2] ] = [5,5]
    @test z == RLEDataTable( a=RLEVector([5,2,2]), b=RLEVector([5,5,4]), c=RLEVector([3,2,1]) )

    z = RLEDataTable( a=RLEVector([5,2,2]), b=RLEVector([4,4,4]), c=RLEVector([3,2,1]) )
    z[1,3] = 12
    @test z == RLEDataTable( a=RLEVector([5,2,2]), b=RLEVector([4,4,4]), c=RLEVector([12,2,1]) )
    


    
end # testset
end # module
