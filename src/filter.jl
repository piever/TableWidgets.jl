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
    function columnlayout(v)
        cols = map(Widgets.div(className = "column"), v)
        Widgets.div(className = "columns is-multiline", cols...)
    end
    :selectors = deletablelist([], layout = columnlayout)
    @on wdg begin
        $(:button)
        push!(:selectors[], :selectortype[](t[], :cols[]))
        :selectors[] = :selectors[]
    end
    @layout! wdg Widgets.div(
        Widgets.div(className = "level is-mobile", map(Widgets.div(className="level-item"), [:cols, :selectortype, :button])...),
        :selectors,
    )
end
