using TableWidgets, Interact, CSV, Blink, Observables
using StatPlots
import DataFrames: DataFrame
import StatPlots: dataviewer
import TableView: showtable
import Observables: AbstractObservable, @map!
import Widgets: components
gr()

# Here we see how to compose widgets. First we create something similar to pipeline:

function datapipeline(df; loader = nothing) # loader here is a placeholder, we'll fill it later with a loader with an appropriate callback
    df isa AbstractObservable || (df = Observable{Any}(df))
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

function myui(df; kwargs...)
    leftpane = datapipeline(df; kwargs...)
    rightpane = visualizer(leftpane)
    wdg = Widget(
        OrderedDict("left" => leftpane, "right" => rightpane);
        output = observe(rightpane),
    )
    colstyle = Dict("height" => "100vh", "overflow-y" => "scroll", "overflow-x" => "hidden")
    @layout! wdg begin
        node(
            "div",
            className = "columns",
            node("div", className = "column is-two-fifths has-background-light", :left; style = colstyle),
            node("div", className = "column", :right; style = colstyle),
        )
    end
end

function myui()
    loader = filepicker()
    ui = Observable{Any}(loader)
    # initialize the widget as a filepicker, when the filepicker gets used, replace with the output of `myui` called with the loaded table
    @map! ui myui(CSV.read(&loader, allowmissing = :none), loader = loader)
    WebIO.render(ui)
end

w = Window()
body!(w, myui())
