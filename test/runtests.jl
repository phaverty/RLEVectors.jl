using RLEVectors
using Base.Test
#using RunTests
#exit(run_tests())

test_files = [
              "test_indexing.jl",
              "test_types.jl",
              "test_collections_api.jl",
              "test_math.jl",
              "test_utils.jl",
              "test_sorting.jl",
              "test_describe.jl",
              "test_group_generics.jl",
              "test_ranges.jl",
              "test_runs.jl"]

# println("Linting ...")
# using Lint
# @test isempty(lintpkg( "MyPackage", returnMsgs=true))
# println("Done.")

println("Testing ...")
for f in test_files
    println(f)
    include(f)
end
println("Done testing.")
