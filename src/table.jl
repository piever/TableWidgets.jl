function format(x)
    io = IOBuffer()
    show(IOContext(io, :compact => true), x)
    String(take!(io))
end

function row(r, i; format = TableWidgets.format)
	fields = propertynames(r)

    node("tr",
        node("th", format(i)),
        (node("td", format(getproperty(r, field))) for field in fields)...)
end

rendertable(t; kwargs...) = render_row_iterator(Tables.rows(t); kwargs...)
rendertable(t, r::Integer; kwargs...) = render_row_iterator(Iterators.take(Tables.rows(t), r); kwargs...)

function render_row_iterator(t; format = TableWidgets.format, className = "is-striped is-hoverable")
    fr, lr = Iterators.peel(t)

    names = propertynames(fr)
    headers = node("tr", node("th", ""), (node("th", string(n)) for n in names)...) |> node("thead")

    first_row = row(fr, 1; format = format)
    body = node("tbody", first_row, (row(r, i+1; format = format) for (i, r) in enumerate(lr))...)
    className = "table $className"
    n = slap_design!(node("table", headers, body, className = className))
end

"""
`head(t, r=6)`

Show first `r` rows of table `t` as HTML table.
"""
function head(t, r::Integer = 6; kwargs...)
    t isa AbstractObservable || (t = Observable{Any}(t))
    r isa AbstractObservable || (r = Observable{Integer}(r))
    h = @map rendertable(&t, &r; kwargs...)

    Widget{:head}([:rows => r, :head => h], output = t, layout = i -> i[:head])
end

function toggled(wdg::AbstractWidget; readout = true, label = "Show")
    toggled_wdg = togglecontent(wdg, label = label, value = readout)
    Widget{:toggled}([:toggle => toggled_wdg], output = observe(wdg), layout = i -> i[:toggle])
end

# """
# `dataeditor(t)`
#
# Create a textbox to preprocess a table with JuliaDB / JuliaDBMeta: displays the result using `toggletable`.
# """
# @widget wdg function dataeditor(t, args...; kwargs...)
#     (t isa Observable) || (t = Observable{Any}(t))
#     :input = t
#     @output! wdg Observable{Any}(table(t[]))
#     @display! wdg toggletable(_.output, args...; kwargs...)
#     :text = textarea(placeholder = "Write transformation to apply to the table")
#     :by_wdg = dropdown(map(colnames, t), placeholder = "Grouping variables", multiple = true)
#     :flatten = checkbox("flatten")
#     wdg[:by_toggle] = togglecontent(hbox(wdg[:by_wdg], hskip(1em), wdg[:flatten]), label = "Group data")
#     :by = $(:by_toggle) ? $(:by_wdg) : nothing
#     parsetext!(wdg; text = observe(wdg, :text), on = (observe(wdg, :text)), parse = parsepipeline, default = identity)
#     :apply = button("Apply")
#     :reset = button("Reset", className = "is-danger")
#     @on wdg ($(:apply); $(:input); _.output[] = :by[] === nothing ? :function[](:input[]) : groupby(:function[], :input[], Tuple(:by[]); flatten = :flatten[]))
#     @on wdg ($(:reset); :text[] = ""; _.output[] = table(t[]))
#     @layout! wdg Widgets.div(:text, :by_toggle, hbox(:apply, hskip(1em), :reset), _.display)
# end
#
# dataeditor(t::Widgets.AbstractWidget, args...; kwargs...) = dataeditor(observe(t), args...; kwargs...)
