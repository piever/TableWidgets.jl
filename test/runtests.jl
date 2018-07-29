using TableWidgets, Observables, WebIO, Widgets, InteractBase
using IndexedTables, IterableTables, DataFrames, RDatasets
@static if VERSION < v"0.7.0-DEV.2005"
    using Base.Test
else
    using Test
end

@testset "selector" begin
    v = [1, 1, 2, 2, 1, 3, 4]
    sel = categoricalselector(v)
    @test observe(sel)[] == v
    observe(sel, :checkboxes)[] = [1, 3]
    sleep(0.1)
    @test observe(sel)[] == [1, 1, 1, 3]

    sel = rangeselector(v)
    @test observe(sel)[] == v
    observe(sel, :extrema)[] = [1.8, 3.2]
    observe(sel, :changes)[] = 4
    sleep(0.1)
    @test observe(sel)[] == [2, 2, 3]

    sel = selector(v, map)
    @test observe(sel)[] == fill(true, length(v))
    observe(sel, :function)[] = t -> t != 2
    observe(sel, :textbox, :changes)[] = 4
    sleep(0.1)
    @test observe(sel)[] == map(t -> t != 2, v)
end

@testset "undo" begin
    obs = Observable(1)
    u = TableWidgets.Undo(obs)
    obs[] = 2
    sleep(0.1)
    @test obs[] == 2
    u()
    sleep(0.1)
    @test obs[] == 1
    @test observe(u)[] == 1
end

@testset "table" begin
    iris = RDatasets.dataset("datasets", "iris")
    t = table(iris)
    wdg = displaytable(iris)
    l = WebIO.children(WebIO.children(wdg.display[][:head])[1]) |> length
    @test l == 6
    wdg2 = displaytable(t, 1:20)
    l2 = children(children(wdg2.display[][:head])[1]) |> length
    @test l2 == 6
    @test wdg2.display[][:body] |> children |> length == 20
end
