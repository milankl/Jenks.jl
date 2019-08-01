module Jenks

export JenksClassification, GVF, JenksResult

using Random, StatsBase, Statistics, Printf

include("initialisation.jl")
include("metrics.jl")
include("JenksStruct.jl")
include("JenksOptimization.jl")

end
