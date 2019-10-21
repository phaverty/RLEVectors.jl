module TestIndexing

using Test
using RLEVectors
using Missings:allowmissing, disallowmissing

@testset begin

# ind2run
@test ind2run(RLEVector([3,3,4,4,5,5,6,6,7,7]),5) == 3
@test ind2run(RLEVector([3,3,4,4,5,5,6,6,7,7]),6) == 3
@test ind2run(RLEVector([3,3,4,4,5,5,6,6,7,7]),7) == 4
@test ind2run(RLEVector([3,3,4,4,5,5,6,6,7,7]),7:9) == 4:5
@test ind2run(RLEVector([3,3,4,4,5,5,6,6,7,7]),[3, 5, 6]) == [2, 3, 3]

# ind2runcontext
@test ind2runcontext(RLEVector([3,3,4,4,5,5,6,6,7,7]),5) == (3,1,1)
@test ind2runcontext(RLEVector([3,3,4,4,5,5,6,6,7,7]),6) == (3,2,0)
@test ind2runcontext(RLEVector([3,3,4,4,5,5,6,6,7,7]),7) == (4,1,1)
@test ind2runcontext(RLEVector([3,3,4,4,5,5,6,6,7,7]),7:9) == (4,5,1,1)

## getindex for single position
x = RLEVector([1,2,3,4],[2,4,6,8])
@test x[1] == 1
@test x[3] == 2
@test x[8] == 4
@test_throws BoundsError x[9]

## getindex on multiple positions
x = RLEVector([1,2,3,4],[2,4,6,8])
@test x[ [1,2,3] ] == RLEVector([1,1,2])
@test x[ [8,2,4] ] == RLEVector([4,1,2])
@test x[ 2:5 ] == RLEVector([1,2,2,3])
@test x[ 5:-1:2 ] == RLEVector([3,2,2,1])
@test x[ 1:end ] == x

## getindex with logical
x = RLEVector([1,2],[2,4])
@test x[ [true, false, false, true] ] == RLEVector([1, 2])

## setindex! for single position
y = RLEVector([3,4,4,5,5])
y[1] = 20
@test collect(y) == [20,4,4,5,5]

# No change
x = RLEVector([1,2,3,4],[2,4,6,8])
x[4] = 2
@test collect(x) == [1,1,2,2,3,3,4,4]
@test x.runvalues == [1,2,3,4]
@test x.runends == [2,4,6,8]

# left of run
x = RLEVector([1,2,3,4],[2,4,6,8])
x[1] = 9
@test collect(x) == [9,1,2,2,3,3,4,4]
@test x.runvalues == [9,1,2,3,4]
@test x.runends == [1,2,4,6,8]

# right of run
x = RLEVector([1,2,3,4],[2,4,6,8])
x[2] = 7
@test collect(x) == [1,7,2,2,3,3,4,4]
@test x.runvalues == [1,7,2,3,4]
@test x.runends == [1,2,4,6,8]

# left of run making repeat
x = RLEVector([1,2,3,4],[2,4,6,8])
x[3] = 1
@test collect(x) == [1,1,1,2,3,3,4,4]
@test x.runvalues == [1,2,3,4]
@test x.runends == [3,4,6,8]

# right of run making repeat
x = RLEVector([1,2,3,4],[2,4,6,8])
x[4] = 3
@test collect(x) == [1,1,2,3,3,3,4,4]
@test x.runvalues == [1,2,3,4]
@test x.runends == [2,3,6,8]

# middle of run
x = RLEVector([1,2,3],[3,6,9])
x[5] = 5
@test collect(x) == [1,1,1,2,5,2,3,3,3]
@test x.runvalues == [1,2,5,2,3]
@test x.runends == [3,4,5,6,9]

# ends
x = RLEVector([1,2,3],[3,6,9])
x[1] = 10
@test collect(x) == [10,1,1,2,2,2,3,3,3]
x = RLEVector([1,2,3],[3,6,9])
x[9] = 10
@test collect(x) == [1,1,1,2,2,2,3,3,10]

# singleton ranges
x = RLEVector([1,2,2,3,3])
x[1] = 5
@test collect(x) == [5,2,2,3,3]
x = RLEVector([1,2,2,3,3])
x[1] = 2
@test collect(x) == [2,2,2,3,3]
x = RLEVector([1,1,2,3,3])
x[3] = 3
@test collect(x) == [1,1,3,3,3]
x = RLEVector([1,1,2,3,3])
x[3] = 1
@test collect(x) == [1,1,1,3,3]
x = RLEVector([3,1,2,1,3])
x[3] = 1
@test collect(x) == [3,1,1,1,3]

## range with scalar
# in middle, no match
x = RLEVector([1,2,3,4],[4,8,12,16])
x[10:11] .= 5
@test x.runvalues == [1,2,3,5,3,4]
@test x.runends == [4,8,9,11,12,16]

# just left, no match
x = RLEVector([1,2,3,4],[4,8,12,16])
x[9:10] = 5
@test x.runvalues == [1,2,5,3,4]
@test x.runends == [4,8,10,12,16]

# just right, no match
x = RLEVector([1,2,3,4],[4,8,12,16])
x[11:12] .= 5
@test x.runvalues == [1,2,3,5,4]
@test x.runends == [4,8,10,12,16]

# just left, match
x = RLEVector([1,2,3,4],[4,8,12,16])
x[9:10] .= 2
@test x.runvalues == [1,2,3,4]
@test x.runends == [4,10,12,16]

# just right, match
x = RLEVector([1,2,3,4],[4,8,12,16])
x[11:12] .= 4
@test x.runvalues == [1,2,3,4]
@test x.runends == [4,8,10,16]

