workspace()
module TestTypes
importall RleVectors
using Base.Test

# Initialization
expected_run_values = [1,2,3]
expected_run_ends = [2,4,7]
x = RleVector([1,1,2,2,3,3,3])
y = RleVector(expected_run_values, expected_run_ends)
@test isa(x,RleVector)
@test x.runvalues == expected_run_values
@test x.runends == expected_run_ends
x = RleVector(["a","b","c","d","d","d","e","f"],[3,6,9,12,15,18,21,24])
y = RleVector(["a","b","c","d","e","f"],[3,6,9,18,21,24])
@test x.runvalues == y.runvalues
@test x.runends == y.runends
x = RleVector(BitVector(5),collect(1:5))
y = RleVector([false],[5])
@test x.runvalues == y.runvalues
@test x.runends == y.runends
x = RleVector([4,5,6],[2,4,6])
y = RleVector([4,4,5,5,6,6])
@test x.runvalues == y.runvalues
@test x.runends == y.runends

@test_throws ArgumentError RleVector([1,2,3],[2,4,3]) # Sorted runends
@test IntegerRle([1,2,3],[2,4,6]) == RleVector([1,2,3],Int32[2,4,6])
@test FloatRle([1,2,3],[2,4,6]) == RleVector(Float64[1,2,3],Int32[2,4,6])
@test BoolRle([true,false,true],[2,4,6]) == RleVector([true,false,true],Int32[2,4,6])
@test StringRle(["a","bob","joe"],[2,4,6]) == RleVector(["a","bob","joe"],Int32[2,4,6])

# Creating
y = RleVector([1.0,1,2,2,3,3,3])
@test similar(y) == RleVector(Array(Real,0),Array(Int,0))
@test similar(y,4) == RleVector(zeros(Real,1),Int[4])

# Conversion
x = RleVector([4,4,5,5,6,7,8])
@test convert(Vector,x) == [4,4,5,5,6,7,8]
@test convert(Set,x) == Set([4,5,6,7,8])

# Expanding
@test collect(RleVector([1,1,2,2,3,3])) == [1,1,2,2,3,3]
@test convert(Vector, RleVector([1,1,2,2,3,3])) == [1,1,2,2,3,3]

# Describing
x = RleVector(expected_run_values,expected_run_ends)
@test eltype(x) == eltype(expected_run_values)

# Getters and setters
x = RleVector([1,2,3],[2,9,22])
@test rfirst(x) == [1,3,10]
@test rfirst(x,1) == 1
@test rfirst(x,3) == 10
@test rwidth(x) == [2,7,13]
@test rwidth(x,1) == 2
@test rwidth(x,2) == 7
@test rwidth(x,3) == 13
@test rlast(x) == [2,9,22]
@test rvalue(x) == [1,2,3]


end # module
