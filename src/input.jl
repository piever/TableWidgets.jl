_isvalid(x) = x isa AbstractString && x != ""

@widget wdg function tablepicker(args...; kwargs...)
    :widget = filepicker(args...; kwargs...)
    @output! wdg _isvalid($(:widget)) ? loadtable($(:widget)) : nothing
    @display! wdg Observable{Any}(nothing)
end
