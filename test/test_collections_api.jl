module TestCollections

using Base.Test
using RLEVectors

@testset begin

x = RLEVector([4,5,6],[3,6,9])
# setdiff, symdiff, union, endof, maxabs, minabs, any, all, in

# push!
x = RLEVector([1,1,2,2,3,3,4,4,5,5])
push!(x,9)
@test x == RLEVector([1,1,2,2,3,3,4,4,5,5,9])
x = RLEVector(Int64[], Int64[])
push!(x, 12)
@test x == RLEVector([12])
x = RLEVector([2, 2, 4, 4, 5])
push!(x, 5)
@test x == RLEVector([2, 2, 4, 4, 5, 5])

# pop!
x = RLEVector([1,1,2,2,3,3,4,4,5,5])
@test pop!(x) == 5
@test x == RLEVector([1,1,2,2,3,3,4,4,5])
x = RLEVector([7])
@test pop!(x) == 7
@test x.runends == Int64[]
@test x.runvalues == Int64[]

# unshift!
x = RLEVector([1,1,2,2,3,3,4,4,5,5])
unshift!(x,4)
@test x == RLEVector([4,1,1,2,2,3,3,4,4,5,5])

# shift!
x = RLEVector([1,1,2,2,3,3,4,4,5,5])
@test shift!(x) == 1
@test x == RLEVector([1,2,2,3,3,4,4,5,5])
x = RLEVector([7])
@test shift!(x) == 7
@test x.runends == Int64[]
@test x.runvalues == Int64[]

# vcat
@test RLEVector([1,1,2,2,3,3,4,4]) == vcat( RLEVector([1,1,2,2]), RLEVector([3,3,4,4]) )
@test RLEVector([1,1,2,2,2,2,4,4]) == vcat( RLEVector([1,1,2,2]), RLEVector([2,2,4,4]) )
@test RLEVector([1,1,2,2,3,3,4,4,5,5,6,6]) == vcat( RLEVector([1,1,2,2]), RLEVector([3,3,4,4]), RLEVector([5,5,6,6]) )

# insert!
x = RLEVector([1,1,2,2,3,3,4,4,5,5])
@test_throws BoundsError insert!(x,0,5)
@test_throws BoundsError insert!(x,length(x) + 2,5)
@test insert!(x,11,9) == RLEVector([1,1,2,2,3,3,4,4,5,5,9])
x = RLEVector([1,1,2,2,3,3,4,4,5,5])
@test insert!(x,1,9) == RLEVector([9,1,1,2,2,3,3,4,4,5,5])
@test insert!(x,3,9) == RLEVector([9,1,9,1,2,2,3,3,4,4,5,5])
@test insert!(x,1,7) == RLEVector([7,9,1,9,1,2,2,3,3,4,4,5,5])
@test insert!(x,length(x) + 1,100) == RLEVector([7,9,1,9,1,2,2,3,3,4,4,5,5,100])
x = RLEVector([2, 2, 4, 4, 5])
insert!(x, 3, 4)
@test x == RLEVector([2, 2, 4, 4, 4, 5])
x = RLEVector([2, 2, 4, 4, 5])
insert!(x, 4, 4)
@test x == RLEVector([2, 2, 4, 4, 4, 5])

# deleterun!
x = RLEVector([1,1,2,2,3,3,4,4,5,5])
@test deleterun!(x,1) == RLEVector([2,2,3,3,4,4,5,5])
@test deleterun!(x,4) == RLEVector([2,2,3,3,4,4])
@test deleterun!(x,2) == RLEVector([2,2,4,4])
x = RLEVector([1,1,2,2,1,1,4,4,5,5])
@test deleterun!(x,2) == RLEVector([1,4,5],[4,6,8])

# deleteat! and decrement_run!
x = RLEVector([1,1,2,2,3,3,4,4,5,5])
@test deleteat!(x,1) == RLEVector([1,2,2,3,3,4,4,5,5])
@test deleteat!(x,1) == RLEVector([2,2,3,3,4,4,5,5])
@test deleteat!(x,4) == RLEVector([2,2,3,4,4,5,5])
@test deleteat!(x,5) == RLEVector([2,2,3,4,5,5])
@test deleteat!(x,6) == RLEVector([2,2,3,4,5])

