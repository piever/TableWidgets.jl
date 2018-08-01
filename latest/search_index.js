var documenterSearchIndex = {"docs": [

{
    "location": "index.html#",
    "page": "Introduction",
    "title": "Introduction",
    "category": "page",
    "text": ""
},

{
    "location": "index.html#TableWidgets-1",
    "page": "Introduction",
    "title": "TableWidgets",
    "category": "section",
    "text": "TableWidgets provides a simple set of widgets to be used in combination with Interact and JuliaDB, JuliaDBMeta (though in future other table types may be supported)."
},

{
    "location": "index.html#Getting-started-1",
    "page": "Introduction",
    "title": "Getting started",
    "category": "section",
    "text": "To install it:Pkg.clone(\"https://github.com/piever/TableWidgets.jl.git\")See the API reference for more details."
},

{
    "location": "api_reference.html#",
    "page": "API reference",
    "title": "API reference",
    "category": "page",
    "text": ""
},

{
    "location": "api_reference.html#API-reference-1",
    "page": "API reference",
    "title": "API reference",
    "category": "section",
    "text": ""
},

{
    "location": "api_reference.html#TableWidgets.displaytable",
    "page": "API reference",
    "title": "TableWidgets.displaytable",
    "category": "function",
    "text": "displaytable(t, rows=1:10; edit = false)\n\nShow rows rows of table t as HTML table. Use : to show the whole table. Use edit=true to make the rows editable. Use reset! to restore original table.\n\n\n\n"
},

{
    "location": "api_reference.html#TableWidgets.toggletable",
    "page": "API reference",
    "title": "TableWidgets.toggletable",
    "category": "function",
    "text": "toggletable(t, rows=1:10)\n\nSame as displaytable but the table can be shown or hidden with a toggle switch.\n\n\n\n"
},

{
    "location": "api_reference.html#Visualizing-tables-1",
    "page": "API reference",
    "title": "Visualizing tables",
    "category": "section",
    "text": "displaytable\ntoggletable"
},

{
    "location": "api_reference.html#TableWidgets.categoricalselector",
    "page": "API reference",
    "title": "TableWidgets.categoricalselector",
    "category": "function",
    "text": "categoricalselector(v::AbstractArray, f=filter)\n\nCreate as many checkboxes as the unique elements of v and use them to select v. By default it returns a filtered version of v: use categoricalselector(v, map) to get the boolean vector of whether each element is selected\n\n\n\n"
},

{
    "location": "api_reference.html#TableWidgets.rangeselector",
    "page": "API reference",
    "title": "TableWidgets.rangeselector",
    "category": "function",
    "text": "rangeselector(v::AbstractArray, f=filter)\n\nCreate a rangepicker as wide as the extrema of v and uses to select v. By default it returns a filtered version of v: use rangeselector(v, map) to get the boolean vector of whether each element is selected\n\n\n\n"
},

{
    "location": "api_reference.html#TableWidgets.selector",
    "page": "API reference",
    "title": "TableWidgets.selector",
    "category": "function",
    "text": "selector(v::AbstractArray, f=filter)\n\nCreate a textbox where the user can type in an anonymous function that is used to select v. _ can be used to denote the funcion argument, e.g. _ > 0. By default it returns a filtered version of v: use selector(v, map) to get the boolean vector of whether each element is selected\n\n\n\n"
},

{
    "location": "api_reference.html#TableWidgets.addfilter",
    "page": "API reference",
    "title": "TableWidgets.addfilter",
    "category": "function",
    "text": "addfilter(t; readout = true)\n\nCreate selectors (categoricalselector, rangeselector, selector are supported) and delete them for various columns of table t. readout denotes whether the table will be displayed initially. Outputs the filtered table.\n\n\n\n"
},

{
    "location": "api_reference.html#Filtering-data-1",
    "page": "API reference",
    "title": "Filtering data",
    "category": "section",
    "text": "categoricalselector\nrangeselector\nTableWidgets.selector\naddfilter"
},

{
    "location": "api_reference.html#TableWidgets.dataeditor",
    "page": "API reference",
    "title": "TableWidgets.dataeditor",
    "category": "function",
    "text": "dataeditor(t)\n\nCreate a textbox to preprocess a table with JuliaDB / JuliaDBMeta: displays the result using toggletable.\n\n\n\n"
},

{
    "location": "api_reference.html#Processing-data-1",
    "page": "API reference",
    "title": "Processing data",
    "category": "section",
    "text": "dataeditor"
},

]}
