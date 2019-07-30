"""Initialises the breaks array based on quantile / maximum entropy method."""
function BreaksInit(n::Int,X::Array{T,1}) where {T<:AbstractFloat}

    np = length(X) ÷ n       # number of data points per chunk

    # breaks are determind by the lower bounds index of the data array X
    breaks = Array{Int,1}(undef,n+1)

    # the lower bounds index of the first interval is always 1
    # quantile-approach / maximum entropy method
    breaks[1:end-1] = collect(1:np:np*n)

    # this is redundant but makes class collection easier
    breaks[end] = length(X)+1

    return breaks
end

"""Returns the data point values for a given class i, provided the data X and
the breaks. Assumes the data array X to be sorted."""
function ClassValues(X::Array{T,1},breaks::Array{Int,1},i::Int)
    return X[breaks[i]:breaks[i+1]-1]
end

function JenksOptimization(n::Int,X::Array{T,1}) where {T<:AbstractFloat}

    breaks = BreaksInit(n,X)
    sort!(X)

    maxiter = 10

    for iter in 1:maxiter

        # Do a GVF estimate and print it?

        for iclass in 1:n-1

            ThisClass = ClassValues(X,breaks,iclass)
            NextClass = ClassValues(X,breaks,iclass+1)

            ThisClassMean = mean(ThisClass)
            NextClassMean = mean(NextClass)

            s0 = SDAM(ThisClass,ThisClassMean) + SDAM(NextClass,NextClassMean)

            breaks[iclass+1] -= 1

            ThisClass = ClassValues(X,breaks,iclass)
            NextClass = ClassValues(X,breaks,iclass+1)

            ThisClassMean = mean(ThisClass)
            NextClassMean = mean(NextClass)

            s1 = SDAM(ThisClass,ThisClassMean) + SDAM(NextClass,NextClassMean)

            if s1 > s0

                breaks[iclass+1] += 2

                ThisClass = ClassValues(X,breaks,iclass)
                NextClass = ClassValues(X,breaks,iclass+1)

                ThisClassMean = mean(ThisClass)
                NextClassMean = mean(NextClass)

                s2 = SDAM(ThisClass,ThisClassMean) + SDAM(NextClass,NextClassMean)

                if s2 > s1
                    breaks[iclass+1] -= 2
                end
            end
        end
    end

    return breaks
end
