

var = "Hello world ";

text[]  :=  (

    s = "from the Wolfram Cloud!";
    var <> s
)


setanon3Text[] := text[];
setimagesrc[] := BaseEncode[ExportByteArray[Graphics[Circle[]], "JPG"]];
APIHandler[func_] := Which[
func == "setanon3Text", setanon3Text[],
func == "setimagesrc", setimagesrc[]];
Print[CloudDeploy[APIFunction[{"funcName"->"String"}, APIHandler[#funcName]&], "api", Permissions -> "Public"]]