"""Squared deviations from the array mean."""
function SqDeviation(X::Array{T,1}) where {T<:AbstractFloat}

    s = 0.0
    Xmean = mean(X)

    @simd for xi in X
        s += (xi - Xmean)^2
    end

    return s
end

"""Squared deviations from the class means."""
function SDCM(X::Array{T,1},breaks::Array{Int,1}) where {T<:AbstractFloat}

    n = length(breaks)  # number of classes (aka intervals)

    @boundscheck breaks[end] < length(X) || throw(BoundsError())
    @boundscheck breaks[1] == 1 || throw(BoundsError())

    s = 0.0

    for iclass in 1:n
        s += SqDeviation(ClassValues(X,breaks,iclass))
    end

    return s
end

function GVF(X::Array{T,1},breaks::Array{Int,1}) where {T<:AbstractFloat}
    sdam = SqDeviation(X)
    sdcm = SDCM(X,breaks)
    return 1 - sdcm/sdam
end
