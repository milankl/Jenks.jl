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

    n = length(breaks)-1  # number of classes (aka intervals)

    @boundscheck breaks[end] == length(X)+1 || throw(BoundsError())
    @boundscheck breaks[1] == 1 || throw(BoundsError())

    s = zero(T)

    for iclass in 1:n
        s += SqDeviation(ClassValues(X,breaks,iclass))
    end

    return s
end

"""Goodness of variance fit for data array X (assumed to be sorted) and classes determined by break indices."""
function GVF(X::Array{T,1},breaks::Array{Int,1}) where {T<:AbstractFloat}
    sdam = SqDeviation(X)       # squared deviation from array mean
    sdcm = SDCM(X,breaks)       # sum  of squared deviations from class mean for each class
    return 1 - sdcm/sdam
end

"""Average rounding error for data array X (assumed to be sorted) and classes determind by break indices."""
function ARE(X::Array{T,1},breaks::Array{Int,1}) where {T<:AbstractFloat}
    s = zero(T)
    ndata = length(X)
    for iclass in 1:(length(breaks)-1)
        s += LinDeviation(ClassValues(X,breaks,iclass))
    end
    return s/ndata
end
