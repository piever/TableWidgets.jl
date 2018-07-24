@widget wdg function addfilter(t)
    t isa Observable || (t = Observable{Any}(t))
    :cols = dropdown(map(colnames, t), label = "Column to filter")
    selectoptions = OrderedDict(
        "categorical" => categoricalselector,
        "range" => rangeselector,
        "predicate" => selector
    )
    :selectortype = dropdown(selectoptions, label = "Selector type")
    :button = button("Add selector")
    :filter = button("Filter")
    function columnlayout(v)
        cols = map(Widgets.div(className = "column"), v)
        Widgets.div(className = "columns is-multiline", cols...)
    end
    :selectors = deletablelist([], layout = columnlayout)

    lazymap(f, v) = (f(i) for i in v)
    @on wdg begin
        $(:button)
        push!(:selectors[], :selectortype[](t[], :cols[], lazymap))
        :selectors[] = :selectors[]
    end

    @output! wdg t

    on(observe(wdg[:filter])) do x
        sels = (observe(i)[] for i in observe(wdg[:selectors])[])
        wdg.output[] = t[][[all(i) for i in zip(sels...)]]
    end

    @layout! wdg Widgets.div(
        Widgets.div(className = "level is-mobile", map(Widgets.div(className="level-item"), [:cols, :selectortype, :button, :filter])...),
        :selectors,
    )
end
