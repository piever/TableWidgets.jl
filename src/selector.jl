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
    :minimum = spinbox(range, kwargs...)
    :maximum = spinbox(range, value=range[end], kwargs...)
    :function = t -> :minimum[] <= t <= :maximum[]
    @output! wdg ($(:minimum, :changes); $(:maximum, :changes); f(:function, v))
    @layout! wdg vbox(
        :minimum,
        "miminum",
        CSSUtil.vskip(vskip),
        :maximum,
        "maxinum",
    )
end

@widget wdg function selector(v::AbstractArray, f=filter; kwargs...)
    :textbox = textbox("insert condition")
    func = Observable{Function}(x -> true)
    on(x -> update_function!(func, x), observe(wdg[:textbox]), parse=parsepredicate)
    :function = func
    @output! wdg ($(:textbox, :changes); f(:function[], v))
    @layout! wdg :textbox
end

function parsepredicate(s)
    ismatch(r"^(\s)*$", s) && return :(t -> true)
    expr = parse("_ -> " * s)
    sym = gensym()
    flag = Ref(false)
    expr = MacroTools.postwalk(x -> x == :(_) ? (flag[] = true; sym) : x, parse(s))
    flag[] ? Expr(:->, sym, expr) : expr
end
