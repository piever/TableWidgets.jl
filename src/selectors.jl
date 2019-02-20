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

function selectors(t, obs::AbstractObservable; threshold = 10, defaultstyle = TableWidgets.defaultstyle)
    t isa AbstractObservable || (t = Observable{Any}(t))
    cols = @map Tables.columntable(&t)
    output = Observable{Any}(Tables.materializer(t[])(cols[]))
    connect!(cols, output)

    sel_dict = OrderedDict(sym => Observable{Any}(Widget[]) for sym in selectortypes)

    function update_sels!(x)
        for sym in selectortypes
            empty!(sel_dict[sym][])
        end
        for (name, col) in pairs(x)
            sel_func = defaultselector(name, col, threshold)
            sel = sel_func(col, lazymap)
            push!(sel_dict[widgettype(sel)][], toggled(sel; label = string(name), readout = false))
        end
        for sym in selectortypes
            sel_dict[sym][] = sel_dict[sym][]
        end
    end

    update_sels!(cols[])
    on(update_sels!, cols)

    wdg = Widget{:selectors}(sel_dict; output = output)

    on(obs) do _
        selwdgs = Iterators.flatten(wdg[seltyp][] for seltyp in selectortypes)
        sels = (i[] for i in selwdgs if i[:toggle][])
        output[] = Tables.materializer(t[])(_filter(cols[], sels...))
    end

    layout!(wdg) do x
        sel_cols = [node(
            :div,
            className = "column",
            string(typ),
            @map(node(:div, &x[typ]...))
        ) for typ in selectortypes]
        filters = node(:div, className = "columns", sel_cols...)
    end
end

function selectors(t; kwargs...)
    btn = button("Filter")
    wdg = selectors(t, btn; kwargs...)
    wdg[:filter] = btn
    Widgets.layout(wdg) do x
        node(:div, wdg[:filter], x)
    end
end
