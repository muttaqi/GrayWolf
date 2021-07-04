#!wolframscript

GWDir := Environment["GW_DIR"]

Import[GWDir <> "/Util.m"]

Serve[root_] := (

    listener = SocketListen[
        58000,
        Function[{assoc},
            With[{
                client = assoc["SourceSocket"]
            },

            route = StringSplit[assoc["Data"], " "][[2]];

            If[
                route == "/",
                responseString = ReadString[File[PathJoin[root, "index.html"]]],
                responseString = ReadString[File[PathJoin[root, StringDrop[route, 1]]]]
            ];
            
            response = ExportString[
            HTTPResponse[ responseString, <|
                "StatusCode" -> 200,
                "ContentType" -> If[
                    ((StringLength[route] > 4) && (StringTake[route, -4] == "wasm")),
                    "application/wasm",
                    "text/html"
                ],
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

    Print[url <> "\n"];
    
    While[True]
);
