using TableWidgets, Interact, CSV, Blink, Observables
import DataFrames: DataFrame
import StatPlots: dataviewer
import TableView: showtable
import Observables: AbstractObservable, @map!
import Widgets: components
gr()

# Here we see how to compose widgets. First we create something similar to pipeline:

function datapipeline(df)
    df isa AbstractObservable || (df = Observable{Any}(df))
    loader = filepicker()
    filter = selectors(df)
    editor = dataeditor(map(DataFrame, filter))

    wdg = Widget{:datapipeline}(
        OrderedDict("load" => loader, "filter" => filter, "edit" => editor);
        output = observe(editor), # The output of this widget is the output of the last processing step
        layout = x -> tabulator(components(x)) # As layout, we put all the components in separate tabs
    )
end

# Here we create the graphical part, combining existing widgets from the Julia ecosystem
# In this case I'm taking the spreadsheet visualizer from TableView and the UI from StatPlots
function visualizer(df)
    df isa AbstractObservable || (df = Observable{Any}(df))
    wdg = Widget{:visualizer}(
        OrderedDict("TableView" => map(showtable, df), "StatPlots" => dataviewer(df));
        output = df,
        layout = x -> tabulator(components(x)) # As layout, we put all the components in separate tabs
    )
end

function myui(df)
    leftpane = datapipeline(df)
    rightpane = visualizer(leftpane)
    wdg = Widget(
        OrderedDict("left" => leftpane, "right" => rightpane);
        output = observe(rightpane),
    )

    @layout! wdg begin
        node(
            "div",
            className = "columns",
            node("div", className = "column", :left),
            node("div", className = "column", :right),
        )
    end
end

# Now that we have an analysis widget, we can add some visualizations
function myui()
    wdg = filepicker()
    widget(myui∘CSV.read, wdg, init = wdg) # initialize the widget as a filepicker, when the filepicker gets used, replace with the output of `myui` called with the loaded table
end

w = Window()
body!(w, myui())
