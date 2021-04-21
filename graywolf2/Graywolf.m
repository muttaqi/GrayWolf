#!wolframscript

GWDir := Environment["GW_DIR"]
CurrentDirectory = StringRiffle[Drop[StringSplit[ExpandFileName[First[$ScriptCommandLine]], "\\"], -1], "/"];

Import[GWDir <> "/Server.m"]

PathJoin[names__] := (
    StringReplace[FileNameJoin[List[names]], "\\"->"/"]
);

RenderList[components_List] := (
    out := "";
    
    (
        out = out <> "\n" <> #["render", {}];
    )&/@components;
    out
);

Inject[components_List] := (
    indexPath = PathJoin[CurrentDirectory, "index.html"];
    If[
        FileExistsQ[indexPath],
        (
            html := ReadString[File[indexPath]];
            StringReplace[html, "{{ GRAYWOLF }}" -> RenderList[components]]
        ),
        (
            RenderList[components]
        )
    ]
);

Graywolf[components_List] := (

    distPath = PathJoin[CurrentDirectory, "dist", "index.html"];
    If[
        Not[FileExistsQ[distPath]],
        CreateFile[distPath]
    ];
    dist = OpenWrite[distPath];
    WriteString[dist, Inject[components]];
    Close[dist];
    
    Serve[File[distPath]];
);

Graywolf[component_] := Graywolf[{component}];

CompileAndServe[main_] := (
    If[Not[FileExistsQ[main]], Error["Main.m not found"]];

    Print["Starting..."];
    serverProc = StartProcess[{"wolframscript", main}];
    url = ReadString[serverProc, "\n"];

    <|"Process"->serverProc, "URL"->url|>
)

Controller[main_] := (
    serverTuple = CompileAndServe[main];
    Print["Listening:  ", serverTuple["URL"], "\n"];
    
    While[True,
        (
            Print["[q] quit\n[r] reload\n"];
            in = ToString[Input[]];
            If[
                in == "q",
                (
                    KillProcess[serverTuple["Process"]];
                    Quit[];
                ),
                If[
                    in == "r",
                    (
                        KillProcess[serverTuple["Process"]];
                        serverTuple = CompileAndServe[main];
                        Print["Listening:  ", url, "\n"];
                    )
                ]
            ]
        )
    ]
);

If[
    And[
        Length[$ScriptCommandLine] == 2,
        StringTake[ToString[Part[$ScriptCommandLine,1]], -10] == "Graywolf.m"
    ],
    Controller[PathJoin[ToString @ Part[$ScriptCommandLine,2], "Main.m"]]
];
