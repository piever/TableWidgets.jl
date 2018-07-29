function parsetext!(wdg::Widgets.AbstractWidget, name = "function"; text = observe(wdg), on = text, parse = Base.parse, default = (args...) -> nothing)
    f = default
    try
        @eval f = $(parse(text[]))
    catch
    end
    name = Symbol(name)
    wdg[name] = Observable{Any}(f)
    InteractBase.on(on) do s
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

function parsepipeline(s)
    pipeline = """
    JuliaDBMeta.@apply begin
        $s
    end
    """
    parse(pipeline)
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
