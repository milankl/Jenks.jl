"""Squared deviations from the array mean."""
function SqDeviation(X::Array{T,1}) where {T<:AbstractFloat}

    s = zero(T)
    μ = mean(X)

    @simd for xi in X
        s += (xi - μ)^2
    end

    return s
end

"""Linear deviations from the array mean - i.e. L1-Norm."""
function LinDeviation(X::Array{T,1}) where {T<:AbstractFloat}

    s = zero(T)
    μ = mean(X)

    @simd for xi in X
        s += abs(xi - μ)
    end

    return s
end

"""Squared deviations from the class means."""
function SDCM(X::Array{T,1},breaks::Array{Int,1}) where {T<:AbstractFloat}

    n = length(breaks)  # number of classes (aka intervals)

    @boundscheck breaks[end] < length(X) || throw(BoundsError())
    @boundscheck breaks[1] == 1 || throw(BoundsError())

    s = zero(T)

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
