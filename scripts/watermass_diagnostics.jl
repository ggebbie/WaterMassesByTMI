#=
% Diagnose water-mass properties at core sites,
including the mean or ideal age and water-mass fractions.
=#

# activate environment with DrWatson
# activate the local project
include("intro.jl")

using Revise
using TMI
using DataFrames
using DrWatson
using XLSX

include(scriptsdir("config_watermass_diagnostics.jl"))


# Several parameter containers
#params = @strdict TMIversion cores
#dicts = dict_list(params)

#map(watermassdiags_at_locs,dicts)

watermassdiags_at_locs(TMIversion)
