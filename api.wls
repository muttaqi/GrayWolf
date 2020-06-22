var = "here is some ";

text[]  :=  (

    s = "cloud generated text";
    var <> s
)

APIHandler[func_] := Which[
func == "text[", text[],
];
CloudDeploy[APIFunction[{"funcName"->"String"}, APIHandler[#funcName]&], "api", Permissions -> "Public"]