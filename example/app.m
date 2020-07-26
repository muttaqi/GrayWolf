(* ::Package:: *)

var = "Hello world ";

text[] := (

    s = "from the Wolfram Cloud!";
    var <> s
)

App[{

    head[
        children -> {
            script[
                src -> "./controller.js"
            ]
        }
    ],
    
    body[
        children -> {
            a[
                "Welcome to GrayWolf",
                id -> "aId",
                children -> {
                    p[
                        text[]
                    ]
                }
            ],
            img[
                id -> "image",
                src -> Graphics[Circle[]]
            ]
        }
    ]
}]
