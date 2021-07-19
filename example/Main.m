#!wolframscript

GWDir := Environment["GW_DIR"]

Import[GWDir <> "/Graywolf.m"]

(* example function to be compiled to WebAssembly *)
increment[i_] := i + 2;

(* text component *)
component = New[Component, <|"tag"-> "a", "text" -> "Hello World!"|>];

(* nested list component *)
i = 1
listComponent = New[Component, <|"tag"-> "ul", "class" -> {"test-class"}, "children" -> {
    New[Component, <|"tag"-> "li", "style" -> <|"margin" -> 2|>, "text" -> (i = i + 1; ToString[i])|>],
    New[Component, <|"tag"-> "li", "style" -> <|"margin" -> 3|>, "text" -> (i = i + 1; ToString[i])|>],
    New[Component, <|"tag"-> "li", "style" -> <|"margin" -> 4|>, "text" -> (i = i + 1; ToString[i])|>]
}|>];

(* img component from Mathematica graphics *)
imgComponent = New[Img, <|"src"->Graphics[Circle[]], "style"-><|"width"->"200px", "height"->"auto"|>|>];

embedComponent = New[Embed, <|"object"->
    CloudDeploy[
        Notebook[
            {
                Cell["Weekly Summary", "Title"], Cell["Monday", "Section"],
                Cell["Tuesday", "Section"], Cell["Wednesday", "Section"], 
                Cell["Thursday", "Section"], Cell["Friday", "Section"]
            }
        ], 
        FileNameJoin[{CreateDirectory[CloudObject[]], "index.nb"}]
    ]|>
];

(* compile increment function to WebAssembly *)
WolfrASMScript[increment];

(* load main.js as a script *)
scriptComponent = New[Script, <|"src"->"js/main.js"|>];

(* specify components to be served; BR represents a line break *)
Graywolf[{scriptComponent, component, listComponent, imgComponent, BR, embedComponent}]