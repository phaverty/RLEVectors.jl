# TODO list

## Initial features for V0.1.0
 * [x] Examples in toplevel README
 * [x] Some bleeping unit tests already!  It's time.
 * [x] Test for types
 * [x] Test for collections
 * [x] Test for indexing
 * [x] Test for describe
 * [x] Test for math
 * [x] Tests for utils
 * [x] Split RLEVectors.jl into multiple files by subject. It's getting unweildy.
 * [x] conversion of RLEVector{T} to Vector{T}
 * [x] runind or findRun or whichRun method, return index or (index,offset)
 * [x] how does julia do R's table? R's S4vectors doesn't do table(rle1,rle2), but wants to
 * [x] Set operations like setdiff, union, symdiff
 * [x] rle method on Rle, drop zero length runs and join runs with same value
 * [x] clarity on zero-length runs. OK? start and end == 1? What would value be (would I need to get myself involved with DataArrays and Nullable do do this?)
 * [x] in initializer check incoming runends are sorted
 * [x] initializer checks incoming runends are stricly increasing, would be nice to use issorted with a new comparator
 * [x] rep utility to match R's
 * [x] more vector funs: head, tail
 * [x] getindex and setindex! for i::AbstractArray
 * [x] deleteat!
 * [x] splice!
 * [x] inverse_rle method for RLEVector, use in collect etc., skip rwidth
 * [x] fix setindex when on end of run, check for zero length run
 * [x] resize!
 * [x] constructor that takes bitarray and converts to bool array: convert(Vector{Int32},bob)
 * [x] sorting including sort, issorted, reverse and sortperm

## Decisions
 *[ ] How do I set up the type hierarchy?
   a.  How do I share common code as high in the tree as possible? (wait for new features of abstract types in 0.4?)
   b.  Can I make it a subtype of Vector and get lots of the Vector
   API for free?  Can I then use it in other places that take a
   vector? Like a DataFrame column?

* [x] How do I represent the runs? length, end, start/end?

    end allows for direct binarysearch for indexing and makes size a simple lookup
    Gives 5X speedup for size, 40X for indexing on RLEVector(int([1:1:1e3]),int([1:1:1e3]))
    19956X speedup over R (more efficient algo here though) for
      foo = Rle( seq(1,1000,5), rep.int(5,200) )
      l = 1:1e3; system.time( for(i in l) { foo[100] } )
        vs.
      foo = IntegerRle([ int(linspace(1,1000,200)) ], [ int(linspace(1,1000,200)) ])
      @time for i in 1:1e3 foo[100] end
      2000X speedup for foo + 4

* [ ] Is there a strictly increasing and positive int vector type I can leverage or make for the runs?
       Maybe something that could be linked to the values?  OrderedSet, IntSet?
       For disjoin operations, it will be useful to know the unique runends in two+ sets of runs
       Would be nice to have disjoin for RLEVector and RunEnds and IRanges and GRanges types

