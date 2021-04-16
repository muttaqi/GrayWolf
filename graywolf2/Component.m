#!wolframscript

Import["woops/woops.m"]

Component := Class[
    <|
        "tag" -> "",
        "style" -> <||>,
        "class" -> <||>,
        "text" -> "",
        "children" -> {}
    |>,
    <|
        "render" -> Function[
            {this},
            (
            )
        ]
    |>
]