module TableWidgets

using InteractBase, InteractBulma, Widgets, CSSUtil, Observables, JuliaDBMeta, IndexedTables, WebIO
using FileIO, IterableTables
using Compat
using DataStructures
import DataStructures: reset!

using MacroTools

export categoricalselector, rangeselector, selector

# hack before rdeits PR is merged in webio
node(args...; kwargs...) = Node(args...; kwargs...)
node(s::AbstractString, args...; kwargs...) = node(Symbol(s), args...; kwargs...)

include("utils.jl")
include("selector.jl")
include("table.jl")
include("edit.jl")
include("input.jl")
include("finance.jl")
include("filter.jl")

end # module
