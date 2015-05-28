workspace()
module TestGroupGenerics
importall RleVectors
using Base.Test

# compare group
vec = [1,1,2,2,4,4]
x = RleVector(vec)
@test (x .< 3) == RleVector([true,false],[4,6])

# math group
vec = [1,1,2,2,4,4]
x = RleVector(vec)
@test x + 5 == 5 + x
@test x + 4 == RleVector([5,5,6,6,8,8])
@test div(vec,2) == collect(div(x,2))
@test median(RleVector([1,2,3,2,1,5,4])) == median([1,2,3,2,1,5,4])
@test median(RleVector([1,2,3,2,1,5])) == median([1,2,3,2,1,5])

# findmax, findmin
@test findmin(RleVector([1,2,3,4,1,1])) == findmin([1,2,3,4,1,1])
@test findmax(RleVector([1,2,3,4,1,1])) == findmax([1,2,3,4,1,1])

# indexin
foo = IntegerRle(Int32[ 1:1000 ], Int32[5:5:5000])
x = RleVector([2,2,4,4,3,3])
y = RleVector([0,0,0,3,3,3,4,4])
@test indexin(x,y) == RleVector([0,8,6],[2,4,6])
@test indexin(x,[3:11]) == RleVector([0,2,1],[2,4,6])
@test indexin([200,200,1,1,5,5],foo) == [1000,1000,5,5,25,25]

# findin
@test findin(RleVector([1,1,2,2,3,3]), RleVector([3:10])) == [5:6]
@test findin(RleVector([1,1,2,2,3,3]), 3:10) == [5:6]
@test findin(RleVector([1,1,2,2,3,3]), [3:10]) == [5:6]
@test findin([3,4,5],RleVector([1:4])) == [1,2]

end
