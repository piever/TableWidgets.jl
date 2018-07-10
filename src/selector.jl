@widget wdg function categoricalselector(v::AbstractArray, f=filter; kwargs...)
    :checkboxes = checkboxes(unique(v); kwargs...)
    :function = t -> t in $(:checkboxes)
    @output! wdg f($(:function), v)
    @layout! wdg :checkboxes
end

@widget wdg function selector(v::AbstractArray, f=filter; kwargs...)
    :textbox = textbox("insert condition")
    func = Observable{Function}(x -> true)
    on(x -> update_function!(func, x), observe(wdg[:textbox]))
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

function update_function!(func::Observable{<:Function}, s)
    try
        @eval f = $(parsepredicate(s))
        func[] = f
    end
end
