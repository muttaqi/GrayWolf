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

            contentType = "text/html";

            If[
                ((StringLength[route] > 4) && (StringTake[route, -4] == "wasm")),
                contentType = "application/wasm"
            ];

            If[
                ((StringLength[route] > 3) && (StringTake[route, -3] == "ico")),
                contentType = "image/x-icon"
            ];

            (* return response *)
            response = ExportString[
            HTTPResponse[ responseString, <|
                "StatusCode" -> 200,
                (* wasm files require specific header *)
                "ContentType" -> contentType,
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

(* if Server.m is run via the CLI it will serve a specified folder *)
If[
    And[
        Length[$ScriptCommandLine] == 2,
        ToLowerCase[StringTake[ToString[Part[$ScriptCommandLine,1]], -8]] == "server.m"
    ],
    Serve[PathJoin[ToString @ Part[$ScriptCommandLine,2]]]
];