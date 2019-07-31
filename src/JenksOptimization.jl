"Jenks Natural Breaks Optimzation algorithm. Assumes data in X to be sorted."
function JenksOptimization(n::Int,X::Array{T,1},
                            errornorm::Int=1,
                            maxiter::Int=200,
                            flux::Real=0.1,
                            feedback::Bool=true) where {T<:AbstractFloat}

    ndata = length(X)

    # Initialisation
    breaks = BreaksInit(n,X)            # lower bounds of every class as index of X
    SDAM = SqDeviation(X)               # squared deviation from array mean (this is constant)
    DEVs = Array{Float64,1}(undef,n)    # Deviations from class centre for each class (lin/sq)


    if errornorm == 1
        Deviation = LinDeviation
    elseif errornorm == 2
        Deviation = SqDeviation
    else
        throw(error("Errornorm '$errornorm' not defined."))
    end

    t0 = time()
    for iter in 1:maxiter

        # Get the lin/squared deviations for all classes
        for iclass in 1:n
            DEVs[iclass] = Deviation(ClassValues(X,breaks,iclass))
        end

        # provide goodness of variance feedback
        if feedback
            percent = Int(round(iter/maxiter*100))

            if errornorm == 1
                ARE = @sprintf "%.8f" sum(DEVs)/ndata
                print("\r\u1b[K")
                print("$percent%: ARE=$ARE")
            else
                GVF = @sprintf "%.8f" 1-sum(DEVs)/SDAM
                print("\r\u1b[K")
                print("$percent%: GVF=$GVF")
            end
        end

        # shift class bounds
        for iclass in 1:n-1

            a,b,c = breaks[iclass:iclass+2]         # for class sizes

            if DEVs[iclass] < DEVs[iclass+1]        # compare deviations between two adjacent classes
                cs_factor = Int(round((b-a)*flux))  # class size factor: Bigger classes give away more data points
                # shift data points to the class with smaller DEV
                newbreak = breaks[iclass+1]+cs_factor
                breaks[iclass+1] = min(newbreak,breaks[iclass+2]-2)
            else
                cs_factor = Int(round((c-b)*flux))
                newbreak = breaks[iclass+1]-cs_factor
                breaks[iclass+1] = max(newbreak,breaks[iclass]+2)
            end
        end
    end
    dt = time() - t0
    println(@sprintf ", finished in %.2fs." dt)

    return breaks
end

"""Returns the data point values for a given class i, provided the data X and
the breaks. Assumes the data array X to be sorted."""
function ClassValues(X::Array{T,1},breaks::Array{Int,1},i::Int) where {T<:AbstractFloat}
    return X[breaks[i]:breaks[i+1]-1]
    # @inbounds return X[breaks[i]:breaks[i+1]-1]
end

"""Run the JenksOptimization and return the class centres calculated from the class breaks."""
function JenksClassification(n::Int,X::Array{T,1};
                            errornorm::Int=1,
                            maxiter::Int=200,
                            flux::Real=0.1,
                            feedback::Bool=true) where {T<:AbstractFloat}

    sort!(X)
    breaks = JenksOptimization(n,X,errornorm,maxiter,flux,feedback)

    # Compute class centres from breaks 
    class_centres = Array{Float64,1}(undef,n)

    for i in 1:n
        class_centres[i] = (X[breaks[i]] + X[breaks[i+1]-1])/2
    end

    return class_centres
end
