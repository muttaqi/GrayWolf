#!wolframscript

GWDir := Environment["GW_DIR"]
CurrentDirectory = StringRiffle[Drop[StringSplit[ExpandFileName[First[$ScriptCommandLine]], "\\"], -1], "/"];

Import[GWDir <> "/Component.m"]
Import[GWDir <> "/Server.m"]
Import[GWDir <> "/Util.m"]

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

    distIndexPath = PathJoin[CurrentDirectory, "dist", "index.html"];
    If[
        Not[FileExistsQ[distIndexPath]],
        CreateFile[distIndexPath]
    ];
    distIndex = OpenWrite[distIndexPath];
    WriteString[distIndex, Inject[components]];
    Close[distIndex];
    
    dist = PathJoin[CurrentDirectory, "dist"];
    js = PathJoin[CurrentDirectory, "js"];
    If[
        FileExistsQ[js],
        Run["cp -r "<>js<>" "<>dist]
    ];
    
    Serve[dist];
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
