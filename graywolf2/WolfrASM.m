(* ::Package:: *)
ClearAll["Global`*"]

GWDir := Environment["GW_DIR"]

Import[GWDir <> "/Util.m"]

CurrentDirectory = StringRiffle[Drop[StringSplit[ExpandFileName[First[$ScriptCommandLine]], "\\"], -1], "/"];

Needs["CCodeGenerator`"];
Needs["CCompilerDriver`"];
Needs["SymbolicC`"];

ClearAll[countArgs];
SetAttributes[countArgs,{HoldAll,Listable}];
countArgs[f_Symbol]:=With[{dv=DownValues[f]},countArgs[dv]];

countArgs[Verbatim[HoldPattern][HoldPattern[f_Symbol[args___]]]:>_]:=countArgs[f[args]];

countArgs[f_[Except[_Optional|_OptionsPattern|Verbatim[Pattern][_,_OptionsPattern]],rest___]]:={1,0,0}+countArgs[f[rest]];

countArgs[f_[o__Optional,rest___]]:={0,Length[HoldComplete[o]],0}+countArgs[f[rest]];

countArgs[f_[_OptionsPattern|Verbatim[Pattern][_,_OptionsPattern]]]:={0,0,1};

countArgs[f_[]]:={0,0,0};

GenerateC[f_] := (
	Print[CurrentDirectory];

	args = (Symbol["A"<>ToString[#]])&/@Range[countArgs[f][[1]][[1]]];
	cForm = CForm[Apply[f,args]];

	c=Compile[{args},f[args/.List->Squence]];
	cFile = CCodeGenerate[c, ToString[f], PathJoin[CurrentDirectory, "__wolfrasm__", ToString[f] <> ".c"]];

	cCode = ReadString[cFile];
	lines= StringSplit[cCode, "\n"];
	funcHeaderI = Position[lines, _?(StringContainsQ[ToString[#]," "<>ToString[f]<>"("]&)][[1]][[1]];
	lines[[funcHeaderI]];
	funcHeader = StringSplit[lines[[funcHeaderI]], {"(", ","}];
	returnType = StringSplit[Last[funcHeader], " "][[1]];
	funcHeader[[1]] = StringReplace[funcHeader[[1]], "int"->returnType];
	funcHeader = Delete[funcHeader, {{2},{Length[funcHeader]}}];
	lines[[funcHeaderI]] = funcHeader[[1]] <> "(" <> StringRiffle[Drop[funcHeader,1], ","] <> ") {";
	lines = Take[lines, funcHeaderI];
	lines = Append[lines, "return " <> ToString[cForm] <> ";"];
	lines = Append[lines,"}"];
	lines = Delete[lines, Position[lines, _?(StringContainsQ[ToString[#],ToString[f]<>".h"]&)][[1]][[1]]];
	out = StringRiffle[lines, "\n"];

	outFilePath = PathJoin[CurrentDirectory, "__wolfrasm__", "out.txt"];
	OpenWrite[outFilePath];
	WriteString[outFilePath, out];
	CopyFile[outFilePath, cFile, OverwriteTarget->True];
	Close[outFilePath];

	cFile
)

GenerateWASM[] := (
	If[
		DirectoryQ[PathJoin[CurrentDirectory, "__wolfrasm__"]],
		(
			cFilesFolder = PathJoin[CurrentDirectory, "__wolfrasm__"];

			cFiles = FileNames["*.c", cFilesFolder];
			funcNames = (StringSplit[FileNameTake[#], ".c"][[1]]) &/@ cFiles;

			wolfrasmFolder = PathJoin[CurrentDirectory, "wolfrasm"];
			If[
				Not[DirectoryQ[wolfrasmFolder]],
				CreateDirectory[wolfrasmFolder]
			];

			s = "emcc " <> PathJoin[cFilesFolder, "*.c"] <> " -o " <> PathJoin[wolfrasmFolder, "wolfrasm.html"] <> " -s 'EXPORTED_FUNCTIONS=[\"_" <> StringRiffle[funcNames, "\",\"_"] <> "\"]' -s 'EXPORTED_RUNTIME_METHODS=[\"ccall\",\"cwrap\"]' -I\""<>StringReplace[$InstallationDirectory, "\\"->"/"] <> "/SystemFiles/IncludeFiles/C\"";
			Print[s];

			proc = StartProcess["bash"];
			WriteLine[proc, s<>"\n"];
			WriteLine[proc, "rm -r " <> cFilesFolder <> "\n"];
			While[
				DirectoryQ[cFilesFolder],
				Pause[1]
			];
		)
	];
)

WolfrASM[f_] := (

	cFile = GenerateC[f];
)
