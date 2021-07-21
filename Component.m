#!wolframscript

Import["woops/woops.m"]
Off[General::stop]

(* see github.com/muttaqi/woops for documentation on object oriented syntax used *)

(* component class *)
Component := Class[
    <|
        "tag" -> "",
        "style" -> <||>,
        "class" -> {},
        "text" -> "",
        "children" -> {}
    |>,
    <|
        (* renders a component into html format *)
        "render" -> Function[
            {this},
            (
                out = "<" <> this["tag"] <> " ";
                
                (* format style association as CSS format *)
                If[Length[Keys[this["style"]]] > 0, (
                        out = out <> "style=\"";
                        
                        Do[
                            (
                                out = out <> styleName <> ": " <> ToString[this["style"][styleName]] <> "; ";
                            ),
                            {
                                styleName,
                                Keys[this["style"]]
                            }
                        ];
                        out = out <> "\" ";
                    )
                ];

                (* format class list as space-divided output *)
                If[Length[this["class"]] > 0, (
                    out = out <> "class=\"";
                    (
                        out = out <> # <> " ";
                    ) &/@ this["class"];
                    
                    out = out <> "\" ";
                )];

                (* text content *)
                out = out <> ">\n" <> this["text"] <> "\n";
                (
                    out = out <> #["render", {}] <> "\n";
                ) &/@ this["children"];

                (* close tag and return *)
                out = out <> "</" <> this["tag"] <> ">";

                out
            )
        ]
    |>
];

(* img is a component with a pre-determined tag, and an additional src field *)
Img := Extend[Component, 
    <|
        "tag"->"img",
        "src"->None
    |>,
    <|
        "render"->Function[
            {this},
            (
                (* get image data in base64 *)
                srcString = "data:image/png;base64,"<>BaseEncode[ExportByteArray[this["src"], "PNG"]];
                (* call component render *)
                superRender = this["_super"]["render", {}];
                (* insert base64 data *)
                StringInsert[superRender, " src=\""<>srcString<>"\"", 5]
            )
        ]
    |>
]

(* script is a component with a pre-determined tag, and an additional src field *)
Script := Extend[Component,
    <|
        "tag"->"script",
        "src"->""
    |>,
    <|
        "render"->Function[
            {this},
            (
                (* render as a component and insert src file attribute *)
                superRender = this["_super"]["render", {}];
                StringInsert[superRender, " src=\""<>this["src"]<>"\"", 8]
            )
        ]
    |>
]

(* embed is a component that renders to a static string computed by wolfram *)
Embed := Extend[Component,
    <|
        "object"->Nothing
    |>,
    <|
        "render"->Function[
            {this},
            (
                EmbedCode[this["object"]]["CodeSection"]["Content"]
            )
        ]
    |>
]

BRType := Extend[Component,
    <|
        "tag"->"iframe"
    |>,
    <|
        "render"->Function[
            {},
            (
                "<br>"
            )
        ]
    |>
]

BR = New[BRType];