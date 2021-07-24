#!wolframscript

GWDir := Environment["GW_DIR"]

Import[GWDir <> "/Component.m"]
On[Assert]

component = New[Component, <|"tag"-> "a", "text" -> "Hello World!"|>]

Assert[component["render", {<||>}]["html"] == "<a >\nHello World!\n</a>"]

listComponent = New[Component, <|"tag"-> "ul", "class" -> {"test-class"}, "children" -> {
    New[Component, <|"tag"-> "li", "style" -> <|"margin" -> 2|>|>],
    New[Component, <|"tag"-> "li", "style" -> <|"margin" -> 3|>|>],
    New[Component, <|"tag"-> "li", "style" -> <|"margin" -> 4|>|>]
}|>]

Assert[listComponent["render", {<||>}]["html"] == "<ul class=\"test-class \" >\n\n<li style=\"margin: 2; \" >\n\n</li>\n<li style=\"margin: 3; \" >\n\n</li>\n<li style=\"margin: 4; \" >\n\n</li>\n</ul>"]

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

Assert[StringTake[embedComponent["render", {<||>}], 7]["html"] == "<iframe"];
*)

Assert[BR["render", {<||>}]["html"] == "<br>"];

bound = Bind["test"];
boundComponent = New[Component, <|"tag"-> "a", "text" -> bound|>];

result = boundComponent["render", {<||>}];

Assert[StringContainsQ[result["html"], "<a"]]
Assert[StringContainsQ[result["html"], "\ntest\n"]]
Assert[StringContainsQ[result["html"], "</a>"]]

GenerateState[result["stateRelationships"]];

boundComponent = New[Component, <|"tag"-> "ul", "class" -> {"test-class"}, "children" -> {
    New[Component, <|"tag"-> "li", "style" -> <|"margin" -> 2|>, "text" -> bound|>],
    New[Component, <|"tag"-> "li", "style" -> <|"margin" -> 3|>, "text" -> bound|>],
    New[Component, <|"tag"-> "li", "style" -> <|"margin" -> 4|>, "text" -> bound|>],
    New[Component, <|"tag"-> "input", "props"-> <|"value" -> bound|>|>]
}|>];

result = boundComponent["render", {<||>}];

GenerateState[result["stateRelationships"]];
Assert[Keys[result["stateRelationships"]] > 0];
