module TableWidgets

using InteractBase, Widgets, CSSUtil, Observables, WebIO
using Tables
import Observables: AbstractObservable, @map, @map!, @on
import Widgets: AbstractWidget, components

import InteractBulma
using DataStructures
import DataStructures: reset!

using MacroTools

export categoricalselector, rangeselector, selector
export dataeditor, addfilter

include("utils.jl")
include("selector.jl")
include("table.jl")
include("edit.jl")
include("filter.jl")

end # module