* [x] What do I call the getters and setters? I want to use same getters for RLEs and GRanges and such.
    begin, end and start are taken. first, step, and last make sense because of what they mean for ranges, but they would mean something else for a Vector
    Maybe confusion between Ranges and Vector API means that I should just make my own and use rangestart, rangewidth, rangeend or rfirst, rwidth and rlast. With the latter, the 'r' could be range or run.
    -> Going with rfirst, rwidth, rlast

 * [x] Is it a good idea to require two arg vectors to be the same length like this: function bob{T1,T1,N}(x::Vector{T1,N},y::Vector{T2,N})  ?  Or just test the lengths and throw an ArgumentError?


 * [x] Is 1 an appropriate start for an empty RLEVector? Does that imply that there is a value associated? Go to zero-based, half open (#can-of-worms)?. NO.
 * [x] does one export methods defined on generics from Base?
 * [x] similar. What would length arg do?  length, nrun, always return an empty one?
 * [x] better naming for runindex, ind2run
 * [x] maybe drop ree!(x::RLEVector) for a ree that returns a tuple of cleaned up runvalues and runends? With the new 0.4 tuple hotness performance won't matter anymore (right?)
 * [x] when incoming runvalues for RLEVector creation is a BitArray (like from .<) where do I unpack it? Probably best during ree, because it will probably get shorter. Use numruns(runvalues) then deal with 0-len runs separately?
 * [x] What type to return for a slice of an RLEVector?
 * [x] likewise, maybe ind2range(RLEVector, UnitRange) should return a UnitRange

## Enhancements
 * [ ] Make Runs type, split from and use in RLEVector
 * [x] pretty `show` with elipsis if length > 6, show runs and also expanded vector, use utils.rep
 * [x] Add benchmark/ with R and .jl scripts comparing timings on some common things. Have one read a CSV from the other and plot.
 * [ ] outer constructor for RLEVectors that takes runends or vector and then optional named args runends and runwidths
 * [ ] Can I make a special zip-like loop that runs over the disjoint runs of 2+ RLEVectors and the associated values?
 * [ ] vcat with splat for multiple args (vararg vcat)
 * [x] deleterun! should give a ree'd RLEVector, check for newly adjacent runs, use deleteat![x,itr] if necessary
 * [x] Any other function groups from DataArrays that I need?
 * [x] factor out run counting stuff in ree(Vector) and disjoin, call it `nrun`
 * [x] implement comparison operators <=, etc.
 * [x] Rle to set conversion
 * [ ] iterator versions of rwidth and rstart. Allocation is the root of all evil. Allocation in rwidth seems to be the bulk of 'median' at this point, for example.
 * [x] ind2runcontext for UnitRange, use for setindex(x::RLEVector, value, indices::UnitRange)
 * [x] Make sure this works with Julia V0.4. Likely we have some tuple trouble and the tests will be riddled with the Range expansion change ([1:4] is a 1-vector of Ranges rather than [1,2,3,4]).
 * [x] function documentation section: describing
 * [x] function documentation section: creating
 * [x] function documentation section: range functions
 * [ ] get ree and vcat out of splice

## Optimizations
 * [ ] Re-read julia/base/range.jl, some day understand the meaning of "# to make StepRange constructor inlineable, so optimizer can see `step` value"
 * [x] getindex and setindex! optimizations for sorted i, especially for i::UnitRange
 * [ ] Lint clean and test for that
 * [ ] TypeCheck clean (and test for that?)
 * [ ] some trick with start(Range) to make splice! work with scalar int or range
 * [ ] revisit all the array surgery functions like splice!, factor out common elements, try to use resize and copy. Try to centralize the merging of two things, checking for shared runvalues at the ends.
 * [x] try optimizing rwidth and rfirst by copying x.runends and then modifying the copy in place
 * [x] much faster rwidth and rfirst
 * [x] get vcat and sort out of disjoin, especially sort
 * [ ] Everything seems to have a special case for length < 2 Rles. Is there some way to make those unnecessary globally?
 * [x] custom O(n) disjoin
 * [x] ree, bottleneck is making the return tuple. Do ree! and update an Rle?
 * [x] use sort for median rather than collect, use i = fld(n,2) + 1 for odd n ...
 * [x] look for places where I can use isempty instead of length. 2X speed of nrun(x) == 0 and 4X speed of length(x) == 0
 * [x] findmin
 * [x] findmax
 * [x] findin
 * [x] indexin
 * [ ] can I do setindex(x::Rlevector, i, indices::Array) and such with an iterator that feeds "ree"?  Sort incoming indices and values of course.
 * [x] add a few special cases to the "punt else" to work towards not punting
 * [ ] setindex!(rle::RLEVector, value, i::UnitRange), can I merge this with the scalar i case using i:i?

## Bugs
 * [x] fix mode, needs to do table not just which.max
 * [x] fix vcat, what about merging adjacent runs?
 * [x] binary_functions list not all commutative, split up, mabye set operations separately
 * [x] changes to ree cause reversions in insert and splice
 * [x] Fix group generics definitions to get rid of ambiguous method warnings
 * [x] something is wrong with the iterator, which breaks sum and mean
 * [x] something in splice and insert
 * [x] ree(runvalues,runends) needs to avoid modifying input
