module TableWidgets

using InteractBase, Widgets, CSSUtil, Observables, IndexedTables, WebIO

using MacroTools

export categoricalselector, rangeselector, selector

include("selector.jl")
include("edit.jl")

end # module
