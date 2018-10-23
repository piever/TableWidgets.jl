lazymap(f, v) = (f(i) for i in v)

# To be replaced by the equivalent operations in TableOperators
_filter(t) = t
function _filter(t, args...)
    mask = [all(i) for i in zip(args...)]
    map(x -> x[mask], Tables.columntable(t))
end

@enum ColumnStyle categorical numerical arbitrary

const selectordict = Dict(
    categorical => categoricalselector,
    numerical => rangeselector,
    arbitrary => selector,
)

const selectortypes = [:categoricalselector, :rangeselector, :selector]

function hasdistinct(col, n)
    itr = IterTools.distinct(col)
    for (i, _) in enumerate(itr)
        i >= n && return true
    end
    return false
end

defaultstyle(name::Symbol, col::AbstractVector{<:Union{Missing, Real}}, n) = hasdistinct(col, n) ? numerical : categorical
defaultstyle(name::Symbol, col, n) = hasdistinct(col, n) ? arbitrary : categorical

defaultselector(args...) = selectordict[defaultstyle(args...)]

function selectors(t; threshold = 10, defaultstyle = TableWidgets.defaultstyle)
    cols = Tables.columntable(t)

    wdg = Widget{:selectors}()
    foreach(sym -> wdg[sym] = Widget{sym}[], selectortypes)

    for (name, col) in pairs(cols)
        sel_func = defaultselector(name, col, threshold)
        sel = toggled(sel_func(col, lazymap; label = string(name), readout = false))
        push!(wdg[widgettype(sel)], sel)
    end

    layout!(wdg) do x
        cols = [node(
            :div,
            className = "column",
            string(typ),
            x[typ]...
        ) for typ in selectortypes]
        node(:div, className = "columns", cols...)
    end
end