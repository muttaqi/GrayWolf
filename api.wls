

var = "here is some ";

text[]  :=  (

    s = "cloud generated text";
    var <> s
)


APIHandler[func_] := Which[
func == "text[", text[],
func == "set"anon0"Te", set"anon0"Text,
];
CloudDeploy[APIFunction[{"funcName"->"String"}, APIHandler[#funcName]&], "api", Permissions -> "Public"]