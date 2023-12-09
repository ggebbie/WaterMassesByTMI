#=
 Find the global distribution of a "water mass" defined by an oceanographically-relevant surface region.
 Steps: (a) define the water mass 1). by a pre-defined surface
            dyed with passive tracer concentration of 1,
        (b) propagate the dye with the matrix A, with the result
            being the fraction of water originating from the
            surface region.
 See Section 2b of Gebbie & Huybers 2010, esp. eqs. (15)-(17).
=#

# activate the local project
include("intro.jl")

using Revise
using TMI
using WaterMassesByTMI
using DrWatson

#using Test
#using GGplot

for TMIversion in versionlist()

    A, Alu, γ, TMIfile, L, B = config_from_nc(TMIversion)
    watermassfilename = datadir("WaterMassDistributions_"*TMIversion*".nc")

    for region in TMI.regionlist()
        # do numerical analysis
        g = watermassdistribution(TMIversion,Alu,region,γ);
        TMI.writefield(watermassfilename,g)
        println(region)
    end
end
