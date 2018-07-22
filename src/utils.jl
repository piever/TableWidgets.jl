function parsetext!(wdg::Widgets.AbstractWidget, name = "function"; parse = Base.parse, default = (args...) -> nothing)
    f = default
    try
        @eval f = parse(observe(wdg)[])
    catch
    end
    name = Symbol(name)
    wdg[name] = Observable{Any}(f)
    on(observe(wdg)) do s
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
