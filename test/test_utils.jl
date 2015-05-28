module TestUtils

importall RleVectors
using Base.Test

@test RleVectors.rep([4,5,6], each=2) == [4,4,5,5,6,6]
@test RleVectors.rep([4,5,6], times=2) == [4,5,6,4,5,6]
@test RleVectors.rep([4,5,6], each=3, times=2) == [4,4,4,5,5,5,6,6,6,4,4,4,5,5,5,6,6,6]
@test RleVectors.rep(["p","d","q"], each=3, times=2) == ["p","p","p","d","d","d","q","q","q","p","p","p","d","d","d","q","q","q"]
@test_throws ArgumentError RleVectors.rep([1,2,3], each=[4,5])

end
