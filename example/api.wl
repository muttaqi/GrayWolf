

var = "Hello world ";

text[]  :=  (

    s = "from the Wolfram Cloud!";
    var <> s
)


setanon3Text[] := text[];
APIHandler[func_] := Which[
func == "setanon3Text", setanon3Text[]];
Print[CloudDeploy[APIFunction[{"funcName"->"String"}, APIHandler[#funcName]&], "api", Permissions -> "Public"]]