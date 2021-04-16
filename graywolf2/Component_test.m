#!wolframscript

Import["Component.m"]
On[Assert]

component = New[Component, <|"tag"-> "a", "text" -> "Hello World!"|>]

Assert[component["render", {}] == "<a style=\"\" class=\"\">\nHello World!\n</a>"]

listComponent = New[Component, <|"tag"-> "ul", "class" -> {"test-class"}, "children" -> {
    New[Component, <|"tag"-> "li", "style" -> <|"margin" -> 2|>|>],
    New[Component, <|"tag"-> "li", "style" -> <|"margin" -> 3|>|>],
    New[Component, <|"tag"-> "li", "style" -> <|"margin" -> 4|>|>]
}|>]

Assert[listComponent["render", {}] == "<ul style=\"\" class=\"test-class \">\n\n<li style=\"margin: 2; \" class=\"\">\n\n</li>\n<li style=\"margin: 3; \" class=\"\">\n\n</li>\n<li style=\"margin: 4; \" class=\"\">\n\n</li>\n</ul>"]