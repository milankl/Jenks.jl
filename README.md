# Jenks.jl
Jenks Natural Breaks Optimization - a 1D classification method to minimise in-class variance or L1 rounding error.

![example](figs/example.png?raw=true "Example Jenks Classification")

# Usage

Specify the number of classes `n`, and provide some data `data`, then
```julia
using Jenks
data = randn(10_000)
n = 5
JR = JenksClassification(n,data)
```
After completion the struct `JR` contains the break indices `JR.breaks`, the bounds `JR.bounds`, the number of elements per class `JR.n_in_class` and a few other result parameters.

```Julia
julia> JR.n_in_class
5-element Array{Int64,1}:
 1281
 2564
 2729
 2241
 1185
```
A comprehensive example can be found in this [notebook](https://github.com/milankl/Jenks.jl/blob/master/docs/simple_example.ipynb)

# Installation
In the REPL do
```julia
] add https://github.com/milankl/Jenks.jl
```
