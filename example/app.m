(* ::Package:: *)

var = "Hello world ";

text[] := (

    s = "from the Wolfram Cloud!";
    var <> s
)

App[{

    a[
        "Text",
        id -> "aId",
        children -> {
            p[
                text[]
            ]
        }
    ]
}]
