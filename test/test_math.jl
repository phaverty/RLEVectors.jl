using RLEVectors
using Base.Test

# mode and implicitly countmap
x = RLEVector([4,5,6,5],cumsum([10,5,3,6]))
@test mode(x) == 5
