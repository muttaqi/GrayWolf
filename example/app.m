(* ::Package:: *)

SetDirectory["C:/Users/12265/GrayWolf/src"];
Import["./GrayWolf.m"];
 
var = "Hello world ";

generateText[] := (

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
                textContent -> "Welcome to GrayWolf",
                id -> "aId",
                children -> {
                    p[
                        textContent :> generateText[]
                    ]
                }
            ],
            img[
                id -> "image",
                src :> Graphics[Circle[]]
            ]
        }
    ]
}]