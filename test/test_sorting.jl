module TestSorting

if VERSION >= v"0.5.0"
    using Base.Test
else
    using BaseTestNext
    const Test = BaseTestNext
end

using RLEVectors

@testset begin

# issorted
@test issorted( RLEVector([3,4,2],[3,6,9])) == false
@test issorted( RLEVector([2,3,4],[3,6,9])) == true
@test issorted( RLEVector(["bob","fred","joe"],[3,6,9])) == true

# sort, sort!
x = RLEVector([2,4,3,5],[4,7,9,10])
@test sort(x) == RLEVector([2,3,4,5],[4,6,9,10])
@test sort!(x) == RLEVector([2,3,4,5],[4,6,9,10])

# sortperm
x = RLEVector([2,4,3,5],[4,7,9,10])
@test sortperm(x) == RLEVector([1,3,2,4],[4,6,9,10])

# reverse
x = RLEVector([2,4,3,5],[4,7,9,10])
@test reverse(x) == RLEVector([5,3,4,2],[1,3,6,10])
@test reverse!(x) == RLEVector([5,3,4,2],[1,3,6,10])

# permute runs
x = RLEVector([2,4,3,5],[4,7,9,10])
y = RLEVector([4,5,3,2],[3,4,6,10])
@test permute_runs(x, [2, 4, 3, 1]) == y

end # testset

end # module
