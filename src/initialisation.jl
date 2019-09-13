"""Initialises the breaks array based on various methods:

    maxentropy: quantile / maximum entropy.
    rand: random breaks without empty classes."""
function BreaksInit(n::Int,X::Array{T,1},method::String="maxentropy") where {T<:AbstractFloat}

    if method == "maxentropy"

        np = length(X) ÷ n       # number of data points per chunk

        # breaks are determind by the lower bounds index of the data array X
        breaks = Array{Int,1}(undef,n+1)

        # the lower bounds index of the first interval is always 1
        # quantile-approach / maximum entropy method
        breaks[1:end-1] = collect(1:np:np*n)

        # this is redundant but makes class collection easier
        breaks[end] = length(X)+1

    elseif method == "rand"     # random initialisation

        # breaks are determind by the lower bounds index of the data array X
        breaks = Array{Int,1}(undef,n+1)
        breaks[1] = 1
        breaks[end] = length(X)+1

        breaks[2:end-1] = randintNDNC(3,length(X)-1,n-1)

    else
        throw(error("Method '$method' not defined."))
    end

    return breaks
end

"""randint with no duplicates and no consecutive numbers"""
function randintNDNC(N0::Int,N1::Int,n::Int)

    ratio = n/(N1-N0)

    if ratio > 0.33
        throw(error("Subset-set size ratio is $ratio, too likely that no solution can be found. Increase n."))
    elseif ratio > 0.2 && n > 10000
        @warn "Finding $n random numbers for a subset-set size ratio of $ratio may take a long time."
    end

    v = Array{Int,1}(undef,n)
    v[1] = rand(N0:N1)

    for i in 2:n
        r = rand(N0:N1)     # pick a random number
        while any(abs.(r .- v[1:i-1]) .<= 1)    # check that it's not duplicate or a consecutive
            r = rand(N0:N1) # if that's the case try another one.
        end
        v[i] = r
    end

    sort!(v)
    return v
end
