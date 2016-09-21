library("IRanges")
foo = Rle( seq(1,1000), rep.int(5,1000) )
l = 1:1e4

timings = data.frame(
    language = "R",
    language_version = "3.3.1",
    date = as.character(Sys.Date()), 
    indexing = system.time( for(i in l) { foo[800] } )["elapsed"],
    range_indexing = system.time( for(i in l) { foo[801:900] } )["elapsed"],
    setting = system.time( for(i in l) { foo[800] = 5} )["elapsed"],
    range_setting = system.time( for(i in l) { foo[801:900] = 1:100 } )["elapsed"],
    scalar_add = system.time( for(i in l) { foo = foo + 4 } )["elapsed"],
    length = system.time( for(i in l) { length(foo) } )["elapsed"],
    nrun = system.time( for(i in l) { nrun(foo) } )["elapsed"],
    mean = system.time( for(i in l) { mean(foo,na.rm=FALSE) } )["elapsed"],
    max = system.time( for(i in l) { max(foo,na.rm=FALSE) } )["elapsed"],
    width = system.time( for(i in l) { width(foo) } )["elapsed"],
    last = system.time( for(i in l) { end(foo) } )["elapsed"],
    first = system.time( for(i in l) { start(foo) } )["elapsed"],
    add_two_rles = system.time( for(i in l) { foo + foo } )["elapsed"],
    disjoin = system.time( for(i in l) { disjoin(ranges(c(foo, foo))) } )["elapsed"],
    which  = system.time( for(i in l) { which(foo %in% c(800L,200L,357L)) } )["elapsed"],
    scalar_less  = system.time( for(i in l) { foo < 3 } )["elapsed"],
    median  = system.time( for(i in l) { median(foo) } )["elapsed"],
    which_max  = system.time( for(i in l) { which.max(foo) } )["elapsed"],
    stringsAsFactors=FALSE)

foo = read.csv("rle.timings.csv", as.is=TRUE)
for (x in setdiff(colnames(timings), colnames(foo))) {
    foo[, x] = NaN
}
foo = foo[, colnames(timings)]

timings = rbind(foo, timings)
write.csv(timings, "/Users/phaverty/.julia/v0.5/RLEVectors/benchmark/rle.timings.csv",
          row.names=FALSE,append=TRUE, na="NaN")
print(timings)
