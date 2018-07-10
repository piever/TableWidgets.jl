using TableWidgets, Observables, InteractBase
@static if VERSION < v"0.7.0-DEV.2005"
    using Base.Test
else
    using Test
end

@testset "selector" begin
    v = [1, 1, 2, 2, 1, 3, 4]
    sel = categoricalselector(v)
    @test observe(sel)[] == v
    observe(sel[:checkboxes])[] = [1, 3]
    @test observe(sel)[] == [1, 1, 1, 3]
    
    sel = rangeselector(v)
    @test observe(sel)[] == v
    observe(sel, :minimum)[] = 2
    observe(sel, :maximum)[] = 3
    sel[:minimum][:changes][] = 4
    @test observe(sel)[] == [2, 2, 3]
end

