@widget wdg function categoricalselector(v::AbstractArray, f=filter; values=unique(v), value=values, kwargs...)
    :checkboxes = checkboxes(values; value=value, kwargs...)
    :function = t -> t in :checkboxes[]
    @output! wdg ($(:checkboxes); f(:function, v))
    @layout! wdg :checkboxes
end

@widget wdg function rangeselector(v::AbstractArray{<:Real}, f=filter; digits=6, vskip=1em, min=minimum(v), max=maximum(v), n=50, kwargs...)
    min = floor(min, digits)
    max = ceil(max, digits)
    step = signif((max-min)/n, digits)
    range = min:step:(max+step)
    :extrema = InteractBase.rangepicker(range; kwargs...)
    :changes = (:extrema, :changes)
    :function = t -> ((min, max) = :extrema[]; min <= t <= max)
    @output! wdg ($(:changes); f(:function, v))
    @layout! wdg :extrema
end

@widget wdg function selector(v::AbstractArray, f=filter; kwargs...)
    :textbox = textbox("insert condition")
    func = Observable{Function}(x -> true)
    on(x -> update_function!(func, x, parse=parsepredicate), observe(wdg[:textbox]))
    :function = func
    @output! wdg ($(:textbox, :changes); f(:function[], v))
    @layout! wdg :textbox
end

for s in [:categoricalselector, :rangeselector, :selector]
    @eval begin
        function $s(t::IndexedTables.AbstractIndexedTable, c::Symbol, args...; kwargs...)
            wdg = Widget{$(Widgets.quotenode(s))}()
            wdg[:widget] = $s(column(t, c), args...; kwargs...)
            wdg[:label] = string(c)
            @output! wdg :widget
            @layout! wdg Widgets.div(:label, :widget)
            return wdg
        end
    end
end

function parsepredicate(s)
    ismatch(r"^(\s)*$", s) && return :(t -> true)
    expr = parse("_ -> " * s)
    sym = gensym()
    flag = Ref(false)
    expr = MacroTools.postwalk(x -> x == :(_) ? (flag[] = true; sym) : x, parse(s))
    flag[] ? Expr(:->, sym, expr) : expr
end
