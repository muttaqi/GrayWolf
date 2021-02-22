(* ::Package:: *)
ClearAll["Global`*"]

Needs["CCodeGenerator`"];
Needs["CCompilerDriver`"];
Needs["SymbolicC`"];

SetDirectory[NotebookDirectory[]]

ClearAll[countArgs];
SetAttributes[countArgs,{HoldAll,Listable}];
countArgs[f_Symbol]:=With[{dv=DownValues[f]},countArgs[dv]];

countArgs[Verbatim[HoldPattern][HoldPattern[f_Symbol[args___]]]:>_]:=countArgs[f[args]];

countArgs[f_[Except[_Optional|_OptionsPattern|Verbatim[Pattern][_,_OptionsPattern]],rest___]]:={1,0,0}+countArgs[f[rest]];

countArgs[f_[o__Optional,rest___]]:={0,Length[HoldComplete[o]],0}+countArgs[f[rest]];

countArgs[f_[_OptionsPattern|Verbatim[Pattern][_,_OptionsPattern]]]:={0,0,1};

countArgs[f_[]]:={0,0,0};

Execute[i_]:=(
v :=i+1;
v
)

MatrixMultiply3x3[m1_,m2_] := (
	ValueAt[i_,j_]:=(
		m1[i, 1;;3] * m2[1 ;; 3, j]
	)

	Array[ValueAt, {3, 3}]
)

WolfrASM[f_] := (

	args = (Symbol["A"<>ToString[#]])&/@Range[countArgs[f][[1]][[1]]];
	cForm = CForm[Apply[f,args]];

	c=Compile[{args},f[args/.List->Squence]];
	cFile = CCodeGenerate[c,ToString[f],{}];

	cCode = ReadString[cFile];
	lines= StringSplit[cCode, "\n"];
	funcHeaderI = Position[lines, _?(StringContainsQ[#," "<>ToString[f]<>"("]&)][[1]][[1]];
	lines[[funcHeaderI]];
	funcHeader = StringSplit[lines[[funcHeaderI]], {"(", ","}];
	returnType = StringSplit[Last[funcHeader], " "][[1]];
	funcHeader[[1]] = StringReplace[funcHeader[[1]], "int"->returnType];
	funcHeader = Delete[funcHeader, {{2},{Length[funcHeader]}}];
	lines[[funcHeaderI]] = funcHeader[[1]] <> "(" <> StringRiffle[Drop[funcHeader,1], ","] <> ") {";
	lines = Take[lines, funcHeaderI];
	lines = Append[lines, "return " <> ToString[cForm] <> ";"];
	lines = Append[lines,"}"];
	lines = Delete[lines, Position[lines, _?(StringContainsQ[#,ToString[f]<>".h"]&)][[1]][[1]]];
	out = StringRiffle[lines, "\n"];

	s = OpenWrite["out.txt"];
	WriteString["out.txt",out];
	ReadString["out.txt"];
	CopyFile["out.txt", cFile, OverwriteTarget->True];
	ReadString[cFile];
	Close["out.txt"];
	s = "emcc \"" <> StringReplace[Directory[], "\\"->"/"] <> "/" <> ToString[cFile] <> "\" -o " <> StringReplace[Directory[], "\\"->"/"] <> "/function.html -s EXPORTED_FUNCTIONS='[\"_" <> ToString[f] <> "\"]' -s EXPORTED_RUNTIME_METHODS='[\"ccall\", \"cwrap\"]' -I\""<>StringReplace[$InstallationDirectory, "\\"->"/"] <> "/SystemFiles/IncludeFiles/C\"";
	s
)

(*WolfrASM[Execute]*)
(*
bashPath[path_]:= StringReplace[StringReplace[path, "C:\\"->"/mnt/host/c/"], "\\"->"/"];
allPaths = StringRiffle[bashPath /@Select[StringSplit[Environment["Path"], ";"],StringContainsQ[#, {"Python", "emsdk"}]&], ":"]

RunProcess["bash", All, "ls /mnt/host/c/Users/12265/AppData/Local/Programs/Python/Python38"]
RunProcess["bash.exe",  All, "export PATH=" <> allPaths <> " && python.exe && ./wolfrasm.sh " <> emPath <> " "<> ToString[f] <> " function.html " <> bashPath[$InstallationDirectory]]
*)