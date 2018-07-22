using NamedTuples


@widget wdg function tablerow(i, row; string = true)
    tostring = string ? Base.string : identity
	ns = fieldnames(row)
    for el in ns
        wdg[el] = getfield(row, el)
    end

    @layout! wdg node("tr", node("td", tostring(i)), (node("td", tostring(_[el])) for el in ns)...)
end

@widget wdg function _displaytable(t; className = "is-striped is-hoverable is-fullwidth", kwargs...)

    headers = (node("th", string(el)) for el in colnames(t))

    :head = node("tr", node("th", "#"), node.("th", string.(colnames(t)))...) |> node("thead")

    for (i, line) in enumerate(t)
        wdg["row$i"] = tablerow(i, line; kwargs...)
    end

    :body = node("tbody", (wdg["row$i"] for i in 1:length(t))...)
    className = "table $className"
    @layout! wdg node("table", :head, :body, className=className)
end

@widget wdg function displaytable(t, lines = 1:min(10, length(Observables._val(t))); stacksize = 10, kwargs...)
    (t isa Observable) || (t = Observable{Any}(t))
    (lines isa Observable) || (lines = Observable{Any}(lines))
    :lines = lines
    :backup = copy(t[])
    :stack = Any[t[]]
    wdg[:exclude] = on(t) do val
        push!(wdg[:stack], val)
        length(wdg[:stack]) > stacksize && popfirst!(wdg[:stack])
    end

    @output! wdg t
    @display! wdg _displaytable($(_.output)[$(:lines)]; kwargs...)

    InteractBase.settheme!(Bulma())
    scp = WebIO.Scope()
    InteractBase.slap_design!(scp)
    scp.dom = node("div",  wdg.display)

    wdg.scope = scp
    @layout! wdg _.scope
    InteractBase.resettheme!()
end

function reset!(wdg::Widget{:displaytable})
    observe(wdg)[] = wdg[:backup]
    wdg
end

function undo!(wdg::Widget{:displaytable})
    pop!(wdg[:stack])
    isempty(wdg[:stack]) && error("Stack is finished, cannot undo any more")
    Observables.setexcludinghandlers(observe(wdg), last(wdg[:stack]), t -> t != wdg[:exclude])
    wdg
end

@widget wdg function manipulatetable(args...; kwargs...)
    :table = displaytable(args...; kwargs...)
    :text = textarea()
    parsetext!(wdg; text = observe(wdg, :text))
    :apply = button("Apply")
    :undo = button("Undo")
    :reset = button("Reset")
    # on(wdg[:apply]) do x
    #     observe(wdg, :table)[] = (wdg[:function][])(observe(wdg, :table)[])
    # end
    @on wdg ($(:apply); :table[] = :function[](:table[]))
    @on wdg ($(:reset); reset!(wdg))
    @on wdg ($(:undo); undo!(wdg))
    @output! wdg :table
    @layout! wdg vbox(hbox(:text, :apply, :undo, :reset), :table)
end
