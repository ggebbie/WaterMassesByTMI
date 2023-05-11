#=
% Diagnose water-mass properties at core sites,
including the mean or ideal age and water-mass fractions.
=#

# activate environment with DrWatson
# activate the local project
include("intro.jl")

using Revise
using WaterMassesByTMI

include(scriptsdir("config_watermass_diagnostics.jl"))

watermassdiags_at_locs(TMIversion,inputfile)
