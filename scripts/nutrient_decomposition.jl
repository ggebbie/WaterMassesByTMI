#=
% Diagnose water-mass properties at core sites,
including the mean or ideal age and water-mass fractions.
=#

# activate environment with DrWatson
# activate the local project
include("intro.jl")

using Revise
using TMI
using DrWatson
using WaterMassesByTMI

include(scriptsdir("config_nutrient_decomposition.jl"))

A, Alu, γ, TMIfile, L, B = config_from_nc(TMIversion);

PO₄ᴿ = regeneratedphosphate(TMIversion,Alu,γ)
PO₄★ = preformedphosphate(TMIversion,Alu,γ)

NO₃ᴿ = regeneratednitrate(TMIversion,Alu,γ)
NO₃★ = preformednitrate(TMIversion,Alu,γ)

O₂ᴿ = respiredoxygen(TMIversion,Alu,γ)
O₂★ = preformedoxygen(TMIversion,Alu,γ)

filename = datadir("nutrient_decomposition_"*TMIversion*".nc")

# rewrite as broadcast vector
isfile(filename) && rm(filename)
writefield(filename,PO₄ᴿ)
writefield(filename,PO₄★)
writefield(filename,NO₃ᴿ)
writefield(filename,NO₃★)
writefield(filename,O₂ᴿ)
writefield(filename,O₂★)

