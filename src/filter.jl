"""
`addfilter(t; readout = true)`

Create selectors (`categoricalselector`, `rangeselector`, `selector` are supported) and delete them for various
columns of table `t`. `readout` denotes whether the table will be displayed initially. Outputs the filtered table.
"""
@widget wdg function addfilter(t; readout = true)
    t isa Observable || (t = Observable{Any}(t))
    :cols = dropdown(map(colnames, t), placeholder = "Column to filter", value = nothing)
    selectoptions = OrderedDict(
        "categorical" => categoricalselector,
        "range" => rangeselector,
        "predicate" => selector
    )
    :selectortype = dropdown(selectoptions, placeholder = "Selector type", value = nothing)
    :button = button("Add selector")
    :filter = button("Filter")
    function columnlayout(v)
        cols = map(Widgets.div(className = "column"), v)
        Widgets.div(className = "columns is-multiline is-mobile", cols...)
    end
    :selectors = notifications([], layout = columnlayout)

    lazymap(f, v) = (f(i) for i in v)
    @on wdg begin
        $(:button)
        push!(:selectors[], :selectortype[](t[], :cols[], lazymap))
        :selectors[] = :selectors[]
    end

    @output! wdg Observable{Any}(t[])

    on(observe(wdg[:filter])) do x
        sels = (observe(i)[] for i in observe(wdg[:selectors])[])
        wdg.output[] = isempty(sels) ? t[] : t[][[all(i) for i in zip(sels...)]]
    end

    @layout! wdg Widgets.div(
        Widgets.div(className = "level is-mobile", map(Widgets.div(className="level-item"), [:cols, :selectortype, :button, :filter])...),
        :selectors,
        toggletable(_.output, readout = true)
    )
    on(t) do x
        observe(wdg, :selectors)[] = []
        observe(wdg)[] = x
    end
end

addfilter(t::Widgets.AbstractWidget; kwargs...) = addfilter(observe(t); kwargs...)
