using DataFrames, Interact, TableWidgets, Tables
using Observables: @map

# Pass a DataFrame with the last column containing only strings
function label!(t::DataFrame; categories=[""])

    category_vec = last(Tables.columntable(t))
    category_obs = Observable{Any}(category_vec)
    options = @map union(&category_obs, categories)

    function myrow(r, i; format = TableWidgets.format)
        fields = propertynames(r)
        category = getproperty(r, last(fields))
        wdg = autocomplete(options, value = category) |> onchange
        on(wdg) do val
            category_obs[][i] = val
            category_obs[] = category_obs[]
        end

        node("tr",
            node("th", format(i)),
            (node("td", format(getproperty(r, field))) for field in fields[1:end-1])...,
            node("td", wdg))
    end

    TableWidgets.rendertable(t, row = myrow)
end

# Annotate your expenses / income from a set of categories (the set of categories
# increases every time you type one manually)
df = DataFrame(Place = ["home", "home", "work"], Amount = [-12.3, -1.2, 1400], Category = ["", "", ""])
label!(df, categories = ["Food", "Coffe", "Salary"])
