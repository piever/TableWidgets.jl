module TableWidgets

using InteractBase, Widgets, CSSUtil, Observables, WebIO
using Tables
import Observables: AbstractObservable, @map
import Widgets: AbstractWidget, components
# using JuliaDBMeta, IndexedTables
# import IndexedTables: AbstractIndexedTable
import InteractBulma
using Compat
using DataStructures
import DataStructures: reset!

using MacroTools

export categoricalselector, rangeselector, selector

include("utils.jl")
include("selector.jl")
include("table.jl")
include("edit.jl")
# include("filter.jl")

end # module
