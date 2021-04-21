#!wolframscript

Serve[file_] := (

    listener = SocketListen[
        58000,
        Function[{assoc},
            With[{
            client = assoc["SourceSocket"]
            },
            response = ExportString[
            HTTPResponse[ ReadString[file], <|
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

    Print[url <> "\n"];

    task = ZeroMQLink`Private`$AsyncState["Task"];
    WaitAsynchronousTask[task];
    Print["Exiting..."];
);
