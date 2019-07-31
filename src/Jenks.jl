module Jenks

export JenksOptimization, GVF, JenksClassification

using Random, StatsBase, Statistics, Printf

include("initialisation.jl")
include("gvf.jl")
include("JenksOptimization.jl")

end
