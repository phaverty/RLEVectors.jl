using RLEVectors
using DataFrames

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
timings[:date] = chomp(readstring(`date "+%Y-%m-%d"`))
timings[:indexing] = @timeit foo[100]
timings[:range_indexing] = @timeit foo[801:900]
timings[:setting] = @timeit foo[800] = 5
timings[:range_setting] = @timeit foo[801:900] = 1:100
timings[:scalar_add] = @timeit foo + 4
timings[:length] = @timeit length(foo)
timings[:nrun] = @timeit nrun(foo)
timings[:mean] = @timeit mean(foo)
timings[:max] = @timeit maximum(foo)
timings[:width] = @timeit rwidth(foo)
timings[:last] = @timeit rlast(foo)
timings[:first] = @timeit rfirst(foo)
timings[:add_two_rles] = @timeit foo + foo
timings[:disjoin] = @timeit disjoin(foo.runends,foo.runends)
timings[:which] = @timeit findin(foo,[800,200,357])
timings[:scalar_less] = @timeit foo .< 3
timings[:median] = @timeit median(foo)
timings[:which_max] = @timeit findmax(foo)

bdf = DataFrames.readtable("/Users/phaverty/.julia/v0.4/RLEVectors/benchmark/rle.timings.csv",header=true);

for n in names(timings)
  if !(n in names(bdf))
    bdf[n] = NaN
  end
end

bdf = vcat(bdf,timings)

writetable( "/Users/phaverty/.julia/v0.4/RLEVectors/benchmark/rle.timings.csv",
             bdf, separator=',',header=true)

jdf = timings
rdf = bdf[ bdf[:language] .== "R",:];
rdf = rdf[end,:]

for n in names(bdf)[4:end]
       println(n)
       println( rdf[1,n] / jdf[1,n])
end
r_over_julia = zeros(ncol(bdf)-3)

for i in 1:length(r_over_julia)
    r_over_julia[i] = log2(rdf[1,i+3] / jdf[1,i+3])
end

### Plotting
using Gadfly

## Performance Relative to R
bench_plot = plot(x=names(bdf)[4:end],y=r_over_julia, Geom.bar, Guide.ylabel("Elapsed Time: log2(R/julia)"),
     Guide.xticks(orientation=:vertical),Scale.color_continuous(minvalue=-15,maxvalue=15),color=r_over_julia,
     Guide.title("Relative Performance of R and Julia Rle Vectors"),Geom.hline(color="black"),yintercept=[0],Guide.xlabel(""))

date = jdf[1,:date]
relative_perf_file = "/Users/phaverty/.julia/v0.4/RLEVectors/benchmark/plots/benchmark_rle_vectors.$(date).png"
draw(PNG(relative_perf_file,8inch,5inch),bench_plot )
current_relative_perf_file = "/Users/phaverty/.julia/v0.4/RLEVectors/benchmark/plots/benchmark_rle_vectors.png"
cp(relative_perf_file, current_relative_perf_file, remove_destination=true)

## Performance over time
jdf = bdf[ bdf[:,:language] .== "julia", 3:end ]
melted_bdf = melt(jdf, :date)
timeline_plot = plot(melted_bdf, x="date", y="value", color="variable", Guide.xlabel("Date"), Geom.line,
                     Scale.y_log10, Guide.ylabel("log2 elapsed seconds (1e4 runs)"))
timeline_file = "/Users/phaverty/.julia/v0.4/RLEVectors/benchmark/plots/benchmark_rle_vectors.$(date).timeline.png"
draw(PNG(timeline_file,10inch,6inch),timeline_plot )
current_timeline_file = "/Users/phaverty/.julia/v0.4/RLEVectors/benchmark/plots/benchmark_rle_vectors.timeline.png"
cp(timeline_file, current_timeline_file, remove_destination=true)

## Profiling
using ProfileView
foo + foo; Profile.clear(); @profile for i in 1:1e6 foo + foo end; ProfileView.view()
foo .< 3; Profile.clear(); @profile for i in 1:1e4 foo .< 3 end; ProfileView.view()
foo .+ 3; Profile.clear(); @profile for i in 1:1e4 foo .+ 3 end; ProfileView.view()
sum(foo); Profile.clear(); @profile for i in 1:1e4 sum(foo) end; ProfileView.view()
findin(foo,[800,300,357]); Profile.clear(); @profile for i in 1:1e5 findin(foo,[800,300,357]) end; ProfileView.view()
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
