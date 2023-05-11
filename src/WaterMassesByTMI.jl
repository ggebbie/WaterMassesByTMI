module WaterMassesByTMI

using DrWatson, Interpolations, TMI, DataFrames, NCDatasets

export watermassdiags_at_locs, watermasslist, watermasssymbols, versionlist, read_locs
export watermassdistribution, tracerlist

""" 
    function watermassdiags_at_locs(params)

    A suite of water-mass diagnostics at the coresites
"""
function watermassdiags_at_locs(TMIversion)

    println(TMIversion)
    A, Alu, γ, TMIfile, L, B = config_from_nc(TMIversion);

    # read input Excel file into DataFrame
    df = DataFrame(XLSX.readtable(datadir(filename),1))

    locs = read_locs(df)

    # set up fixed diagnostic parameters
    watermassnames = watermasslist()

    nl = length(watermassnames)

    if !isnothing(B)
        aname = "Mean Age [yr]"
        # combine two steps and eliminate local variable
        output = Dict(aname => observe(meanage(TMIversion,Alu,γ),locs,γ))
    else
        output = Dict{String,Any}()
    end
    
    wmunits = " [% by mass]"

    for wm in watermassnames

        # put three lines together. not sure it helps much. (less readable).
        push!(output, wm*wmunits =>
            100*observe(watermassdistribution(TMIversion,Alu,wm,γ),locs,γ))
    end

    # find all of the tracers in the TMI version, observe them at core locations.
    clist = tracerlist(TMIfile)
    fieldunits = TMI.fieldsatts()

    # name of practical salinity needs upstream update
    push!(fieldunits,"Sp" => fieldunits["Sₚ"])

    for c in clist
        cunits = " ["*fieldunits[c]["units"]*"]"
        push!(output,c*cunits =>
            observe(readfield(TMIfile,c,γ),locs,γ))
    end

    ## CHANGE NAME HERE TO MATCH INPUT FILE
    ## kludge to remove ".xlsx"
    fn = datadir(filename[1:end-5]*"_"*TMIversion*".xlsx")
    println("output file name ",fn)
    
    # write output
    ## CHANGE TO XLSX FORMAT
    isfile(fn) && mv(fn,fn*"1")
    XLSX.writetable(fn,hcat(df,DataFrame(output)))
    println("write XLSX output")
    
    # concatenate two Dicts to save to jld2.
    fnjld = datadir(filename[1:end-5]*"_"*TMIversion*".jld2")
    @tagsave(fnjld, output)
    println("write jld2: Native Julia format")
    
    return nothing
end

"""
    function read_locs(df::DataFrame)

    Read data locations from DataFrame.
"""
function read_locs(df::DataFrame)
    nr = nrow(df)
    
    locs = Vector{Tuple{Float64,Float64,Float64}}(undef,nr)
    for ii in 1:nr
        locs[ii] = (df[:,:Longitude][ii],df[:,:Latitude][ii],df[:,:Depth][ii])
    end
    return locs
end

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

"""
    function watermasslist()

    Return list of possible TMI watermasses
"""
watermasslist() =  ("GLOBAL","ANT","SUBANT",
            "NATL","NPAC","TROP","ARC",
            "MED","ROSS","WED","LAB","GIN",
            "ADEL","SUBANTATL","SUBANTPAC","SUBANTIND",
                    "TROPATL","TROPPAC","TROPIND")


"""
    function watermassymbols()

    Return watermasslist as symbols
"""
watermasssymbols() =  (:GLOBAL,:ANT,:SUBANT,
            :NATL,:NPAC,:TROP,:ARC,
            :MED,:ROSS,:WED,:LAB,:GIN,
            :ADEL,:SUBANTATL,:SUBANTPAC,:SUBANTIND,
                       :TROPATL,:TROPPAC,:TROPIND)

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

end