# splice!
# splice! removing
x = RLEVector([1,1,2,2,3,3,4,4,5,5])
@test splice!(x,1) == 1
@test x == RLEVector([1,2,2,3,3,4,4,5,5])
x = RLEVector([1,1,2,2,3,3,4,4,5,5])
@test splice!(x,10) == 5
@test x == RLEVector([1,1,2,2,3,3,4,4,5])
x = RLEVector([1,1,2,2,3,3,4,4,5,5])
@test splice!(x,3) == 2
@test x == RLEVector([1,1,2,3,3,4,4,5,5])
x = RLEVector([1,1,2,2,3,3,4,4,5,5])
@test_throws BoundsError splice!(x, 100, [5])
@test_throws BoundsError splice!(x, 0:100, [5])

# splice! replacing
x = RLEVector([1,1,2,2,3,3,4,4,5,5])
@test splice!(x,1,[9]) == 1
@test x == RLEVector([9,1,2,2,3,3,4,4,5,5])
x = RLEVector([1,1,2,2,3,3,4,4,5,5])
@test splice!(x,1,[9,11]) == 1
@test x == RLEVector([9,11,1,2,2,3,3,4,4,5,5])
x = RLEVector([1,1,2,2,3,3,4,4,5,5])
@test splice!(x,5,[10,11,12]) == 3
@test x == RLEVector([1,1,2,2,10,11,12,3,4,4,5,5])
x = RLEVector([1,1,2,2,3,3,4,4,5,5])
@test splice!(x,5,RLEVector([10,11,12])) == 3
@test x == RLEVector([1,1,2,2,10,11,12,3,4,4,5,5])
x = RLEVector(collect(1:10))
@test splice!(x,10,[100]) == 10
@test x == RLEVector([collect(1:9);100])
x = RLEVector(collect(1:10))
y = RLEVector([99,99])
splice!(x,4:5,y)
@test collect(x) == [1,2,3,99,99,6,7,8,9,10] # regression test, length of x must not change when in and out same length
@test y == RLEVector([99,99]) # regresssion test, splice must not change y

# splice! adding
x = RLEVector([1,1,2,2,3,3,4,4,5,5])
@test splice!(x,1:0,[9,11]) == similar(x,0)
@test x == RLEVector([9,11,1,1,2,2,3,3,4,4,5,5])
x = RLEVector([1,1,2,2,3,3,4,4,5,5])
@test splice!(x,5:4,[10,11,12]) == similar(x,0)
@test x == RLEVector([1,1,2,2,10,11,12,3,3,4,4,5,5])
x = RLEVector([1,1,2,2,3,3,4,4,5,5])
@test splice!(x,10,[9]) == 5
@test x == RLEVector([1,1,2,2,3,3,4,4,5,9])
x = RLEVector([1,1,2,2,3,3,4,4,5,5])
@test splice!(x,10,[9,11]) == 5
@test x == RLEVector([1,1,2,2,3,3,4,4,5,9,11])
x = RLEVector([1,1,2,2,3,3,4,4,5,5])
@test splice!(x,10:9,[9,11]) == similar(x,0)
@test x == RLEVector([1,1,2,2,3,3,4,4,5,9,11,5])
xd = [1,1,2,2,3,3,4,4,5,5]
xr = RLEVector(xd)
@test collect(splice!(xr,9:10,[9,11])) == splice!(xd,9:10,[9,11])
@test xr == RLEVector([1,1,2,2,3,3,4,4,9,11])

# resize!
x = RLEVector([1,1,2,2,3,3,4,4,5,5])
@test resize!(x,5) == RLEVector([1,1,2,2,3])
x = RLEVector([1,1,2,2,3,3,4,4,5,5])
@test resize!(x,12) == RLEVector([1,1,2,2,3,3,4,4,5,5,0,0])

# empty!
x = RLEVector([1,1,2,2,3,3,4,4,5,5])
@test empty!(x) == RLEVector(Int[],Int[])

# intersect
x = RLEVector([9, 9, 12, 12, 13, 13, 9, 9, 14, 14])
@test intersect(x, [12, 9]) == RLEVector([9, 9, 12, 12, 9, 9])
@test intersect(x, [9, 12], [12]) == RLEVector([12, 12])
@test intersect(x, Set([12, 14])) == RLEVector([12, 12, 14, 14])

end # testset

end # module
