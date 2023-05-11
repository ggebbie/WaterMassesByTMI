# WaterMassesByTMI

This code base is using the [Julia Language](https://julialang.org/) and
[DrWatson](https://juliadynamics.github.io/DrWatson.jl/stable/)
to make a reproducible scientific project named
> WaterMassesByTMI

It is authored by G Jake Gebbie.

## Steps to run the code

0. Download this code base using git. Notice that raw data are typically not included in the git-history and may need to be downloaded independently.
```sh
git clone https://github.com/ggebbie/WaterMassesByTMI
```

1. Download Julia. For MacOSX and Linux, I recommend using `juliaup`.

```sh
curl -fsSL https://install.julialang.org | sh
juliaup add 1.9.0
juliaup default 1.9.0
```

2. Open the REPL, e.g.:
- Use a terminal and type `julia`
- Use VirtualStudio Code and the julia extension.
- Use `julia-repl` or `julia-snail` packages in Emacs.

3. (First time only): Install DrWatson.jl in your default (i.e., "v1.9") environment:
```julia
import Pkg; Pkg.add("DrWatson.jl")
```

4. (First time only:) Set up the WaterMassesByTMI environment.
```julia
cd("WaterMassesByTMI") # modify this to navigate to the directory containing this project
Pkg.activate(".")
Pkg.instantiate()
```

This will install all necessary packages for you to be able to run the
scripts and everything should work out of the box, including correctly
finding local paths.

5. Make any necessary changes to the configuration file at `WaterMassesByTMI/scripts/config_watermasses.jl`.
Here you can specify the input file name and the TMI version.

6. Put a data file (CSV format) into the data directory at `WaterMassesByTMI/data`.

7. Run it.

## More information

You may notice that most scripts start with the commands:
```julia
using DrWatson
@quickactivate "WaterMassesByTMI"
```
which auto-activate the project and enable local path handling from DrWatson.
