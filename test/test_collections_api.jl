workspace()
module TestCollections
importall RleVectors

using Base.Test

x = RleVector([4,5,6],[3,6,9])
# setdiff, symdiff, union, endof, maxabs, minabs, any, all, in

# push!
x = RleVector([1,1,2,2,3,3,4,4,5,5])
push!(x,9)
@test x == RleVector([1,1,2,2,3,3,4,4,5,5,9])

# pop!
x = RleVector([1,1,2,2,3,3,4,4,5,5])
@test pop!(x) == 5
@test x == RleVector([1,1,2,2,3,3,4,4,5])

# shove!
x = RleVector([1,1,2,2,3,3,4,4,5,5])
shove!(x,4)
@test x == RleVector([4,1,1,2,2,3,3,4,4,5,5])

# shift!
x = RleVector([1,1,2,2,3,3,4,4,5,5])
@test shift!(x) == 1
@test x == RleVector([1,2,2,3,3,4,4,5,5])

# vcat
@test RleVector([1,1,2,2,3,3,4,4]) == vcat( RleVector([1,1,2,2]), RleVector([3,3,4,4]) )
@test RleVector([1,1,2,2,2,2,4,4]) == vcat( RleVector([1,1,2,2]), RleVector([2,2,4,4]) )

# insert!
x = RleVector([1,1,2,2,3,3,4,4,5,5])
@test_throws BoundsError insert!(x,0,5)
@test_throws BoundsError insert!(x,length(x) + 2,5)
@test insert!(x,1,9) == RleVector([9,1,1,2,2,3,3,4,4,5,5])
@test insert!(x,3,9) == RleVector([9,1,9,1,2,2,3,3,4,4,5,5])
@test insert!(x,1,7) == RleVector([7,9,1,9,1,2,2,3,3,4,4,5,5])
@test insert!(x,length(x) + 1,100) == RleVector([7,9,1,9,1,2,2,3,3,4,4,5,5,100])

# deleterun!
x = RleVector([1,1,2,2,3,3,4,4,5,5])
@test deleterun!(x,1) == RleVector([2,2,3,3,4,4,5,5])
@test deleterun!(x,4) == RleVector([2,2,3,3,4,4])
@test deleterun!(x,2) == RleVector([2,2,4,4])
x = RleVector([1,1,2,2,1,1,4,4,5,5])
@test deleterun!(x,2) == RleVector([1,4,5],[4,6,8])

# deleteat! and decrement_run!
x = RleVector([1,1,2,2,3,3,4,4,5,5])
@test deleteat!(x,1) == RleVector([1,2,2,3,3,4,4,5,5])
@test deleteat!(x,1) == RleVector([2,2,3,3,4,4,5,5])
@test deleteat!(x,4) == RleVector([2,2,3,4,4,5,5])
@test deleteat!(x,5) == RleVector([2,2,3,4,5,5])
@test deleteat!(x,6) == RleVector([2,2,3,4,5])

# splice!
# splice! removing
x = RleVector([1,1,2,2,3,3,4,4,5,5])
@test splice!(x,1) == 1
@test x == RleVector([1,2,2,3,3,4,4,5,5])
x = RleVector([1,1,2,2,3,3,4,4,5,5])
@test splice!(x,10) == 5
@test x == RleVector([1,1,2,2,3,3,4,4,5])
x = RleVector([1,1,2,2,3,3,4,4,5,5])
@test splice!(x,3) == 2
@test x == RleVector([1,1,2,3,3,4,4,5,5])

# splice! replacing
x = RleVector([1,1,2,2,3,3,4,4,5,5])
@test splice!(x,1,[9]) == 1
@test x == RleVector([9,1,2,2,3,3,4,4,5,5])
x = RleVector([1,1,2,2,3,3,4,4,5,5])
@test splice!(x,1,[9,11]) == 1
@test x == RleVector([9,11,1,2,2,3,3,4,4,5,5])
x = RleVector([1,1,2,2,3,3,4,4,5,5])
@test splice!(x,5,[10,11,12]) == 3
@test x == RleVector([1,1,2,2,10,11,12,3,4,4,5,5])
x = RleVector([1,1,2,2,3,3,4,4,5,5])
@test splice!(x,5,RleVector([10,11,12])) == 3
@test x == RleVector([1,1,2,2,10,11,12,3,4,4,5,5])
x = RleVector([1:10])
@test splice!(x,10,[100]) == 10
@test x == RleVector([1:9,100])

# splice! adding
x = RleVector([1,1,2,2,3,3,4,4,5,5])
@test splice!(x,1:0,[9,11]) == similar(x,0)
@test x == RleVector([9,11,1,1,2,2,3,3,4,4,5,5])
x = RleVector([1,1,2,2,3,3,4,4,5,5])
@test splice!(x,5:4,[10,11,12]) == similar(x,0)
@test x == RleVector([1,1,2,2,10,11,12,3,3,4,4,5,5])
x = RleVector([1,1,2,2,3,3,4,4,5,5])
@test splice!(x,10,[9]) == 5
@test x == RleVector([1,1,2,2,3,3,4,4,5,9])
x = RleVector([1,1,2,2,3,3,4,4,5,5])
@test splice!(x,10,[9,11]) == 5
@test x == RleVector([1,1,2,2,3,3,4,4,5,9,11])
x = RleVector([1,1,2,2,3,3,4,4,5,5])
@test splice!(x,10:9,[9,11]) == similar(x,0)
@test x == RleVector([1,1,2,2,3,3,4,4,5,9,11,5])

# resize!
x = RleVector([1,1,2,2,3,3,4,4,5,5])
@test resize!(x,5) == RleVector([1,1,2,2,3])
x = RleVector([1,1,2,2,3,3,4,4,5,5])
@test resize!(x,12) == RleVector([1,1,2,2,3,3,4,4,5,5,0,0])

# empty!
x = RleVector([1,1,2,2,3,3,4,4,5,5])
@test empty!(x) == RleVector(Int[],Int[])

end # module

