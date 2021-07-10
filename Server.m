#!wolframscript

GWDir := Environment["GW_DIR"]

Import[GWDir <> "/Util.m"]

Serve[root_] := (
    (* listen on the port *)
    listener = SocketListen[
        58000,
        Function[{assoc},
            With[{
                client = assoc["SourceSocket"]
            },

            (* get route from data read by socket *)
            route = StringSplit[assoc["Data"], " "][[2]];

            (* serve index.html if empty route, else serve the specified file *)
            If[
                route == "/",
                responseString = ReadString[File[PathJoin[root, "index.html"]]],
                responseString = ReadString[File[PathJoin[root, StringDrop[route, 1]]]]
            ];
            
            (* return response *)
            response = ExportString[
            HTTPResponse[ responseString, <|
                "StatusCode" -> 200,
                (* wasm files require specific header *)
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

    (* output url to confirm port is being listened to *)
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
