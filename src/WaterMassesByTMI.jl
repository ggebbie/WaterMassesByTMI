module WaterMassesByTMI

using DrWatson, Interpolations, TMI, DataFrames, NCDatasets, XLSX, CSV

export watermassdiags_at_locs, watermasslist, watermasssymbols, versionlist
export tracerlist, cubemask, maskcoords, calcite_oxygen_isotope_ratio
export watermassdiags_at_locs, watermasslist, watermasssymbols, versionlist
export read_locs
export watermassdistribution, tracerlist

""" 
    function watermassdiags_at_locs(params)

    A suite of water-mass diagnostics at the coresites
"""
function watermassdiags_at_locs(TMIversion,filename;output_filetype="xlsx")

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
            100*observe(TMI.watermassdistribution(TMIversion,Alu,wm,γ),locs,γ))
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

    fn = datadir(replace(filename,".xlsx" => "")*"_"*TMIversion*"."*output_filetype)
    #println("output file name ",fn)
    
    # write output

    ## make a backup of existing data (DrWatson can increment all backups, should use that instead)
    isfile(fn) && mv(fn,fn*"1",force=true)

    # outerjoin with `on` column is probably better
    #outerjoin(df,DataFrame(output))
    df = hcat(df,DataFrame(output))
    
    # DataFrame too wide to look ok in standard output
    #df_final = hcat(df,DataFrame(output))
    #println("Data Frame of results")
    #println(df)

    if output_filetype == "xlsx"
        #XLSX.writetable(fn,hcat(df,DataFrame(output)))
        XLSX.writetable(fn,df)
        println("write XLSX output at ",fn)
    elseif output_filetype == "csv"
        CSV.write(fn,df)
        println("write CSV output at ",fn)
    end
        
    # concatenate two Dicts to save to jld2.
    #fnjld = datadir(filename[1:end-5]*"_"*TMIversion*".jld2")
    fnjld = replace(fn,output_filetype => "jld2")

    #datadir(replace(filename,"."*output_filetype => "")*"_"*TMIversion*"."*output_filetype)
    @tagsave(fnjld, output)
    println("write jld2: Native Julia format at ",fnjld)
    
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
        d18Oc = d18Ow - 0.224*θ + offset # bemis equation 1.
    elseif alg==:bemis
        offset = 3.16*ones(θ.γ)
        d18Oc = d18Ow - 0.21*θ + offset # bemis equat
    end
    return Field(d18Oc.tracer,d18Oc.γ,:δ¹⁸Oc,"oxygen-18 to oxygen-16 ratio in calcite","‰ VPDB")
end

end
