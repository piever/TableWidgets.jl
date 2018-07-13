using NamedTuples

# Recipe implementation of Simon Byrne editable table

@widget wdg function editablefield(field, w = widget(field); editing = false)
    :widget = w
    :field = :widget
    editing isa Observable || (editing = Observable(editing))
    :editing = editing
    @output! wdg :widget
    @layout! wdg $(:editing) ? :widget : :field
end

@widget wdg function editbutton(save = x -> nothing; editing = false)
    :edit = button("Edit")
    :save = button("Save")
    editing isa Observable || (editing = Observable(editing))
    :editing = editing
    changestate() = (editing[] = !editing[])
    @on wdg ($(:edit); changestate())
    @on wdg (save($(:save)); changestate())
    @layout! wdg $(:editing) ? :save : :edit
end

@widget wdg function editablerow(t, i; editing = false)
    row = t[i]
	ns = colnames(t)
    editing isa Observable || (editing = Observable(editing))
    for el in ns
        wdg[el] = editablefield(getfield(row, el); editing = editing)
    end
    :button = editbutton(; editing = editing) do x
        for el in ns
            column(t, el)[i] = observe(wdg, el)[]
        end
    end

    @layout! wdg Node(^(:tr), Node(^(:td), i), (Node(^(:td), _[el]) for el in ns)..., Node(^(:td), :button))
end

@widget wdg function editabletable(t, lines = 1:min(10, length(t)))
    wdg[:headers] = Node(
        :tr,
        Node(:th, pad((:right, :bottom), 1em, "#")),
        Node.(:th, pad.(((:right, :bottom),), 1em, string.(colnames(t))))...,
        Node(:th,  pad((:right, :bottom), 1em, "edit"))
    )
    for i in lines
        wdg["row$i"] = editablerow(t, i)
    end
    @layout! wdg Node(^(:table), values(wdg.children)...)
end
