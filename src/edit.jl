using NamedTuples

# Recipe implementation of Simon Byrne editable table

@widget wdg function editablefield(field, w = widget(field); editing = false, format = _compact)
    :widget = w
    :field = :widget
    editing isa Observable || (editing = Observable(editing))
    :editing = editing
    @output! wdg :widget
    @layout! wdg $(:editing) ? :widget : map(format, :field)
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
