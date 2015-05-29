# RleVectors

`RleVectors` is an alternate implementation of the Rle type from
Bioconductor's IRanges package by H. Pages, P. Aboyoun and
M. Lawrence. RleVectors represent a vector with repeated values as the
ordered set of values and repeat extents. In the field of genomics,
data of various types are  measured across the ~3 billion letters in
the human genome can often be represented in a few thousand runs. It
is useful to know the bounds of genome regions covered by these runs,
the values associated with these runs, and to be able to perform
various mathematical operations on these values.


## Background
Bioconductor has some widely used and extremely convenient types for
working with collections of ranges, which sometimes are with
associated data.`IRanges` represents a collection of arbitrary start,
end pairs in [1,Inf). `GRanges` uses `IRanges` to represent locations
on a genome and adds annotation of the chromosome and strand for each
range. Children of `GRanges` add other annotations the the ranges. `Rle`
represents the range [1:n] broken into arbitrary chunks or segments.



## Implementation Details
`RleVectors` differs from R's `Rle` in that we store the run values
and run ends rather than the run values and run lengths. The run ends
are convenient in that they allow for indexing into the vector by
binary search (scalar indexing is O(log(n)) rather than O(n) ).
Additionally, `length` is O(1) rather than O(n) (it's the last run
end rather than the sum of the run lengths). On the other hand,
various operations do require the run lengths, which have to be
calculated. See the benchmark directory and reports to see how
this plays out.

### Creation
`RleVectors` can be created from a single vector or a vector of values and a vector of run ends. In either case runs of values or zero length runs will be compressed out. RleVectors can be expanded to a full vector like a `Range` with `collect`.

`x = RleVector([1,1,2,2,3,3,4,4,4])`
`x = RleVector([4,5,6],[3,6,9])`
`collect(x)`

### Describing
RleVectors implement the standard Vector API and also other methods for describing the ranges and values:


- `length(x)` # The full length of the vector, uncompressed
- `nrun(x)` # The number of runs in the vector
- `rstart(x)` # The index of the beginning of each run
- `rwidth(x)` # The width of each run
- `rstart(x)` # The index of the end of each run

Naming for some of these functions is difficult given that many useful names are already reserved words (`end`, `start`, `last`). Suggestions are welcome at this stage of development.

### Standard vector operations

`RleVector`s can be treated as standard Vectors for arithmetic and collection operations. In many cases these operations are more efficient than operations on a standard vector.

- `x = RleVector([4,5,6],[3,6,9])`
- `x[2]`
- `x[7:9] = 10`
- `push!(x,6)`
- `x + 2x`
- `unique(x)`
- `findin(x,5)`
- `x > 4.2`
- `sort(x)`
- `median(x)`

## Relative speed
`RleVectors` has been extensively profiled and somewhat optimized. Please see the benchmarking section for the evolution over time and comparisons to like operations in R.

### Benchmarks
![Benchmarking results](benchmark/plots/benchmark_rle_vectors.svg)

### Optimization progress
![Optimization progress](benchmark/plots/benchmark_rle_vectors.timeline.svg)

## Memory considerations
Data compression is a secondary benefit of `RleVector`s, but it can be convenient. Generally run ends are stored as Int64. However, if further memory savings are desired, consider smaller and unsigned types. Uint32 is sufficient to hold the length of the human genome and Uint16 can hold the length of the longest human chromosome.

`RleVector([5.1,2.9,100.7], Uint16[4,8,22])`


## Installation
No git at this point, so no `Pkg.add("RleVectors")`, sorry.

`svn co http://resscm.gene.com/bioinfo/projects/julia/trunk/RleVectors ~/.julia/v3/RleVectors`
