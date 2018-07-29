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

function store!(obs::Observable, stack, stacksize)
    on(obs) do val
        push!(stack, val)
        length(stack) > stacksize && popfirst!(stack)
    end
end

function undo!(obs::Observable, stack, exclude)
    pop!(stack)
    isempty(stack) && error("Stack is finished, cannot undo any more")
    Observables.setexcludinghandlers(obs, last(stack), t -> t != exclude)
    wdg
end
