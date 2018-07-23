module TableWidgets

using InteractBase, InteractBulma, Widgets, CSSUtil, Observables, IndexedTables, WebIO
using Compat
import Widgets: node
import DataStructures: reset!

using MacroTools

export categoricalselector, rangeselector, selector

include("utils.jl")
include("selector.jl")
include("table.jl")
include("edit.jl")

end # module
