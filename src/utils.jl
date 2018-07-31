_onany(f, o::Observable) = InteractBase.on(f, o)
_onany(f, o) = InteractBase.onany(f, o...)

function parsetext!(wdg::Widgets.AbstractWidget, name = "function"; text = observe(wdg), on = text, parse = Base.parse, default = (args...) -> nothing)
    f = default
    try
        @eval f = $(parse(text[]))
    catch
    end
    name = Symbol(name)
    wdg[name] = Observable{Any}(f)
    _onany(on) do s...
        update_function!(wdg[name], text[]; parse = parse)
    end
    wdg
end

function update_function!(func::Observable, s; parse = Base.parse)
    try
        @eval f = $(parse(s))
        func[] = f
    catch
    end
end

function _pipeline(s, arg="")
    """
    JuliaDBMeta.@apply $arg begin
        $s
    end
    """
end

parsepipeline(s; flatten = false) = parse(_pipeline(s))
parsepipeline(s, ::Nothing; kwargs...) = parsepipeline(s; kwargs...)

function parsepipeline(s, by; flatten = false)
    by_sym = gensym(:by)
    arg = "$by_sym flatten = $flatten"
    Expr(:block, Expr(:(=), by_sym, by), parsepipeline(s, arg))
end

"""
`Undo(obs::Observable{T}, stack = T[obs[]]; stacksize = 10) where {T}`

Return a `Undo` object that stores up to `stacksize` past occurences of `Observable` `obs` in `Vector` `stack`.
(::Undo)() sets the observable `obs` back to its previous state as far as memory permits.
"""
struct Undo{T, F}
    obs::Observable{T}
    stack::Vector{T}
    stacksize::Int
    exclude::F

    function Undo(obs::Observable{T}, stack = T[obs[]]; stacksize = 10) where {T}
        exclude = on(obs) do val
            push!(stack, val)
            length(stack) > stacksize && popfirst!(stack)
        end
        new{T, typeof(exclude)}(obs, stack, stacksize, exclude)
    end
end

Widgets.observe(u::Undo) = u.obs

(u::Undo)() = undo!(u.obs, u.stack, u.exclude)

function undo!(obs::Observable, stack, exclude)
    pop!(stack)
    isempty(stack) && error("Stack is finished, cannot undo any more")
    Observables.setexcludinghandlers(obs, last(stack), t -> t != exclude)
    obs
end

"""
apme sa
"""
@widget function Widgets.widget(s::Complex)
    11
end
