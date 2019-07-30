using RLEVectors
using DataFrames
using CSV

results_file = "/Users/phaverty/.julia/dev/RLEVectors/benchmark/rle.timings.csv"

macro timeit(ex)
# like @time, but returning the timing rather than the computed value
  return quote
    #gc_disable()
    local val = $ex # compile
    local t0 = time()
    for i in 1:1e4 val = $ex end
    local t1 = time()
    #gc_enable()
    t1-t0
  end
end

foo = IntegerRle(Vector{Int32}(collect(1:1000)), Vector{Int32}(collect(5:5:5000)))
length(foo)
timings = DataFrame()
timings[:language] = "julia"
timings[:language_version] = VERSION
timings[:date] = chomp(read(`date "+%Y-%m-%d"`, String))
timings[:indexing] = @timeit foo[100]
timings[:range_indexing] = @timeit foo[801:900]
timings[:setting] = @timeit foo[800] = 5
timings[:range_setting] = @timeit foo[801:900] = 1:100
timings[:scalar_add] = @timeit broadcast(+,foo,4)
timings[:length] = @timeit length(foo)
timings[:nrun] = @timeit nrun(foo)
timings[:mean] = @timeit mean(foo)
timings[:max] = @timeit maximum(foo)
timings[:width] = @timeit rwidth(foo)
timings[:last] = @timeit rlast(foo)
timings[:first] = @timeit rfirst(foo)
timings[:add_two_rles] = @timeit broadcast(+,foo,foo)
timings[:disjoin] = @timeit disjoin(foo.runends,foo.runends)
timings[:which] = @timeit findall(in(foo),[800,200,357])
timings[:scalar_less] = @timeit broadcast(<,foo,3)
timings[:median] = @timeit median(foo)
timings[:which_max] = @timeit findmax(foo)

bdf = CSV.read(results_file,header=true);

for n in names(timings)
  if !(n in names(bdf))
    bdf[n] = NaN
  end
end

bdf = vcat(bdf,timings)

CSV.write(results_file, bdf)

jdf = timings
rdf = bdf[ bdf[:language] .== "R",:]
rdf = rdf[end,:]
rdf = rdf[4:end]
jdf = jdf[4:end]

for n in names(rdf)
       println(n)
       println( rdf[n] / jdf[n])
end
r_over_julia = zeros(ncol(rdf))

for i in 1:length(r_over_julia)
    r_over_julia[i] = log2(rdf[i][1] / jdf[i][1])
end

### Plotting
using VegaLite
using FileIO

## Performance Relative to R
date = bdf[end,:date]
relative_perf_file = "/Users/phaverty/.julia/dev/RLEVectors/benchmark/plots/benchmark_rle_vectors.$(date).svg"

df = DataFrame(:function => names(rdf), :ratio => r_over_julia)
df[:,:function] = string.(df[:,:function])
df |> @vlplot(
  :bar,
  x=:function,
  y=:ratio,
  width=500,
  title = "Relative Performance of R and Julia Rle Vectors") |> save(relative_perf_file)


  #Guide.ylabel("Elapsed Time: log2(R/julia)"),
  #Guide.xticks(orientation=:vertical),
  #Scale.color_continuous(minvalue=-15,maxvalue=15),color=r_over_julia,
  #Geom.hline(color="black"),yintercept=[0],Guide.xlabel("")

current_relative_perf_file = "/Users/phaverty/.julia/dev/RLEVectors/benchmark/plots/benchmark_rle_vectors.svg"
cp(relative_perf_file, current_relative_perf_file, force=true)

## Performance over time
timeline_file = "/Users/phaverty/.julia/dev/RLEVectors/benchmark/plots/benchmark_rle_vectors.$(date).timeline.svg"
jdf = bdf[ bdf[:,:language] .== "julia", 3:end ]
melted_bdf = melt(jdf, :date)
melted_bdf |>
  @vlplot(
    :line,
    x="date:t",
    y=:value,
    color=:variable,
    width=500
    ) |> save(timeline_file)
#Guide.xlabel("Date"), Geom.line,
#Scale.y_log10, Guide.ylabel("log2 elapsed seconds (1e4 runs)"))
current_timeline_file = "/Users/phaverty/.julia/dev/RLEVectors/benchmark/plots/benchmark_rle_vectors.timeline.svg";
cp(timeline_file, current_timeline_file, force=true)

## Profiling
using ProfileView
foo + foo; Profile.clear(); @profile for i in 1:1e4 foo + foo end; ProfileView.view()
foo .< 3; Profile.clear(); @profile for i in 1:1e4 foo .< 3 end; ProfileView.view()
foo .+ 3; Profile.clear(); @profile for i in 1:1e4 foo .+ 3 end; ProfileView.view()
sum(foo); Profile.clear(); @profile for i in 1:1e4 sum(foo) end; ProfileView.view()
findall(in([800,300,357]), foo); Profile.clear(); @profile for i in 1:1e5 findall(in([800,300,357]), foo) end; ProfileView.view()
median(foo); Profile.clear(); @profile for i in 1:1e4 median(foo) end; ProfileView.view()
rfirst(foo); Profile.clear(); @profile for i in 1:1e6 rfirst(foo) end; ProfileView.view()
rwidth(foo); Profile.clear(); @profile for i in 1:1e6 rwidth(foo) end; ProfileView.view()
foo[800] = 5; Profile.clear(); @profile for i in 1:1e6 foo[800] = 5 end; ProfileView.view()
foo[802] = 5; Profile.clear(); @profile for i in 1:1e6 foo[802] = 5 end; ProfileView.view()
foo[801:900] = 1:100; Profile.clear(); @profile for i in 1:1e5 foo[801:900] = 1:100 end; ProfileView.view()

x = collect(2:6:5000)
y = collect(6:4:5000)

foo = disjoin(x, y)
goo = disjoin2(x, y)
goo = goo[1:1667]
foo == goo

@time for i in 1:1e6 disjoin(x, y) end
@time for i in 1:1e6 disjoin2(x, y) end
Profile.clear(); @profile for i in 1:1e6 disjoin2(x, y) end; ProfileView.view()
