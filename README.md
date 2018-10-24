# TableWidgets

[![Build Status](https://travis-ci.org/piever/TableWidgets.jl.svg?branch=master)](https://travis-ci.org/piever/TableWidgets.jl)
[![](https://img.shields.io/badge/docs-latest-blue.svg)](https://piever.github.io/TableWidgets.jl/latest/)
[![codecov.io](http://codecov.io/github/piever/TableWidgets.jl/coverage.svg?branch=master)](http://codecov.io/github/piever/TableWidgets.jl?branch=master)

This package contains a few basic widgets to build GUIs to work with tabular data as well as examples of such GUIs.

## Examples

To run the examples, you need to activate the respective folder and instantiate it to get all dependencies.

```julia
import Pkg
import TableWidgets: examplefolder
Pkg.activate(joinpath(examplefolder, "explorer"))
Pkg.instantiate()
include(joinpath(examplefolder, "explorer", "sputnik.jl"))
```
