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

TMIversion = "modern_180x90x33_GH11_GH12"

# even needed
A, Alu, γ, TMIfile, L, B = config_from_nc(TMIversion,compute_lu = false);

# extract in region of interest
# 55N-70N, 50W – 5W
lons = [-50,-5]
lats = [55, 70]
depths = [-5,6000] # all depths

mask = cubemask(lons,lats,depths,γ)
clist = tracerlist(TMIfile)
coords = maskcoords(mask,γ)
lonlist = [coords[i][1] for i in eachindex(coords)]
latlist = [coords[i][2] for i in eachindex(coords)]
depthlist = [coords[i][3] for i in eachindex(coords)]

for c in clist
    val = readfield(TMIfile,c,γ)

    # tracer values
    cvals = val.tracer[mask]
    # print to CSV

    col1 = c
    col2 = "longitude [°E]"
    col3 = "latitude [°N]"
    col4 = "depth [m]"
    
    dict = Dict(col1 => cvals, col2 => lonlist, col3 => latlist, col4 => depthlist)
    df = DataFrame(dict)
    output = datadir("Regional_"*c*"_"*TMIversion*".csv")
    CSV.write(output, df)
end

# Next do δ¹⁸Oc

# Need a paleo-temperature equation

θ = readfield(TMIfile,"θ",γ)
δ¹⁸Ow = readfield(TMIfile,"δ¹⁸Ow",γ)
δ¹⁸Oc = calcite_oxygen_isotope_ratio(θ,δ¹⁸Ow,alg=:marchitto2014)

val = δ¹⁸Oc
c = "δ¹⁸Oc"
# tracer values
cvals = val.tracer[mask]
# print to CSV

col1 = c
col2 = "longitude [°E]"
col3 = "latitude [°N]"
col4 = "depth [m]"

dict = Dict(col1 => cvals, col2 => lonlist, col3 => latlist, col4 => depthlist)
df = DataFrame(dict)
output = datadir("Regional_"*c*"_"*TMIversion*"_Marchitto2014.csv")
CSV.write(output, df)
