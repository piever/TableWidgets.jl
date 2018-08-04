using TableWidgets, Interact, StatPlots, JuliaDBMeta, Blink
gr()

@widget wdg function mypipeline(t)
    (t isa Observable) || (t = Observable{Any}(t))
    :table = t
    :filter = addfilter(:table)
    :editor = dataeditor(:filter)
    :plotter = dataviewer(:editor)

    @layout! wdg tabulator(OrderedDict("filter" => :filter, "editor" => :editor, "plotter" => :plotter))
end

function mypipeline()
    wdg = filepicker()
    widget(mypipeline∘loadtable, wdg, init = wdg) # initialize the widget as a filepicker, when the filepicker gets used, replace with the output of `mypipeline` called with the loaded table
end

##

display(mypipeline())
