

var = "here is some ";

text[]  :=  (

    s = "cloud generated text";
    var <> s
)


setanon0Text := text[];
APIHandler[func_] := Which[
func == "setanon0Text", setanon0Text[]];
Print[CloudDeploy[APIFunction[{"funcName"->"String"}, APIHandler[#funcName]&], "api", Permissions -> "Public"]]