using NamedTuples

isfieldeditable(s::Symbol, edit::Bool) = edit
isfieldeditable(s::Symbol, edit::Function) = edit(s)
isfieldeditable(s::Symbol, edit::AbstractArray) = s in edit
isfieldeditable(s::Symbol, edit::Symbol) = s == edit
isfieldeditable(edit) = t -> isfieldeditable(t, edit)

@widget wdg function tablerow(t, i; output = Observable(nothing), format = InteractBase.format, editing = false, edit = false, widgetfunction = (t, i, el) -> widget(column(t, el)[i]))
    editing isa Observable || (editing = Observable(editing))

    row = t[i]
	ns = fieldnames(row)
    for el in ns
        val = getfield(row, el)
        editable = isfieldeditable(el, edit)
        wdg[string("field_", el)] =
            editable ? editablefield(val, widgetfunction(t, i, el); editing = editing, format = format) : format(val)
    end

    if any(isfieldeditable(edit), fieldnames(row))
        wdg[:button] = editbutton(; editing = editing) do x
            for el in ns
                if isfieldeditable(el, edit)
                    column(t, el)[i] = observe(wdg, string("field_", el))[]
                end
            end
            output[] = output[]
        end
    end

    @layout! wdg node("tr", node("td", format(i)), (node("td", child) for (key, child) in _.children)...)
end

_displaytable(t, lines; kwargs...) = _displaytable(table(t)::AbstractIndexedTable, lines; kwargs...)

@widget wdg function _displaytable(t::AbstractIndexedTable, lines; className = "is-striped is-hoverable", kwargs...)

    headers = (node("th", string(el)) for el in colnames(t))

    :head = node("tr", node("th", "#"), node.("th", string.(colnames(t)))...) |> node("thead")

    ii = _eachindex(t, lines)
    for i in ii
        wdg["row$i"] = tablerow(t, i; kwargs...)
    end

    :body = node("tbody", (wdg["row$i"] for i in ii)...)
    className = "table $className"
    @layout! wdg Widgets.div(node("table", :head, :body, className=className), style = Dict("overflow" => "scroll"))
end

_eachindex(t, lines) = _eachindex(rows(t)::AbstractArray, lines)
_eachindex(t::AbstractArray, ::Colon) = eachindex(t)
_eachindex(t::AbstractArray, lines) = (i for i in lines if checkbounds(Bool, t, i))

"""
`displaytable(t, rows=1:10; edit = false)`

Show rows `rows` of table `t` as HTML table. Use `:` to show the whole table. Use `edit=true` to make the rows editable.
Use `reset!` to restore original table.
"""
displaytable(::Nothing, args...; kwargs...) = nothing

@widget wdg function displaytable(t, lines = 1:min(10, length(Observables._val(t))); kwargs...)
    (t isa Observable) || (t = Observable{Any}(t))
    (lines isa Observable) || (lines = Observable{Any}(lines))
    :lines = lines
    :backup = table(t[])

    @output! wdg t
    @display! wdg _displaytable($(_.output), $(:lines); output = _.output, kwargs...)

    scp = WebIO.Scope()
    InteractBase.slap_design!(scp)
    scp.dom = node("div",  wdg.display)

    wdg.scope = scp
    @layout! wdg _.scope
end

function reset!(wdg::Widget{:displaytable})
    observe(wdg)[] = wdg[:backup]
    wdg
end

"""
`toggletable(t, rows=1:10)`

Same as `displaytable` but the table can be shown or hidden with a toggle switch.
"""
@widget wdg function toggletable(args...; readout = true, label = "Show table", kwargs...)
    :table = displaytable(args...; kwargs...)
    wdg[:toggle] = togglecontent(wdg[:table], label = label, value = readout)
    @output! wdg :table
    @layout! wdg :toggle
end

"""
`dataeditor(t)`

Create a textbox to preprocess a table with JuliaDB / JuliaDBMeta: displays the result using `toggletable`.
"""
@widget wdg function dataeditor(t, args...; kwargs...)
    (t isa Observable) || (t = Observable{Any}(t))
    :input = t
    @output! wdg Observable{Any}(table(t[]))
    @display! wdg toggletable(_.output, args...; kwargs...)
    :text = textarea(placeholder = "Write transformation to apply to the table")
    :by_wdg = dropdown(map(colnames, t), placeholder = "Grouping variables", multiple = true)
    :flatten = checkbox("flatten")
    wdg[:by_toggle] = togglecontent(hbox(wdg[:by_wdg], hskip(1em), wdg[:flatten]), label = "Group data")
    :by = $(:by_toggle) ? $(:by_wdg) : nothing
    parsetext!(wdg; text = observe(wdg, :text), on = (observe(wdg, :text)), parse =parsepipeline)
    :apply = button("Apply")
    :reset = button("Reset", className = "is-danger")
    @on wdg ($(:apply); _.output[] = :by[] === nothing ? :function[](:input[]) : groupby(:function[], :input[], :by[]; flatten = :flatten[]))
    @on wdg ($(:reset); :text[] = ""; _.output[] = table(t[]))
    @layout! wdg Widgets.div(:text, :by_toggle, hbox(:apply, hskip(1em), :reset), _.display)
end
