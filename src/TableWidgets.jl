module TableWidgets

using InteractBase, InteractBulma, Widgets, CSSUtil, Observables, JuliaDBMeta, IndexedTables, WebIO
using FileIO, IterableTables
using Compat
import Widgets: node
import DataStructures: reset!

using MacroTools

export categoricalselector, rangeselector, selector

include("utils.jl")
include("selector.jl")
include("table.jl")
include("edit.jl")
include("input.jl")
include("finance.jl")

end # module
