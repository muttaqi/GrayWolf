#!wolframscript

GWDir := Environment["GW_DIR"]
CurrentDirectory = StringRiffle[Drop[StringSplit[ExpandFileName[First[$ScriptCommandLine]], "\\"], -1], "/"];

Import[GWDir <> "/Component.m"]
Import[GWDir <> "/Server.m"]
Import[GWDir <> "/Util.m"]
Import[GWDir <> "/WolfrASM.m"]

(* see github.com/muttaqi/woops for documentation on object oriented syntax used *)

(* -------------- the code below is handled by the compile and serve process ------------ *)

(* run render function for every component in a given list and output result *)
RenderList[components_List] := (
    out := "";
    
    (
        out = out <> "\n" <> #["render", {}];
    )&/@components;
    out
);

(* render a list of components and inject them into an index.html file *)
Inject[components_List] := (

    render = RenderList[components];

    (* if wasm code has been compiled by wolfrasm *)
    cCodePath = PathJoin[CurrentDirectory, "dist", "__wolfrasm__"];
    If[
        DirectoryQ[cCodePath],
        (
            (* add a {{{ SCRIPT }}} section to specify where wolfrasm script will go *)
            render = "{{{ SCRIPT }}}\n" <> render;
        )
    ];

    (* inject the render output to {{{ GRAYWOLF }}} in the index.html *)
    indexPath = PathJoin[CurrentDirectory, "index.html"];

    If[
        FileExistsQ[indexPath],
        (
            html := ReadString[File[indexPath]];
            StringReplace[html, "{{{ GRAYWOLF }}}" -> render]
        ),
        (
            RenderList[components]
        )
    ]
);

(* compile components into a dist folder *)
Graywolf[components_List] := (

    (* create and write to a dist/index.html folder *)
    distIndexPath = PathJoin[CurrentDirectory, "dist", "index.html"];
    If[
        Not[FileExistsQ[distIndexPath]],
        CreateFile[distIndexPath]
    ];
    distIndex = OpenWrite[distIndexPath];
    WriteString[distIndex, Inject[components]];
    Close[distIndex];

    (* if c code has been generated, compile it to wasm in dist/__wolfrasm__ *)
    cCodePath = PathJoin[CurrentDirectory, "dist", "__wolfrasm__"];
    If[
        DirectoryQ[cCodePath],
        (
            GenerateWASM[];
        )
    ];
    
    (* copy any js files to the dist folder in dist/js *)
    dist = PathJoin[CurrentDirectory, "dist"];
    js = PathJoin[CurrentDirectory, "js"];
    If[
        FileExistsQ[js],
        Run["cp -r "<>js<>" "<>dist]
    ];
    
    (* serve the compiled template *)
    Serve[dist];
)

(* compiling a single component is equivalent to compiling a list of components with one item *)
Graywolf[component_] := Graywolf[{component}];

(* ------------ code below is run by controller process ---------------*)

(* run the compile and serve process separately *)
CompileAndServe[main_] := (
    If[Not[FileExistsQ[main]], Error["Main.m not found"]];

    Print["Starting..."];
    (* capture url which will be outputted and return it along with the server process itself *)
    serverProc = StartProcess[{"wolframscript", main}];
    url = ReadString[serverProc, "\n"];

    <|"Process"->serverProc, "URL"->url|>
)

(* handle user input in a loop and manage compile and serve processes *)
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
                    (* clean up and quit *)
                    KillProcess[serverTuple["Process"]];
                    Quit[];
                ),
                If[
                    in == "r",
                    (
                        (* clean up and re-run compile and serve process *)
                        KillProcess[serverTuple["Process"]];
                        serverTuple = CompileAndServe[main];
                        Print["Listening:  ", serverTuple["URL"], "\n"];
                    )
                ]
            ]
        )
    ]
);

(* if Graywolf.m is run via the CLI, the controller process is run. otherwise it is simply being loaded (for example into Main.m) *)
If[
    And[
        Length[$ScriptCommandLine] == 2,
        StringTake[ToString[Part[$ScriptCommandLine,1]], -10] == "Graywolf.m"
    ],
    Controller[PathJoin[ToString @ Part[$ScriptCommandLine,2], "Main.m"]]
];
