isvalid(x) = x isa AbstractString && x != ""

@widget wdg function tablepicker(args...; kwargs...)
    :widget = filepicker(args...; kwargs...)
    @output! wdg isvalid($(:widget)) ? table(FileIO.load($(:widget))) : nothing
    @display! wdg displaytable($(_.output))
end
