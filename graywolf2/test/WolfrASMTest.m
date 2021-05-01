#!wolframscript

Import["WolfrASM.m"]

func[x_] := x + 1;

gunc[y_] := y - 1;

GenerateC[func];
GenerateWASM[];