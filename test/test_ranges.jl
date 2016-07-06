module TestRanges

using RLEVectors
using Base.Test

# disjoin_length
@test disjoin_length([],[]) == 0
@test disjoin_length([4,5],[]) == 2
@test disjoin_length([],[9,10,12]) == 3
@test disjoin_length([1,2,3],[4,5,6]) == 6
@test disjoin_length([1,2,3],[3,5,6]) == 5
@test disjoin_length([1,3],[2,5,6]) == 5

# disjoin
@test disjoin( [1,3,8,10],[3,4,9,10] ) == [1,3,4,8,9,10]
@test disjoin( [3,4,9,10], [1,3,8,10] ) == [1,3,4,8,9,10]

@test disjoin( RLEVector([1,2,3,4], [1,3,8,10]), RLEVector([4,5,6,7],[3,4,9,10])) == ([1,3,4,8,9,10], [1,2,3,3,4,4], [4,4,5,6,6,7])
@test disjoin( RLEVector([4,5,6,7],[3,4,9,10]), RLEVector([1,2,3,4], [1,3,8,10])) == ([1,3,4,8,9,10], [4,4,5,6,6,7], [1,2,3,3,4,4])

# rangeMeans


end
