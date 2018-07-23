financetable(v::AbstractArray; kwargs...) =
    financetable(table(v, fill("", length(v)), names = [:Comment, :Category]); kwargs...)

function financetable(t::IndexedTables.AbstractIndexedTable; categories=[""])
    obs_table = Observable{Any}(t)
    options = map(t -> union(last(columns(t)), categories), obs_table)
    function widgetfunction(t, i, s)
        col = column(t, s)
        val = col[i]
        autocomplete(options, value = val)
    end
    displaytable(obs_table, edit = :Category, widgetfunction = widgetfunction)
end
