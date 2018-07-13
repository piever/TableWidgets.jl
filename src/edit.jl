using NamedTuples

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
    changestate(x) = (editing[] = !editing[])
    on(changestate, observe(wdg, :edit))
    on(x -> (save(x); changestate(x)), observe(wdg, :save))
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

    @layout! wdg Node(^(:tr), (Node(^(:td), _[el]) for el in ns)..., Node(^(:td), :button))
end
