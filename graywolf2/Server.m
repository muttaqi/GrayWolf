#!wolframscript

RenderList[components_List] := (
    out := "";
    
    (
        out = out <> "\n" <> #["render", {}];
    )&/@components;
    out
)

Graywolf[components_List] := (
    listener = SocketListen[
        58000,
        Function[{assoc},
            With[{
            client = assoc["SourceSocket"]
            },
            response = ExportString[
            HTTPResponse[ RenderList[components], <|
                "StatusCode" -> 200,
                "ContentType" -> "text/html",
                "Headers" -> { "Access-Control-Allow-Origin" -> origin }
            |>], "HTTPResponse"];
            WriteString[client, response];
            Close[client]
            ]
        ]
    ];

    url = URLBuild[
        <|
            "Scheme" -> "http",
            "Domain" -> First[listener["Socket"]["DestinationIPAddress"]],
            "Port" -> listener["Socket"]["DestinationPort"]
        |>
    ];

    Print["Listening:  ", url, "\n"];

    task = ZeroMQLink`Private`$AsyncState["Task"];
    WaitAsynchronousTask[task];
    Print["Exiting..."];
)

Graywolf[component_] := Graywolf[{component}]