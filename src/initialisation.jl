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

"""Find the closest index in array x to a."""
function FindClosest(x::Array{T,1},a::T) where {T<:AbstractFloat}
    return argmin(abs.(x.-a))
end

""" Check that array X has no duplicates and no consecutive numbers. Assumes X to be sorted."""
function isNDNC(X::Array{Int,1})
    return ~any(diff(X) .<= 1)
end

"""randint with no duplicates and no consecutive numbers"""
function randintNDNC(N0::Int,N1::Int,n::Int;printwarn::Bool=true)

    if printwarn
        if (N1-N0)/n < 10
            @warn "Finding random sample for a subset-set size ratio of >0.1 is likely taking a long time."
        end
    end

    v = rand(N0:N1,n)
    sort!(v)

    for i in 1:n-1  # push to larger numbers in case of not consecutive
        if v[i+1]-v[i] < 2
            v[i+1] += 1
        end
    end

    if isNDNC(v) && v[end] > N1     # check that actually NDNC and also not pushed beyond N1 by the last for-loop
        return v
    else
        #println("Do it again.")
        return randintNDNC(N0,N1,n,printwarn=false)
    end
end
