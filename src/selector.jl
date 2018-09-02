"""
`categoricalselector(v::AbstractArray, f=filter)`

Create as many checkboxes as the unique elements of `v` and use them to select `v`. By default it returns
a filtered version of `v`: use `categoricalselector(v, map)` to get the boolean vector of whether each element is
selected
"""
function categoricalselector(v::AbstractArray, f=filter; values=unique(v), value=values, kwargs...)
    data = OrderedDict{Symbol, Any}(
        :checkboxes => checkboxes(values; value=value, kwargs...),
    )
    data[:function] = t -> t in data[:checkboxes][]
    wdg = Widget{:categoricalselector}(data, output = map(x -> f(data[:function], v), data[:checkboxes]))
    @layout! wdg :checkboxes
end

# """
# `rangeselector(v::AbstractArray, f=filter)`
#
# Create a `rangepicker` as wide as the extrema of `v` and uses to select `v`. By default it returns
# a filtered version of `v`: use `rangeselector(v, map)` to get the boolean vector of whether each element is
# selected
# """
# function rangeselector(v::AbstractArray{<:Real}, f=filter; digits=6, vskip=1em, min=minimum(v), max=maximum(v), n=50, kwargs...)
#     min = floor(min, digits)
#     max = ceil(max, digits)
#     step = signif((max-min)/n, digits)
#     range = min:step:(max+step)
#     :extrema = InteractBase.rangepicker(range; kwargs...)
#     :changes = (:extrema, :changes)
#     :function = t -> ((min, max) = :extrema[]; min <= t <= max)
#     @output! wdg ($(:changes); f(:function, v))
#     @layout! wdg :extrema
# end
#
# """
# `selector(v::AbstractArray, f=filter)`
#
# Create a `textbox` where the user can type in an anonymous function that is used to select `v`. `_` can be used
# to denote the funcion argument, e.g. `_ > 0`. By default it returns
# a filtered version of `v`: use `selector(v, map)` to get the boolean vector of whether each element is
# selected
# """
# function selector(v::AbstractArray, f=filter; kwargs...)
#     :textbox = textbox("insert condition")
#     func = Observable{Function}(x -> true)
#     on(x -> update_function!(func, x, parse=parsepredicate), observe(wdg[:textbox]))
#     :function = func
#     @output! wdg ($(:textbox, :changes); f(:function[], v))
#     @layout! wdg :textbox
# end

# for s in [:categoricalselector, :rangeselector, :selector]
#     @eval begin
#         function $s(t::IndexedTables.AbstractIndexedTable, c::Symbol, args...; kwargs...)
#             wdg = Widget{$(Widgets.quotenode(s))}()
#             wdg[:widget] = $s(column(t, c), args...; kwargs...)
#             wdg[:label] = string(c)
#             @output! wdg :widget
#             @layout! wdg Widgets.div(:label, :widget)
#             return wdg
#         end
#     end
# end

function parsepredicate(s)
    ismatch(r"^(\s)*$", s) && return :(t -> true)
    expr = parse("_ -> " * s)
    sym = gensym()
    flag = Ref(false)
    expr = MacroTools.postwalk(x -> x == :(_) ? (flag[] = true; sym) : x, parse(s))
    flag[] ? Expr(:->, sym, expr) : expr
end
