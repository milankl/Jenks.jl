module Jenks

export jenks

using Random, StatsBase, Statistics, Printf

include("initialisation.jl")
include("gvf.jl")
include("JenksOptimization.jl")

end
