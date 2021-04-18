#!wolframscript

GWDir := Environment["GW_DIR"]

Import[GWDir <> "/Component.m"]
Import[GWDir <> "/Server.m"]
On[Assert]

component = New[Component, <|"tag"-> "a", "text" -> "Hello World!"|>]

i = 0
listComponent = New[Component, <|"tag"-> "ul", "class" -> {"test-class"}, "children" -> {
    New[Component, <|"tag"-> "li", "style" -> <|"margin" -> 2|>, "text" -> (i = i + 1; ToString[i])|>],
    New[Component, <|"tag"-> "li", "style" -> <|"margin" -> 3|>, "text" -> (i = i + 1; ToString[i])|>],
    New[Component, <|"tag"-> "li", "style" -> <|"margin" -> 4|>, "text" -> (i = i + 1; ToString[i])|>]
}|>]

Graywolf[{component, listComponent}]