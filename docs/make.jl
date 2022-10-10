using Documenter, RLEVectors

makedocs(
         format = :html,
	 sitename = "RLEVectors"
	 )

deploydocs(
           repo = "github.com/phaverty/RLEVectors.jl.git",
           julia = "release"
           )
