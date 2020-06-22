var = "here is some ";

text[] := (

    s = "cloud generated text";
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