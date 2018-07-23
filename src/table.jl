using NamedTuples

function _compact(x)
    io = IOBuffer()
    showcompact(io, x)
    String(io)
end

@widget wdg function tablerow(t, i; format = _compact, editing = false, editable = false)
    editing isa Observable || (editing = Observable(editing))

    row = t[i]
	ns = fieldnames(row)
    for el in ns
        val = getfield(row, el)
        wdg[string("field_", el)] = editable ? editablefield(val; editing = editing, format = format) : format(val)
    end

    if editable
        wdg[:button] = editbutton(; editing = editing) do x
            for el in ns
                column(t, el)[i] = observe(wdg, string("field_", el))[]
            end
        end
    end

    @layout! wdg node("tr", node("td", format(i)), (node("td", child) for (key, child) in _.children)...)
end

@widget wdg function _displaytable(t; className = "is-striped is-hoverable", kwargs...)

    headers = (node("th", string(el)) for el in colnames(t))

    :head = node("tr", node("th", "#"), node.("th", string.(colnames(t)))...) |> node("thead")

    for i in 1:length(t)
        wdg["row$i"] = tablerow(t, i; kwargs...)
    end

    :body = node("tbody", (wdg["row$i"] for i in 1:length(t))...)
    className = "table $className"
    @layout! wdg Widgets.div(node("table", :head, :body, className=className), style = Dict("overflow" => "scroll"))
end

_getindex(t, lines::Colon) = t[:]
function _getindex(t, lines)
    idx = filter(i -> i in 1:length(t), lines)
    getindex(t, idx)
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
    @display! wdg _displaytable(_getindex($(_.output), $(:lines)); kwargs...)

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
    :text = textarea(placeholder = "Write transformation to apply to the table")
    parsetext!(wdg; text = observe(wdg, :text))
    :apply = button("Apply")
    :undo = button("Undo", className = "is-warning")
    :reset = button("Reset", className = "is-danger")
    @on wdg ($(:apply); :table[] = :function[](:table[]))
    @on wdg ($(:reset); reset!(wdg["table"]))
    @on wdg ($(:undo); undo!(wdg["table"]))
    @output! wdg :table
    @layout! wdg Widgets.div(:text, hbox(:apply, hskip(1em), :undo, hskip(1em), :reset), :table)
end
