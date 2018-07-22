function parsetext!(wdg::Widgets.AbstractWidget, name = "function"; text = observe(wdg), parse = Base.parse, default = (args...) -> nothing)
    f = default
    try
        @eval f = $(parse(text[]))
    catch
    end
    name = Symbol(name)
    wdg[name] = Observable{Any}(f)
    on(text) do s
        update_function!(wdg[name], s; parse = parse)
    end
    wdg
end

function update_function!(func::Observable, s; parse = Base.parse)
    try
        @eval f = $(parse(s))
        func[] = f
    end
end
