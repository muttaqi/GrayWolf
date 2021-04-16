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