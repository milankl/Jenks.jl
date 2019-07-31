"""Initialises the breaks array based on various methods:

    maxentropy: quantile / maximum entropy.
    equidistant: ..."""
function BreaksInit(n::Int,X::Array{T,1};
                    method::String="maxentropy") where {T<:AbstractFloat}

    if method == "maxentropy"

        np = length(X) ÷ n       # number of data points per chunk

        # breaks are determind by the lower bounds index of the data array X
        breaks = Array{Int,1}(undef,n+1)

        # the lower bounds index of the first interval is always 1
        # quantile-approach / maximum entropy method
        breaks[1:end-1] = collect(1:np:np*n)

        # this is redundant but makes class collection easier
        breaks[end] = length(X)+1

    elseif method == "equi"     # equi-distant

        spread = maximum(X)-minimum(X)
        Δ = spread/n

        # breaks are determind by the lower bounds index of the data array X
        breaks = Array{Int,1}(undef,n+1)
        breaks[1] = 1
        breaks[end] = length(X)+1

        for i = 2:n
            breaks[i] = FindClosest(X,1+Δ*(i-1))
        end
    else
        throw(error("Method '$method' not defined."))
    end

    return breaks
end

"""Find the closest index in array x to a."""
function FindClosest(x::Array{T,1},a::T) where {T<:AbstractFloat}
    return argmin(abs.(x.-a))
end
