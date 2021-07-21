#!wolframscript

GWDir := Environment["GW_DIR"]

Import[GWDir <> "/Component.m"]
On[Assert]

component = New[Component, <|"tag"-> "a", "text" -> "Hello World!"|>]

Assert[component["render", {}] == "<a >\nHello World!\n</a>"]

listComponent = New[Component, <|"tag"-> "ul", "class" -> {"test-class"}, "children" -> {
    New[Component, <|"tag"-> "li", "style" -> <|"margin" -> 2|>|>],
    New[Component, <|"tag"-> "li", "style" -> <|"margin" -> 3|>|>],
    New[Component, <|"tag"-> "li", "style" -> <|"margin" -> 4|>|>]
}|>]

Assert[listComponent["render", {}] == "<ul class=\"test-class \" >\n\n<li style=\"margin: 2; \" >\n\n</li>\n<li style=\"margin: 3; \" >\n\n</li>\n<li style=\"margin: 4; \" >\n\n</li>\n</ul>"]

(* cloud call *)
(*
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

Assert[StringTake[embedComponent["render", {}], 7] == "<iframe"];
*)

Assert[BR["render", {}] == "<br>"];