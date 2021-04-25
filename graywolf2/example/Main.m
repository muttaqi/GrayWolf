#!wolframscript

GWDir := Environment["GW_DIR"]

Import[GWDir <> "/Graywolf.m"]

component = New[Component, <|"tag"-> "a", "text" -> "Hello World!"|>]

i = 1
listComponent = New[Component, <|"tag"-> "ul", "class" -> {"test-class"}, "children" -> {
    New[Component, <|"tag"-> "li", "style" -> <|"margin" -> 2|>, "text" -> (i = i + 1; ToString[i])|>],
    New[Component, <|"tag"-> "li", "style" -> <|"margin" -> 3|>, "text" -> (i = i + 1; ToString[i])|>],
    New[Component, <|"tag"-> "li", "style" -> <|"margin" -> 4|>, "text" -> (i = i + 1; ToString[i])|>]
}|>]

imgComponent = New[Img, <|"src"->Graphics[Circle[]], "style"-><|"width"->"200px", "height"->"auto"|>|>]

srcComponent = New[Script, <|"src"->"js/main.js"|>];

Graywolf[{srcComponent, component, listComponent, imgComponent}]