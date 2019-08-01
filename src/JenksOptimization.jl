"Jenks Natural Breaks Optimzation algorithm. Assumes data in X to be sorted."
function JenksClassification(n::Int,X::Array{T,1};
                            errornorm::Int=1,
                            maxiter::Int=200,
                            flux::Real=0.1,
                            fluxadjust::Real=1.03,
                            fluxadjust_bothways::Bool=true,
                            feedback::Bool=true) where {T<:AbstractFloat}

    sort!(X)
    ndata = length(X)

    # initialise a JenksResult struct
    JR = JenksResult(n,X,errornorm=errornorm,maxiter=maxiter,flux=flux)
    JR.ndata = ndata

    # Initialisation
    breaks = JR.breaks                      # breaks is a view on the data in JR.breaks
    breaks[:] = BreaksInit(n,X)             # lower bounds of every class as index of X
    SDAM = SqDeviation(X)                   # squared deviation from array mean (this is constant)
    DEVs = Array{Float64,1}(undef,n)        # Deviations from class centre for each class (lin/sq)
    DEVs_pre = Array{Float64,1}(undef,n)    # Deviations from previous iteration

    # Rename deviation function (linear vs squared)
    if errornorm == 1
        Deviation = LinDeviation
    elseif errornorm == 2
        Deviation = SqDeviation
    else
        throw(error("Errornorm '$errornorm' not defined."))
    end

    if errornorm == 1
        JR.AREhistory[1] = ARE(X,breaks)
    else
        JR.GVFhistory[1] = GVF(X,breaks)
    end

    # automatic flux adjustment
    fluxes = JR.fluxes

    t0 = time()
    for iter in 1:maxiter

        DEVs_pre .= DEVs

        # Get the lin/squared deviations for all classes
        for iclass in 1:n
            DEVs[iclass] = Deviation(ClassValues(X,breaks,iclass))
        end

        # shift class bounds
        for iclass in 1:n-1

            a,b,c = breaks[iclass:iclass+2]         # for class sizes

            # compare deviations between two adjacent classes
            if DEVs[iclass] < DEVs[iclass+1]

                # adjust fluxes based on history
                if iter > 1
                    if DEVs_pre[iclass] >= DEVs_pre[iclass+1]    # flux was previously in opposite direction
                        fluxes[iclass] /= fluxadjust             # decrease flux
                    elseif fluxadjust_bothways                          # flux was previously in same direction
                        fluxes[iclass] *= fluxadjust             # increase flux
                    end
                end

                # class size factor: Bigger classes give away more data points
                # shift data points to the class with smaller DEV
                cs_factor = Int(round((b-a)*fluxes[iclass]))
                newbreak = breaks[iclass+1]+cs_factor
                breaks[iclass+1] = min(newbreak,breaks[iclass+2]-2)
            else

                # adjust fluxes based on history
                if iter > 1
                    if DEVs_pre[iclass] <= DEVs_pre[iclass+1]    # flux was previously in opposite direction
                        fluxes[iclass] /= fluxadjust
                    elseif fluxadjust_bothways
                        fluxes[iclass] *= fluxadjust
                    end
                end

                cs_factor = Int(round((c-b)*fluxes[iclass]))
                newbreak = breaks[iclass+1]-cs_factor
                breaks[iclass+1] = max(newbreak,breaks[iclass]+2)
            end
        end

        # calculate global errors and store them
        if errornorm == 1
            AREnow = sum(DEVs)/ndata
            JR.AREhistory[iter+1] = AREnow
        else
            GVFnow = 1-sum(DEVs)/SDAM
            JR.GVFhistory[iter+1] = GVFnow
        end

        # provide average rounding error / goodness of variance feedback
        if feedback
            percent = Int(round(iter/maxiter*100))

            if errornorm == 1
                AREstring = @sprintf "%.8f" AREnow
                print("\r\u1b[K")
                print("$percent%: ARE=$AREstring")
            else
                GVFstring = @sprintf "%.8f" GVFnow
                print("\r\u1b[K")
                print("$percent%: GVF=$GVFstring")
            end
        end
    end
    JR.dt = time() - t0
    feedback ? println(@sprintf ", finished in %.2fs." JR.dt) : nothing

    # Store both errornorms in JR struct
    if errornorm == 1
        JR.ARE = sum(DEVs)/ndata
        JR.GVF = GVF(X,breaks)
    else
        JR.GVF = 1-sum(DEVs)/SDAM
        JR.ARE = ARE(X,breaks)
    end

    # convert breaks to centres and class sizes
    Breaks2Centres!(JR,X)
    Breaks2ClassSize!(JR)
    Breaks2Bounds!(JR,X)

    return JR
end

"""Returns the data point values for a given class i, provided the data X and
the breaks. Assumes the data array X to be sorted."""
function ClassValues(X::Array{T,1},breaks::Array{Int,1},i::Int) where {T<:AbstractFloat}
    return X[breaks[i]:breaks[i+1]-1]
end
