module TableWidgets

using InteractBase, Widgets, CSSUtil, Observables, WebIO
import Observables: AbstractObservable
import Widgets: AbstractWidget
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
# include("table.jl")
include("edit.jl")
# include("filter.jl")

end # module
