mutable struct JenksResult
    n::Int                          # number of classes / intervals
    ndata::Int                      # number of data points
    breaks::Array{Int,1}            # break indices in data array
    bounds::Array{Float64,1}        # lower bound of each class
    centres::Array{Float64,1}       # centres of intervals
    n_in_class::Array{Int,1}        # number of data points per class
    ARE::Float64                    # Average rounding error (L1 norm)
    GVF::Float64                    # Goodness of variance fit
    AREhistory::Array{Float64,1}    # Rounding error for each iteration
    GVFhistory::Array{Float64,1}    # GVF for each iteration
    errornorm::Int                  # 1 for L1, 2 for L2
    maxiter::Int                    # number of iterations
    dt::Float64                     # time for all iterations (excl initialisation)
end

function JenksResult(n::Int,data::Array{T,1};
                    maxiter::Int=0,
                    errornorm::Int=1) where {T<:AbstractFloat}

    ndata = length(data)

    # classification results
    breaks = Array{Int,1}(undef,n+1)
    centres = Array{Float64,1}(undef,n)
    bounds = Array{Float64,1}(undef,n+1)
    n_in_class = Array{Int,1}(undef,n)

    # error measures
    ARE = 0.0
    GVF = 0.0
    AREhistory = Array{Float64,1}(undef,maxiter+1)
    GVFhistory = Array{Float64,1}(undef,maxiter+1)

    # time measures
    dt = 0.0

    JenksResult(n,ndata,breaks,bounds,centres,n_in_class,
                ARE,GVF,AREhistory,GVFhistory,
                errornorm,maxiter,dt)
end

"""Calculate the class centres from the class break indices. Assumes data in X to be sorted."""
function Breaks2Centres!(JR::JenksResult,X::Array{T,1}) where {T<:AbstractFloat}
    for i in 1:JR.n
        JR.centres[i] = (X[JR.breaks[i]] + X[JR.breaks[i+1]-1])/2
    end
end

"""Calculate the class sizes (number of data points per class/interval) from break indices."""
function Breaks2ClassSize!(JR::JenksResult)
    for i in 1:JR.n
        JR.n_in_class[i] = JR.breaks[i+1] - JR.breaks[i]
    end
end

"""Calculate the lower bounds from break indices. Assumes data in X to be sorted."""
function Breaks2Bounds!(JR::JenksResult,X::Array{T,1}) where {T<:AbstractFloat}
    for i in 1:JR.n
        JR.bounds[i] = X[JR.breaks[i]]
    end
    JR.bounds[end] = X[end]
end
