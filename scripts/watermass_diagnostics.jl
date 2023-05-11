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

include(scriptsdir("config_watermass_diagnostics.jl"))

A, Alu, γ, TMIfile, L, B = config_from_nc(TMIversion)

# read input Excel file into DataFrame
df = DataFrame(XLSX.readtable(datadir(filename),1))

# Several parameter containers
params = @strdict TMIversion cores
dicts = dict_list(params)

watermassdiags_at_locs(TMIversion,Alu,γ,TMIfile,B)

map(watermassdiags_at_locs,dicts)

