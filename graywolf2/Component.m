#!wolframscript

Import["woops/woops.m"]
Off[General::stop]

Component := Class[
    <|
        "tag" -> "",
        "style" -> <||>,
        "class" -> {},
        "text" -> "",
        "children" -> {}
    |>,
    <|
        "render" -> Function[
            {this},
            (
                out := "<" <> this["tag"] <> " style=\"";
                
                Do[
                    (
                        out = out <> styleName <> ": " <> ToString[this["style"][styleName]] <> "; ";
                    ),
                    {
                        styleName,
                        Keys[this["style"]]
                    }
                ];

                out = out <> "\" class=\"";
                (
                    out = out <> # <> " ";
                ) &/@ this["class"];

                out = out <> "\">\n" <> this["text"] <> "\n";
                (
                    out = out <> #["render", {}] <> "\n";
                ) &/@ this["children"];

                out = out <> "</" <> this["tag"] <> ">";

                out
            )
        ]
    |>
];

Img := Extend[Component, 
    <|
        "tag"->"img",
        "src"->None
    |>,
    <|
        "render"->Function[
            {this},
            (
                srcString = "data:image/png;base64,"<>BaseEncode[ExportByteArray[this["src"], "PNG"]];
                superRender = this["_super"]["render", {}];
                StringInsert[superRender, " src=\""<>srcString<>"\"", 5]
            )
        ]
    |>
]