using DrWatson
@quickactivate "WaterMassesByTMI"

# Here you may include files from the source directory
#include(srcdir("dummy_src_file.jl"))

println(
"""
Currently active project is: $(projectname())

Path of active project: $(projectdir())

Have fun computing water mass diagnostics with TMI.
"""
)
