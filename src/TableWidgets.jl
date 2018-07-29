module TableWidgets

using InteractBase, Widgets, CSSUtil, Observables, JuliaDBMeta, IndexedTables, WebIO
import IndexedTables: AbstractIndexedTable
import InteractBulma
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
include("filter.jl")

end # module
