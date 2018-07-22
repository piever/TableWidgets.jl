module TableWidgets

using InteractBase, InteractBulma, Widgets, CSSUtil, Observables, IndexedTables, WebIO

import Widgets: node

using MacroTools

export categoricalselector, rangeselector, selector

include("utils.jl")
include("selector.jl")
include("edit.jl")
include("table.jl")

end # module