# span, no match
x = RLEVector([1,2,3,4],[4,8,12,16])
x[9:12] .= 5
@test x.runvalues == [1,2,5,4]
@test x.runends == [4,8,12,16]

# span, left match
x = RLEVector([1,2,3,4],[4,8,12,16])
x[9:12] .= 2
@test x.runvalues == [1,2,4]
@test x.runends == [4,12,16]

# span, right match
x = RLEVector([1,2,3,4],[4,8,12,16])
x[9:12] .= 4
@test x.runvalues == [1,2,4]
@test x.runends == [4,8,16]

# span, both match
x = RLEVector([1,2,3,2],[4,8,12,16])
x[9:12] .= 2
@test x.runvalues == [1,2]
@test x.runends == [4,16]

# reverse range with scalar
x = RLEVector([1,2,3,4],[2,4,6,8])
x[4:-1:2] .= 5
@test collect(x) == [1,5,5,5,3,3,4,4]
@test x.runvalues == [1,5,3,4]
@test x.runends == [1,4,6,8]

## range with vector
x = RLEVector([1,2,3,4],[2,4,6,8])
x[2:4] = [5,6,7]
@test collect(x) == [1,5,6,7,3,3,4,4]

## range with range
x = RLEVector([1,2,3,4],[2,4,6,8])
x[2:4] = 5:7
@test collect(x) == [1,5,6,7,3,3,4,4]
x = RLEVector([1,2,3,4],[2,4,6,8])
x[1:2] = 5:6
@test collect(x) == [5,6,2,2,3,3,4,4]
x = RLEVector([1,2,3,4],[2,4,6,8])
x[1:3] = 5:7
@test collect(x) == [5,6,7,2,3,3,4,4]
x = RLEVector([1,2,3,4],[2,4,6,8])
x[7:8] = 5:6
@test collect(x) == [1,1,2,2,3,3,5,6]
x = RLEVector([1,2,3,4],[2,4,6,8])
x[6:8] = 5:7
@test collect(x) == [1,1,2,2,3,5,6,7]

# range with vector and match
x = RLEVector([1,2,3,4],[2,4,6,8])
x[1:2] = [2,2]
@test collect(x) == [2,2,2,2,3,3,4,4]
x = RLEVector([1,2,3,4],[2,4,6,8])
x[2:3] = [1,1]
@test collect(x) == [1,1,1,2,3,3,4,4]
x = RLEVector([1,2,3,4],[2,4,6,8])
x[2:3] = [2,2]
@test collect(x) == [1,2,2,2,3,3,4,4]
x = RLEVector([1,2,3,4],[2,4,6,8])
x[6:7] = [3,3]
@test collect(x) == [1,1,2,2,3,3,3,4]
x = RLEVector([1,2,3,4],[2,4,6,8])
x[7:8] = [3,3]
@test collect(x) == [1,1,2,2,3,3,3,3]

# reverse range with vector
x = RLEVector([1,2,3,4],[2,4,6,8])
x[4:-1:2] = [5,6,7]
@test x[4:-1:2] == [5,6,7]

# Colon
x = RLEVector([1,2,3,4],[2,4,6,8])
@test x[:] == x
x[:] .= 4
@test x == RLEVector([4 for i in 1:8])

# Logical
x = RLEVector([1,2],[2,4])
@test x[ [ true,true,true,false ] ] == x[ [1,2,3] ]
x[ [true,true,true,false] ] .= 4
@test x == RLEVector([4,4,4,2])
x = RLEVector([1,2],[2,4])
x[ [true,true,true,false] ] = [4,5,6]
@test x == RLEVector([4,5,6,2])

# eachrange iterator
x = RLEVector([1, 1, 2, 2, 7, 12])
y = collect(eachrange(x))
@test y[1] == (1,1:2)
@test y[2] == (2,3:4)
@test y[3] == (7,5:5)
@test y[4] == (12,6:6)
@test length(eachrange(x)) == 4

# iterate
y = [1, 1, 2, 2, 7, 12]
x = RLEVector([1, 1, 2, 2, 7, 12])
out = Vector{eltype(x)}()
global next = iterate(x)
while next !== nothing
    (i,state) = next
    push!(out, i)
    global next = iterate(x, state)
end
@test out == y

# tapply
factor = repeat( ["a","b","c","d","e"], inner=5 )
rle = RLEVector( factor )
x = collect(1:25)
tapply_res = Dict( "a" => mean(x[1:5]), "b" => mean(x[6:10]), "c" => mean(x[11:15]), "d" => mean(x[16:20]), "e" => mean(x[21:25]) )
@test tapply_res == tapply( x, factor, mean )
@test tapply_res == tapply( x, rle, mean )

# tapply, non-unique RLE values
factor = repeat( ["a","b","c","d","e","b"], inner=5 )
rle = RLEVector( factor )
x = collect(1:30)
tapply_res = Dict( "a" => mean(x[1:5]), "b" => mean(x[vcat(6:10,26:30)]), "c" => mean(x[11:15]), "d" => mean(x[16:20]), "e" => mean(x[21:25]) )
@test_throws ArgumentError tapply( x, rle, mean )

# test missing assignment
rle = allowmissing(RLEVector([1,1,1,2,2,3,3,3]))

# tests to see if disallowmissing works
disallowmissing(rle)

rle[1] = missing
@test isequal(rle[1], missing)

rle[end] = missing
@test isequal(rle[end], missing)

rle[5] = missing
@test isequal(rle[5], missing)

@test all(isequal.(collect(rle), [missing, 1, 1, 2, missing, 3, 3, missing]))

# no longer able to convert
@test_throws MethodError disallowmissing(rle)

end # testset

end # module
