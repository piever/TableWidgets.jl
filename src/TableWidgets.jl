module TableWidgets

using InteractBase, Widgets, CSSUtil, Observables, IndexedTables, WebIO

import Widgets: node

using MacroTools

export categoricalselector, rangeselector, selector

include("selector.jl")
include("edit.jl")
include("table.jl")

end # module
