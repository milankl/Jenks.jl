mutable struct JenksResult
    n::Int                      # number of classes / intervals
    ndata::Int                  # number of data points
    breaks::Array{Int,1}        # breaks in data array
    centres::Array{Float64,1}   # centres of intervals
    n_in_class::Array{Int,1}    # number of data points per class
    ARE::Float64                # Average rounding error (L1 norm)
    GVF::Float64                # Goodness of variance fit
    errornorm::Int              # 1 for L1, 2 for L2
    maxiter::Int                # number of iterations
    dt::Float64                 # time for all iterations (excl initialisation)
end

function JenksResult(n::Int,data::Array{T,1};
                    maxiter::Int=0,
                    errornorm::Int=1) where {T<:AbstractFloat}

    ndata = length(data)
    breaks = Array{Int,1}(undef,n+1)
    centres = Array{Float64,1}(undef,n)
    n_in_class = Array{Int,1}(undef,n)
    ARE = 0.0
    GVF = 0.0
    dt = 0.0

    JenksResult(n,ndata,breaks,centres,n_in_class,ARE,GVF,errornorm,maxiter,dt)
end
