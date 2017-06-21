module TestRuns

using Base.Test
using RLEVectors

@testset begin

# numruns single
@test numruns([1,2,2,3,3]) == 3
@test numruns([1,1,2,2,3]) == 3

# numruns pair
@test numruns(["a","b","c","d","d","e","f","g"],[3,6,9,12,15,18,21,24]) == 7 # Run of 2 runvalues
@test numruns(["a","b","c","d","d","d","e","f"],[3,6,9,12,15,18,21,24]) == 6 # Run of 3 runvalues
@test numruns(["a","b","c","d","e","f","g"],[3,6,9,12,12,15,17]) == 6 # run of 2 runends
@test numruns(["a","b","c","d","e","f"],[3,6,12,12,12,15]) == 4 # run of 3 runends
@test numruns([1,2,3],[1,2,2]) == 2
@test_throws ArgumentError numruns([1,2,3],[3,2,4])

# one vector
@test ree( [1,1,2,2,3,3,4,4,4] ) == ([1,2,3,4],[2,4,6,9])
@test ree( [1,1,2,2,3,3,4,4,7] ) == ([1,2,3,4,7],[2,4,6,8,9])
@test ree( [0,1,2,2,3,3,4,4,7] ) ==([0,1,2,3,4,7],[1,2,4,6,8,9])

# Clean up an RLEVector
@test ree(["a","b","c","d","d","e","f","g"],[3,6,9,12,15,18,21,24]) == (["a","b","c","d","e","f","g"],[3,6,9,15,18,21,24]) # Run of 2 runvalues
@test ree(["a","b","c","d","d","d","e","f"],[3,6,9,12,15,18,21,24]) == (["a","b","c","d","e","f"],[3,6,9,18,21,24]) # Run of 3 runvalues
@test ree(["a","b","c","d","e","f","g"],[3,6,9,12,12,15,17]) == (["a","b","c","d","f","g"],[3,6,9,12,15,17]) # run of 2 runends
@test ree(["a","b","c","d","e","f"],[3,6,12,12,12,15]) == (["a","b","c","f"],[3,6,12,15]) # run of 3 runends
@test ree([1,2,3],[1,2,2]) == ([1,2],[1,2])

# scalar
@test ree(5) == ([5],[1])
@test ree([5]) == ([5],[1])

# inverse_ree
@test inverse_ree([4,5,6],[2,5,7]) == [4,4,5,5,5,6,6]
@test inverse_ree(Real[],Int64[]) == Real[]
@test_throws ArgumentError inverse_ree([],[1])

end # testset

end # module
