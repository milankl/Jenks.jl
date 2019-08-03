[![Build Status](https://travis-ci.com/milankl/Jenks.jl.svg?branch=master)](https://travis-ci.com/milankl/Jenks.jl)
[![Build Status](https://api.cirrus-ci.com/github/milankl/Jenks.jl.svg)](https://cirrus-ci.com/github/milankl/Jenks.jl)

# Jenks.jl
Jenks Natural Breaks Optimization - a 1D classification method to minimise in-class variance or L1 rounding error.

![example](figs/example.png?raw=true "Example Jenks Classification")

From [Wikipedia](https://en.wikipedia.org/wiki/Jenks_natural_breaks_optimization): Jenks natural breaks classification method is a data clustering method designed to determine the best arrangement of values into different classes. This is done by seeking to minimize each class’s average deviation from the class mean, while maximizing each class’s deviation from the means of the other groups. In other words, the method seeks to reduce the variance within classes and maximize the variance between classes.

# Algorithm

Jenks Classification is an iterative optimization process. We start by

0. Define `n` (arbitrary) initial classes. We use a maximum entropy method: The data array is sorted and split into `n` equal chunks, the boundaries of these classes are defined as the initial `breaks` for the `n` classes.

Then loop over

1. For each class, calculate the sum of deviations `DEV` of all data points within that class from the class mean. This deviation can be linear (L1-norm), i.e. abs(xi - μ), or quadratic (L2-norm), i.e. (xi-μ)^2.

2. Calculate the sum of all `DEV`s from all classes and record that value, which is important to assess convergence. For linear deviations this is the average rounding error (or quantization error), which should decrease over iterations, for squared deviations this is the something like the in-class variance, which can be used to calculated the goodness of variance fit, which should approach 1.0

3. For each class, compare the `DEV` of that class to the next classes `DEV`.

    3.1 if larger: The `break` between that class and the neighbouring class should be shifted by `s` to make the class with the smaller `DEV` larger, i.e. so that it contains more data points.
    
    3.2 else, shift by `s` in the other direction.
    
The tricky bit is how to define `s`, which is technically a `flux` of data points from one class to the other (hence, it's called `flux` in the function arguments), that means how much to change the class boundaries in each iteration. We used the following approaches

1. The flux should scale with the size of the 'donating' class. For a constant flux, a class with `N` members passes a certain fraction (for `flux=0.1` this is 10%) to the adjacent class.

2. The flux decreases by `fluxadjust` (a multiplicative factor in the function arguments) if the previous flux direction was oppsite, i.e. in the previous iteration the same two classes exchanged data points in the opposite direction. This is helpful for convergence.

2.1 The flux can also increase by `fluxadjust` when the flux direction previously was the same. This accelerates the convergence.

3. The flux cannot be larger than the size of the donating class. This guarantees that every class always contains at least one member and avoids overlapping classes.

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
