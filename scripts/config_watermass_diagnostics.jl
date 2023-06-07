#=

Choose the input file and TMI version here.

Available TMI versions include:

`modern_90x45x33_GH10_GH12` : TMI version with 4x4 degree horizontal
                  resolution and 33 levels  (G & H 2010), \
				  Includes the input data from the WGHC (Gouretski & Koltermann 2005) 
 
`modern_180x90x33_GH11_GH12` : TMI version with 2x2 degree horizontal
                  resolution and 33 levels  (G & H 2011), \
				  Includes the input data from the WGHC (Gouretski & Koltermann 2005) 

`modern_90x45x33_unpub12` : TMI version with 4x4 degree horizontal
                  resolution and 33 levels  (unpublished 2012), \
				  Includes a steady-state climatology of global tracers

`modern_90x45x33_G14` : TMI version with 4x4 degree horizontal
                  resolution and 33 levels  (Gebbie 2014), \
				  Doesn't rely upon a bottom spreading parameterization and solves for mixed-layer depth

`modern_90x45x33_G14_v2` : TMI version with 4x4 degree horizontal
                  resolution and 33 levels  (Gebbie 2014), \
				  Doesn't rely upon a bottom spreading parameterization and solves for mixed-layer depth\
				  Includes optimization information
				  
`LGM_90x45x33_G14` : Last Glacial Maximum version with 4x4 degree horizontal
                  resolution and 33 levels  (Gebbie 2014)
				  
`LGM_90x45x33_G14A` : Alternate solution, Last Glacial Maximum version with 4x4 degree horizontal
                  resolution and 33 levels  (Gebbie 2014)
				  
`LGM_90x45x33_GPLS1`: Solution #1 (Gebbie, Peterson, Lisiecki, and Spero, 2015), Last Glacial Maximum version with 4x4 degree horizontal resolution and 33 levels 
				  
`LGM_90x45x33_GPLS2`: Solution #2 (Gebbie, Peterson, Lisiecki, and Spero, 2015), Last Glacial Maximum version with 4x4 degree horizontal resolution and 33 levels 
				  
`LGM_90x45x33_OG18`: Last Glacial Maximum version with 4x4 degree horizontal resolution and 33 levels (Oppo, Gebbie et al. 2018)

=#

inputfile = "Holocene_AMOC_cores.xlsx"

# Which TMI version?
# versionlist() # will give a full list

TMIversion = "modern_90x45x33_GH10_GH12"
#TMIversion = "modern_180x90x33_GH11_GH12"
