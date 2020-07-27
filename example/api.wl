(* ::Package:: *)

SetDirectory["C:/Users/12265/GrayWolf/src"];
Import["./GrayWolf.m"];
 
var = "Hello world ";

generateText[] := (

    s = "from the Wolfram Cloud!";
    var <> s
)

setanon3Text[] := (* WOLFRAM *) generateText[];
setimagesrc[] := BaseEncode[ExportByteArray[Graphics[Circle[]], "JPG"]];
APIHandler[func_] := Which[
func == "setanon3Text", setanon3Text[],
func == "setimagesrc", setimagesrc[]];
Print[CloudDeploy[APIFunction[{"funcName"->"String"}, APIHandler[#funcName]&], "api", Permissions -> "Public"]]