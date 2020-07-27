(* ::Package:: *)

SetDirectory["C:/Users/12265/GrayWolf/.reference"];
Import["../src/GrayWolf.m"];
 
var = "Hello world ";

generateText[] := (

    s = "from the Wolfram Cloud!";
    var <> s
)

generateImage[] := Graphics[Circle[]];

setanon3Text[] := (* WOLFRAM *) generateText[];
setimagesrc[] := BaseEncode[ExportByteArray[generateImage[], "JPG"]];
APIHandler[func_] := Which[
func == "setanon3Text", setanon3Text[],
func == "setimagesrc", setimagesrc[]];
Print[CloudDeploy[APIFunction[{"funcName"->"String"}, APIHandler[#funcName]&], "api", Permissions -> "Public"]]