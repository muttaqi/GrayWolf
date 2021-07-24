#!wolframscript
GWDir := Environment["GW_DIR"]

Import["woops/woops.m"]
CurrentDirectory = StringRiffle[Drop[StringSplit[ExpandFileName[First[$ScriptCommandLine]], "\\"], -1], "/"];
Import[GWDir <> "/Util.m"]

Off[General::stop]

(* see github.com/muttaqi/woops for documentation on object oriented syntax used *)

(* info about a bound variable *)
BoundVariable := Class[
    <|
        "id"->"",
        "init"->None
    |>,
    <||>
];

Bind[init_] := New[BoundVariable, <|"id"->CreateUUID["bound-graywolf"], "init"->init|>];

(* used for js generated event listeners *)
bindEvent = <|"input" -> "input", "select" -> "change", "textarea" -> "input"|>;

(* generate all js needed to represent stateRelationships *)
GenerateState[stateRelationships_] := (
    (* create folder and file for __state__.js *)
    jsFolder = PathJoin[CurrentDirectory, "dist", "js"];
    If[
        Not[DirectoryQ[jsFolder]],
        CreateDirectory[jsFolder]
    ];

    stateFilePath = PathJoin[jsFolder, "__state__.js"];
    If[
        Not[FileExistsQ[stateFilePath]],
        CreateFile[stateFilePath]
    ];

    stateJS = "";
    (* for each state relationship*)
    Do[
        (
            (* for each component bound to the bound variable *)
            Do[
                (
                    (* if it is an actor, ie. has a bind event *)
                    If[
                        MemberQ[Keys[bindEvent], boundComponent[[2]]],
                        (
                            (* upon its change event (bind event), update all other bound components bound by the variable *)
                            stateJS = stateJS <> "document.getElementById(\"" <> boundComponent[[1]] <> "\").addEventListener('" <> bindEvent[boundComponent[[2]]] <> "', (event) => {\n";
                            (
                                stateJS = stateJS <>
                                "document.getElementById(\"" <> #[[1]] <> "\")." <> #[[3]] <> " = " <> "event.target." <> boundComponent[[3]] <> ";\n";
                            ) &/@ Select[stateRelationships[boundVar], (#[[2]] != boundComponent[[2]])&];

                            stateJS = stateJS <> "});\n";
                        )
                    ];
                ),
                {
                    boundComponent,
                    stateRelationships[boundVar]
                }
            ]
        ),
        {
            boundVar,
            Keys[stateRelationships]
        }
    ];

    (* write to the js file *)
    stateFile = OpenWrite[stateFilePath];
    WriteString[stateFile, stateJS];
    Close[stateFile];
)

(* model for return object from render function *)
RenderResponse = Class[
    <|
        "html" -> "",
        "stateRelationships" -> <||>
    |>,
    <||>
];

(* update or insert a relationship to a state relationship association *)
upsertRelationship[boundVarId_, boundComponent_, stateRelationships_] := (
    If[
        KeyExistsQ[stateRelationships, boundVarId],
        <|stateRelationships, boundVarId -> Append[stateRelationships[boundVarId], boundComponent]|>,
        <|stateRelationships, boundVarId -> {boundComponent}|>
    ]
)

(* component class *)
Component := Class[
    <|
        "tag" -> "",
        "style" -> <||>,
        "class" -> {},
        "id" -> "",
        "text" -> "",
        "children" -> {},
        "props" -> <||>,
        "attributes" -> {}
    |>,
    <|
        (* renders a component into html format *)
        "render" -> Function[
            {sr, this},
            (
                stateRelationships = sr;
                out = "<" <> this["tag"] <> " ";
                
                (* format style association as CSS format *)
                If[Length[Keys[this["style"]]] > 0, (
                        out = out <> "style=\"";
                        
                        Do[
                            (
                                out = out <> styleName <> ": " <> ToString[this["style"][styleName]] <> "; ";
                            ),
                            {
                                styleName,
                                Keys[this["style"]]
                            }
                        ];
                        out = out <> "\" ";
                    )
                ];

                (* format class list as space-divided output *)
                If[Length[this["class"]] > 0, (
                    out = out <> "class=\"";
                    (
                        out = out <> # <> " ";
                    ) &/@ this["class"];
                    
                    out = out <> "\" ";
                )];

                (* handle props *)
                If[Length[Keys[this["props"]]] > 0, (
                    (
                        out = out <> # <> "=\"" <> 
                        If[
                            ToString[Head[this["props"][#]]] == "Instance" &&
                            StringLength[this["props"][#]["id"]] > 14 &&
                            StringTake[this["props"][#]["id"], 14] == "bound-graywolf",
                            (
                                (* if we have a bound variable for a prop *)

                                (* generate an id *)
                                If[this["id"] == "", (this["id"] = CreateUUID["graywolf"];)];

                                (* update state relationships by pushing this' id to the assoc value *)
                                stateRelationships = upsertRelationship[this["props"][#]["id"], {this["id"], this["tag"], #}, stateRelationships];

                                (* return the initial value of the bound variable *)
                                this["props"][#]["init"]
                            ),
                            this["props"][#]
                        ] <>
                        "\" ";
                    ) &/@ Keys[this["props"]];
                )];

                If[Length[this["attributes"]] > 0, (
                    (
                        out = out <> # <> " ";
                    ) &/@ this["attributes"];
                )];

                boundText = ToString[Head[this["text"]]] == "Instance" &&
                    StringLength[this["text"]["id"]] > 14 &&
                    StringTake[this["text"]["id"], 14] == "bound-graywolf";

                If[boundText,
                    (* generate an id *)
                    If[this["id"] == "", (this["id"] = CreateUUID["graywolf"];)];
                ];

                If[this["id"] != "",
                    out = out <> "id=\"" <> this["id"] <> "\" ";
                ];

                (* text content *)
                out = out <> ">\n" <>
                If[boundText,
                    (
                        (* if a bound variable for text *)

                        (* update state relationships by pushing this' id to the assoc value *)
                        stateRelationships = upsertRelationship[this["text"]["id"], {this["id"], this["tag"], "textContent"}, stateRelationships];

                        (* return the initial value of the bound variable *)
                        this["text"]["init"]
                    ),
                    this["text"]
                ] <> "\n";

                (* children *)
                (
                    (* out is impure upon recursion; warrants further investigation *)
                    preservedOut = out;
                    result = #["render", {stateRelationships}];
                    out = preservedOut <> result["html"] <> "\n";
                    stateRelationships = result["stateRelationships"];
                ) &/@ this["children"];

                (* close tag and return *)
                out = out <> "</" <> this["tag"] <> ">";

                New[RenderResponse, <|"html"->out, "stateRelationships"->stateRelationships|>]
            )
        ]
    |>
];

(* img is a component with a pre-determined tag, and an additional src field *)
Img := Extend[Component, 
    <|
        "tag"->"img",
        "src"->None
    |>,
    <|
        "render"->Function[
            {sr, this},
            (
                (* get image data in base64 *)
                srcString = "data:image/png;base64,"<>BaseEncode[ExportByteArray[this["src"], "PNG"]];
                (* call component render *)
                superRender = this["_super"]["render", {<||>}];
                (* insert base64 data *)
                New[RenderResponse, <|"html"->StringInsert[superRender["html"], " src=\""<>srcString<>"\"", 5], "stateRelationships"->sr|>]
            )
        ]
    |>
]

(* script is a component with a pre-determined tag, and an additional src field *)
Script := Extend[Component,
    <|
        "tag"->"script",
        "src"->""
    |>,
    <|
        "render"->Function[
            {sr, this},
            (
                (* render as a component and insert src file attribute *)
                superRender = this["_super"]["render", {<||>}];
                New[RenderResponse, <|"html"-> StringInsert[superRender["html"], " src=\""<>this["src"]<>"\"", 8], "stateRelationships"->sr|>]
            )
        ]
    |>
]

(* embed is a component that renders to a static string computed by wolfram *)
Embed := Extend[Component,
    <|
        "object"->Nothing
    |>,
    <|
        "render"->Function[
            {sr, this},
            (
                New[RenderResponse, <|"html"-> EmbedCode[this["object"]]["CodeSection"]["Content"], "stateRelationships"->sr|>]
            )
        ]
    |>
]

BRType := Extend[Component,
    <|
        "tag"->"iframe"
    |>,
    <|
        "render"->Function[
            {stateRelationships, this},
            (
                New[RenderResponse, <|"html" -> "<br>", "stateRelationships" -> stateRelationships|>]
            )
        ]
    |>
]

BR = New[BRType];