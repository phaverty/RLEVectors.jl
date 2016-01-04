module TestUtils

importall RLEVectors
using Base.Test

# rep
@test RLEVectors.rep([4,5,6], each=2) == [4,4,5,5,6,6]
@test RLEVectors.rep([4,5,6], times=2) == [4,5,6,4,5,6]
@test RLEVectors.rep([4,5,6], each=3, times=2) == [4,4,4,5,5,5,6,6,6,4,4,4,5,5,5,6,6,6]
@test RLEVectors.rep(["p","d","q"], each=3, times=2) == ["p","p","p","d","d","d","q","q","q","p","p","p","d","d","d","q","q","q"]
@test_throws ArgumentError RLEVectors.rep([1,2,3], each=[4,5])

# searchsortedfirst
@test searchsortedfirst( [0,5,10,15], [-3,2,3,7,22] ) == [1, 2, 2, 3, 5]
@test searchsortedfirst( [0,5,10,15], [-3,2,-3,7,22] ) == [1, 2, 1, 3, 5]

end
