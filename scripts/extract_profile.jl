#=
% Diagnose water-mass properties at core sites,
including the mean or ideal age and water-mass fractions.
=#

# activate environment with DrWatson
# activate the local project
include("intro.jl")

using Revise
using TMI
using CSV
using DataFrames
using DrWatson
using WaterMassesByTMI

# `modern_90x45x33_GH10_GH12` : TMI version with 4x4 degree horizontal
#                   resolution and 33 levels  (G & H 2010), \
# 				  Includes the input data from the WGHC (Gouretski & Koltermann 2005) 
 
# `modern_180x90x33_GH11_GH12` : TMI version with 2x2 degree horizontal
#                   resolution and 33 levels  (G & H 2011), \
# 				  Includes the input data from the WGHC (Gouretski & Koltermann 2005) 

### Investigator choices #######################
# get a profile at 61.35 N, 20.35 W.
lonprofile = -20.35
latprofile = 61.35

TMIversion = "modern_180x90x33_GH11_GH12"
#################################################

# even needed
A, Alu, γ, TMIfile, L, B = config_from_nc(TMIversion,compute_lu = false);

# Need a paleo-temperature equation
θ = readfield(TMIfile,"θ",γ)
δ¹⁸Ow = readfield(TMIfile,"δ¹⁸Ow",γ)
δ¹⁸Oc = calcite_oxygen_isotope_ratio(θ,δ¹⁸Ow,alg=:marchitto2014)

locs = Vector{Tuple{Float64,Float64,Float64}}(undef,length(γ.depth))
for zz = 1:length(γ.depth)
    locs[zz] = (lonprofile,latprofile,γ.depth[zz])
end

#dict_profile = Dict{String,Vector{Float64}}()
col1 = "depth [m]"
dictprofile = Dict(col1 => γ.depth)
for c in clist
    val = readfield(TMIfile,c,γ)
    cprofile = TMI.observe(val,locs,γ)
    cheader = c*" ["*val.units*"]"
    println(cheader)
    dictprofile[cheader] = cprofile
end

# now add d18Oc
# print to CSV
newcol = "δ¹⁸Oc"*" ["*δ¹⁸Oc.units*"]"
cprofile = TMI.observe(δ¹⁸Oc,locs,γ)
dictprofile[newcol] = cprofile
    
df = DataFrame(dictprofile)
if lonprofile < 0
    output = datadir("Profile_"*string(abs(lonprofile))*"W_"*string(latprofile)*"N_"*TMIversion*".csv")
else
    output = datadir("Profile_"*string(lonprofile)*"E_"*string(latprofile)*"N_"*TMIversion*".csv")
end

CSV.write(output, df)

