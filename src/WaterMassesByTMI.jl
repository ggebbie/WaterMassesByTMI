module WaterMassesByTMI

using DrWatson, Interpolations, TMI, NCDatasets

export watermassdiags_at_locs, watermasslist, watermasssymbols, versionlist
export tracerlist, cubemask, maskcoords, calcite_oxygen_isotope_ratio

""" 
    function watermassdiags_at_locs(params)

    A suite of water-mass diagnostics at the coresites
"""
function watermassdiags_at_locs(TMIversion,Alu,γ,TMIfile,B)

    # configure TMI version
    #@unpack TMIversion, cores = params
    #A, Alu, γ, TMIfile, L, B = config_from_nc(TMIversion)

    println(TMIversion)
    nr = nrow(df)

    locs = Vector{Tuple{Float64,Float64,Float64}}(undef,nr)
    for ii in 1:nr
        locs[ii] = (df[:,:Longitude][ii],df[:,:Latitude][ii],df[:,:Depth][ii])
    end

    # set up fixed diagnostic parameters
    watermassnames = watermasslist("new")
    #watermassnames = watermasslist()
    nl = length(watermassnames)

    if !isnothing(B)
        aname = "Mean Age [yr]"
        # combine two steps and eliminate local variable
        output = Dict(aname => observe(meanage(TMIversion,Alu,γ),locs,γ))
    else
        output = Dict{String,Any}()
    end
    
    wmunits = " [% by mass]"

    #get sp and θ, some TMI files don't have this variable, so we need to try/catch
    try
        Sp = readfield(TMIfile, "Sp", γ) #practical sal.
        θ = readfield(TMIfile, "θ", γ) #potential temp

        for wm in watermassnames
            # do numerical analysis
            #g =  watermassdistribution(TMIversion,Alu,wm,γ)
            #output = observe(a,loc,γ)

            # put three lines together. not sure it helps much. (less readable).
            push!(output, wm*wmunits =>
                100*observe(OPT2k.watermassdistribution(TMIversion,Alu,wm,γ,Sp,θ),locs,γ))
            
        end

        # find all of the tracers in the TMI version, observe them at core locations.
        clist = tracerlist(TMIfile)
        fieldunits = TMI.fieldsatts()

        for c in clist
            cunits = " ["*fieldunits[c]["units"]*"]"
            push!(output,c*cunits =>
                observe(readfield(TMIfile,c,γ),locs,γ))
        end

        ## CHANGE NAME HERE TO MATCH INPUT FILE
        fn = datadir(savename("EN539",params,"csv"))
        println("output file name ",fn)
        
        # write output
        ## CHANGE TO XLSX FORMAT
        CSV.write(fn,hcat(cores,DataFrame(output)))
        println("write CSV")
        
        merge!(params,output)

        # concatenate two Dicts to save to jld2.
        # save filename up to suffix XXXXXX
        @tagsave(datadir(savename(filename,params,"jld2")), params)
        println("write jld2")
        
    catch e
        println("This TMI file does not have Sp or θ info")
    end
    
    return nothing
end



# Delia requested IRM and NEATL regions as well.

"""
    function watermasslist()

    Return list of possible TMI watermasses
"""
watermasslist() =  ("GLOBAL","ANT","SUBANT",
            "NATL","NPAC","TROP","ARC",
            "MED","ROSS","WED","LAB","GIN",
            "ADEL","SUBANTATL","SUBANTPAC","SUBANTIND",
                    "TROPATL","TROPPAC","TROPIND",
                    "IRM","NEATL", "LIS")


"""
    function watermasslist()

    Return list of possible TMI watermasses
"""
function watermasslist(version)
    #has NEATL and IRM, no LIS
    if version == "old"
        return ("GLOBAL","ANT","SUBANT",
            "NATL","NPAC","TROP","ARC",
            "MED","ROSS","WED","LAB","GIN",
            "ADEL","SUBANTATL","SUBANTPAC","SUBANTIND",
                    "TROPATL","TROPPAC","TROPIND",
                "IRM","NEATL")
    #has NEATL and LIS, no IRM
    elseif version == "new"
        return ("GLOBAL","ANT","SUBANT",
            "NATL","NPAC","TROP","ARC",
            "MED","ROSS","WED","LAB","GIN",
            "ADEL","SUBANTATL","SUBANTPAC","SUBANTIND",
                    "TROPATL","TROPPAC","TROPIND",
                "NEATL", "LIS")
    end
end

"""
    function watermassymbols()

    Return watermasslist as symbols
"""
watermasssymbols() =  (:GLOBAL,:ANT,:SUBANT,
            :NATL,:NPAC,:TROP,:ARC,
            :MED,:ROSS,:WED,:LAB,:GIN,
            :ADEL,:SUBANTATL,:SUBANTPAC,:SUBANTIND,
                       :TROPATL,:TROPPAC,:TROPIND,
                       :IRM,:NEATL, :LIS)

"""
    function versionlist()

    Return list of possible TMI versions 
"""
versionlist() = ["modern_90x45x33_GH10_GH12",
                 "modern_180x90x33_GH11_GH12",
                 "modern_90x45x33_unpub12",
                 "modern_90x45x33_G14",
                 "modern_90x45x33_G14_v2",
                 "LGM_90x45x33_G14",
                 #"LGM_90x45x33_G14A",
                 "LGM_90x45x33_GPLS1",
                 "LGM_90x45x33_GPLS2",
                 "LGM_90x45x33_OG18"]
"""
    function tracerlist()

    Return list of tracers 
"""
function tracerlist(TMIfile)
    nc = NCDataset(TMIfile)
    list = Vector{String}(undef,0)
    for (k,v) in nc
        if startswith(k,"σ")
            # σ is 2-units
            push!(list,k[3:end])
        end
    end
    return list            
end

function cubemask(lons,lats,depths,γ)
    
    # ternary operator to handle longitudinal wraparound
    lons[1] ≤ 0 ? lons[1] += 360 : nothing
    lons[2] ≤ 0 ? lons[2] += 360 : nothing

    # preallocate
    #mask = copy(γ.wet)
    mask = γ.wet #trues(size(γ.wet))

    # proceed on dimension by dimension basis.
    for j in eachindex(γ.lat)
        if !(lats[1] ≤ γ.lat[j] ≤ lats[2])
            mask[:,j,:] .= false
        end
    end
    for i in eachindex(γ.lon)
        if !(lons[1] ≤ γ.lon[i] ≤ lons[2])
            mask[i,:,:] .= false
        end
    end
    for k in eachindex(γ.depth)
        if !(depths[1] ≤ γ.depth[k] ≤ depths[2])
            mask[:,:,k] .= false
        end
    end
    return mask

end

function maskcoords(mask,γ)

    ci = findall(mask)
    coords = Vector{Tuple{Int,Int,Int}}(undef,length(ci))
    [coords[i] = (γ.lon[ci[i][1]],γ.lat[ci[i][2]],γ.depth[ci[i][3]]) for i in eachindex(ci)]
    #[latlist[i] = ci[i][2] for i in eachindex(ci)]
    
end

function calcite_oxygen_isotope_ratio(θ::Field,d18Ow::Field; alg=:marchitto2014)
    if alg== :marchitto2014
        offset = 3.26*ones(θ.γ)
        return d18Ow - 0.224*θ + offset # bemis equation 1.
    elseif alg==:bemis
        offset = 3.16*ones(θ.γ)
        return d18Ow - 0.21*θ + offset # bemis equat
    end
end

end
