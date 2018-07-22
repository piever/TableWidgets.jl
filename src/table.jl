using NamedTuples


@widget wdg function tablerow(i, row; string = true)
    tostring = string ? Base.string : identity
	ns = fieldnames(row)
    for el in ns
        wdg[el] = getfield(row, el)
    end

    @layout! wdg node("tr", node("td", tostring(i)), (node("td", tostring(_[el])) for el in ns)...)
end

@widget wdg function _displaytable(t, lines = 1:min(10, length(t)); className = "is-striped is-hoverable is-fullwidth", kwargs...)

    headers = (node("th", string(el)) for el in colnames(t))

    :head = node("tr", node("th", "#"), node.("th", string.(colnames(t)))...) |> node("thead")

    for (i, line) in enumerate(t[lines])
        wdg["row$i"] = tablerow(i, line; kwargs...)
    end

    :body = node("tbody", (wdg["row$i"] for i in lines)...)
    className = "table $className"
    @layout! wdg node("table", :head, :body, className=className)
end

@widget wdg function displaytable(args...; kwargs...)
    scp = WebIO.Scope()
    InteractBase.slap_design!(scp)
    scp.dom = _displaytable(args...; kwargs...)
    wdg.scope = scp
    @layout! wdg _.scope
end
