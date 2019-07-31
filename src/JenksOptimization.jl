"Jenks Natural Breaks Optimzation algorithm. Assumes data in X to be sorted."
function JenksOptimization(n::Int,X::Array{T,1},
                            maxiter::Int=1000,
                            flux::Real=0.1,
                            feedback::Bool=true) where {T<:AbstractFloat}

    ndata = length(X)

    # Initialisation
    breaks = BreaksInit(n,X)            # lower bounds of every class as index of X
    SDCMs = Array{Float64,1}(undef,n)   # squared deviations from class mean for each class
    SDAM = SqDeviation(X)               # squared deviation from array mean (this is constant)

    t0 = time()
    for iter in 1:maxiter

        # Get the squared deviations for all classes
        for iclass in 1:n
            SDCMs[iclass] = SqDeviation(ClassValues(X,breaks,iclass))
        end

        # provide goodness of variance feedback
        if feedback
            GVF = 1-sum(SDCMs)/SDAM
            percent = Int(round(iter/maxiter*100))
            print("\r\u1b[K")
            print("$percent%: GVF=$GVF")
        end


        for iclass in 1:n-1

            # for class sizes
            a,b,c = breaks[iclass:iclass+2]

            # # variance ratio
            # v_ratio = SDCMs[iclass]/SDCMs[iclass+1]
            # v_ratio = Int(round(v_ratio > 1.0 ? v_ratio : 1/v_ratio))   # invert ratio if < 1

            if SDCMs[iclass] < SDCMs[iclass+1]      # compare deviations between two adjacent classes

                # class size factor: Bigger classes give away more data points
                cs_factor = Int(round((b-a)*flux))
                breaks[iclass+1] += cs_factor #decay(cs_factor,iter,maxiter)     # shift data points to the class with smaller variance
            else
                # class size factor: Bigger classes give away more data points
                cs_factor = Int(round((c-b)*flux))
                breaks[iclass+1] -= cs_factor #decay(cs_factor,iter,maxiter)               # shift data points to the class with smaller variance
            end

            #println((cs_factor,b-a,c-b,SDCMs[iclass],SDCMs[iclass+1]))
        end

        breaks[n] = min(breaks[n],ndata)


    end
    dt = time() - t0
    println(", finished in $(dt)s.")

    return breaks
end

# function decay(f::Int,i::Int,imax::Int)
#     return max(Int(round(f*i/imax)),1)
# end

"""Returns the data point values for a given class i, provided the data X and
the breaks. Assumes the data array X to be sorted."""
function ClassValues(X::Array{T,1},breaks::Array{Int,1},i::Int) where {T<:AbstractFloat}
    return X[breaks[i]:breaks[i+1]-1]
    # @inbounds return X[breaks[i]:breaks[i+1]-1]
end

function JenksClassification(n::Int,X::Array{T,1};
                            maxiter::Int=1000,
                            flux::Real=0.1,
                            feedback::Bool=true) where {T<:AbstractFloat}

    sort!(X)
    breaks = JenksOptimization(n,X,maxiter,flux,feedback)

    class_centres = Array{Float64,1}(undef,n)

    for i in 1:n
        class_centres[i] = (X[breaks[i]] + X[breaks[i+1]-1])/2
    end

    return class_centres
end
