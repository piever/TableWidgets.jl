@widget wdg function categoricalselector(v::AbstractArray, f=filter; label="", showoutput=true, kwargs...)
    :checkboxes = checkboxes(unique(v); kwargs...)
    :label = label
    @output! wdg f(t -> t in $(:checkboxes), v)
    showoutput || @display! wdg Observable(nothing)
    @layout! wdg vbox(:checkboxes, _.display)
end
