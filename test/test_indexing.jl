workspace()
module TestIndexing

importall RLEVectors
using Base.Test

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
x = RLEVectors.RLEVector([1,2,3,4],[2,4,6,8])
@test x[1] == 1
@test x[3] == 2
@test x[8] == 4
@test_throws BoundsError x[9]

## getindex on multiple positions
x = RLEVectors.RLEVector([1,2,3,4],[2,4,6,8])
@test x[ [1,2,3] ] == RLEVector([1,1,2])
@test x[ [8,2,4] ] == RLEVector([4,1,2])
@test x[ 2:5 ] == RLEVector([1,2,2,3])
@test x[ 5:-1:2 ] == RLEVector([3,2,2,1])
@test x[ 1:end ] == x

## getindex with logical
#x = RLEVectors.RLEVector([1,2],[2,4])
@test x[ [true, false, false, true] ] == [1, 2]

## setindex! for single position
y = RLEVectors.RLEVector([3,4,4,5,5])
y[1] = 20
@test collect(y) == [20,4,4,5,5]

# No change
x = RLEVectors.RLEVector([1,2,3,4],[2,4,6,8])
x[4] = 2
@test collect(x) == [1,1,2,2,3,3,4,4]
@test x.runvalues == [1,2,3,4]
@test x.runends == [2,4,6,8]

# left of run
x = RLEVectors.RLEVector([1,2,3,4],[2,4,6,8])
x[1] = 9
@test collect(x) == [9,1,2,2,3,3,4,4]
@test x.runvalues == [9,1,2,3,4]
@test x.runends == [1,2,4,6,8]

# right of run
x = RLEVectors.RLEVector([1,2,3,4],[2,4,6,8])
x[2] = 7
@test collect(x) == [1,7,2,2,3,3,4,4]
@test x.runvalues == [1,7,2,3,4]
@test x.runends == [1,2,4,6,8]

# left of run making repeat
x = RLEVectors.RLEVector([1,2,3,4],[2,4,6,8])
x[3] = 1
@test collect(x) == [1,1,1,2,3,3,4,4]
@test x.runvalues == [1,2,3,4]
@test x.runends == [3,4,6,8]

# right of run making repeat
x = RLEVectors.RLEVector([1,2,3,4],[2,4,6,8])
x[4] = 3
@test collect(x) == [1,1,2,3,3,3,4,4]
@test x.runvalues == [1,2,3,4]
@test x.runends == [2,3,6,8]

# middle of run
x = RLEVectors.RLEVector([1,2,3],[3,6,9])
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
x = RLEVectors.RLEVector([1,2,3,4],[4,8,12,16])
x[10:11] = 5
@test x.runvalues == [1,2,3,5,3,4]
@test x.runends == [4,8,9,11,12,16]

# just left, no match
x = RLEVectors.RLEVector([1,2,3,4],[4,8,12,16])
x[9:10] = 5
@test x.runvalues == [1,2,5,3,4]
@test x.runends == [4,8,10,12,16]

# just right, no match
x = RLEVectors.RLEVector([1,2,3,4],[4,8,12,16])
x[11:12] = 5
@test x.runvalues == [1,2,3,5,4]
@test x.runends == [4,8,10,12,16]

# just left, match
x = RLEVectors.RLEVector([1,2,3,4],[4,8,12,16])
x[9:10] = 2
@test x.runvalues == [1,2,3,4]
@test x.runends == [4,10,12,16]

# just right, match
x = RLEVectors.RLEVector([1,2,3,4],[4,8,12,16])
x[11:12] = 4
@test x.runvalues == [1,2,3,4]
@test x.runends == [4,8,10,16]

# span, no match
x = RLEVectors.RLEVector([1,2,3,4],[4,8,12,16])
x[9:12] = 5
@test x.runvalues == [1,2,5,4]
@test x.runends == [4,8,12,16]

# span, left match
x = RLEVectors.RLEVector([1,2,3,4],[4,8,12,16])
x[9:12] = 2
@test x.runvalues == [1,2,4]
@test x.runends == [4,12,16]

# span, right match
x = RLEVectors.RLEVector([1,2,3,4],[4,8,12,16])
x[9:12] = 4
@test x.runvalues == [1,2,4]
@test x.runends == [4,8,16]

# span, both match
x = RLEVectors.RLEVector([1,2,3,2],[4,8,12,16])
x[9:12] = 2
@test x.runvalues == [1,2]
@test x.runends == [4,16]

# reverse range with scalar
x = RLEVectors.RLEVector([1,2,3,4],[2,4,6,8])
x[4:-1:2] = 5
@test collect(x) == [1,5,5,5,3,3,4,4]
@test x.runvalues == [1,5,3,4]
@test x.runends == [1,4,6,8]

## range with vector
x = RLEVectors.RLEVector([1,2,3,4],[2,4,6,8])
x[2:4] = [5,6,7]
@test x[2:4] == RLEVector([5,6,7])

## range with range
x = RLEVectors.RLEVector([1,2,3,4],[2,4,6,8])
x[2:4] = 5:7
@test x[ [2,3,4] ] == [5,6,7]

# reverse range with vector
x = RLEVectors.RLEVector([1,2,3,4],[2,4,6,8])
x[4:-1:2] = [5,6,7]
@test x[4:-1:2] == [5,6,7]

# Colon
x = RLEVectors.RLEVector([1,2,3,4],[2,4,6,8])
@test x[:] == x[1:end]
x[:] = 4
@test x == RLEVector([4 for i in 1:8])

# Logical
x = RLEVectors.RLEVector([1,2],[2,4])
@test x[ [ true,true,true,false ] ] == x[ [1,2,3] ]
x[ [true,true,true,false] ] = 4
@test x == RLEVector([4,4,4,2])
x = RLEVectors.RLEVector([1,2],[2,4])
x[ [true,true,true,false] ] = [4,5,6]
@test x == RLEVector([4,5,6,2])

# head and tail
x = RLEVectors.RLEVector([1,2,3,4],[2,4,6,8])
@test head(x) == [1,1,2,2,3,3]
@test head(x,3) == [1,1,2]
@test tail(x) == [2,2,3,3,4,4]
@test tail(x,3) == [3,4,4]

end
