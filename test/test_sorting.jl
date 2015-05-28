workspace()
module TestSorting
importall RleVectors
using Base.Test

# issorted
@test issorted( RleVector([3,4,2],[3,6,9])) == false
@test issorted( RleVector([2,3,4],[3,6,9])) == true
@test issorted( RleVector(["bob","fred","joe"],[3,6,9])) == true

# sort, sort!
x = RleVector([2,4,3,5],[4,7,9,10])
@test sort(x) == RleVector([2,3,4,5],[4,6,9,10])
@test sort!(x) == RleVector([2,3,4,5],[4,6,9,10])

# sortperm
x = RleVector([2,4,3,5],[4,7,9,10])
@test sortperm(x) == RleVector([1,3,2,4],[4,6,9,10])

# reverse
x = RleVector([2,4,3,5],[4,7,9,10])
@test reverse(x) == RleVector([5,3,4,2],[1,3,6,10])
@test reverse!(x) == RleVector([5,3,4,2],[1,3,6,10])

end
