using RLEVectors
using RCall

x = RLEVector([1,1,1,1,2,2])
y = RObject(x)
rcopy(RLEVector,y)
convert(RLEVector,y)
RLEVector(y)

@rput y
R"y = y + 2"
@rget y
