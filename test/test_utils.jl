module TestUtils

using Base.Test
using RLEVectors

@testset begin

# rep
@test RLEVectors.rep([4,5,6], each=2) == [4,4,5,5,6,6]
@test RLEVectors.rep([4,5,6], times=2) == [4,5,6,4,5,6]
@test RLEVectors.rep([4,5,6], each=3, times=2) == [4,4,4,5,5,5,6,6,6,4,4,4,5,5,5,6,6,6]
@test RLEVectors.rep(["p","d","q"], each=3, times=2) == ["p","p","p","d","d","d","q","q","q","p","p","p","d","d","d","q","q","q"]
@test_throws ArgumentError RLEVectors.rep([1,2,3], each=[4,5])

# searchsortedfirst
@test RLEVectors.searchsortedfirst( [3, 6, 9, 12, 15 ], 6, 1, 5 ) == 2
@test RLEVectors.searchsortedfirst( [3, 6, 9, 12, 15 ], 7, 1, 5 ) == 3
@test RLEVectors.searchsortedfirst( [3, 6, 9, 12, 15 ], 7, 0, 22 ) == 3
@test RLEVectors.searchsortedfirst( [3, 6, 9, 12, 15 ], 40, 1, 5 ) == 6
@test RLEVectors.searchsortedfirst( [3, 6, 9, 12, 15 ], -2, 1, 5 ) == 1
@test RLEVectors.searchsortedfirst( [3, 6, 9, 12, 15 ], 14, 4, 5 ) == 5
@test RLEVectors.searchsortedfirst( [3, 6, 9, 12, 15 ], 3, 4, 5 ) == 4

@test RLEVectors.searchsortedfirst( [0,5,10,15], [-3,2,3,7,22] ) == [1, 2, 2, 3, 5]
@test RLEVectors.searchsortedfirst( [0,5,10,15], [-3,2,-3,7,22] ) == [1, 2, 1, 3, 5]

end # testset

end # module
