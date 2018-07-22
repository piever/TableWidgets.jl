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
