module TestMath
importall RleVectors
using Base.Test

# mode and implicitly countmap
x = RleVector([4,5,6,5],cumsum([10,5,3,6]))
@test mode(x) == 5


end
