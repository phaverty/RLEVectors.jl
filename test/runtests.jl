using RLEVectors

if VERSION >= v"0.5.0"
    using Base.Test
else
    using BaseTestNext
    const Test = BaseTestNext
end

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

println("Testing ...")
for f in test_files
    println(f)
    include(f)
end
println("Done testing.")
