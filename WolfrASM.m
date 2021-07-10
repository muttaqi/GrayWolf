GWDir := Environment["GW_DIR"];

Import[GWDir <> "/Util.m"]
Import[GWDir <> "/Component.m"]

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

	args = (Symbol["A"<>ToString[#]])&/@Range[countArgs[f][[1]][[1]]];
	cForm = CForm[Apply[f,args]];

	c=Compile[{args},f[args/.List->Squence]];
	cFile = Quiet[CCodeGenerate[c, ToString[f], PathJoin[CurrentDirectory, "dist", "__wolfrasm__", ToString[f] <> ".c"]]];

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

	outFilePath = PathJoin[CurrentDirectory, "dist", "__wolfrasm__", "out.txt"];
	OpenWrite[outFilePath];
	WriteString[outFilePath, out];
	CopyFile[outFilePath, cFile, OverwriteTarget->True];
	Close[outFilePath];

	cFile
)

GenerateWASM[] := (
	If[
		DirectoryQ[PathJoin[CurrentDirectory, "dist", "__wolfrasm__"]],
		(
    		indexPath = PathJoin[CurrentDirectory, "dist", "index.html"];
			cFilesFolder = PathJoin[CurrentDirectory, "dist", "__wolfrasm__"];

			cFiles = FileNames["*.c", cFilesFolder];
			funcNames = (StringSplit[FileNameTake[#], ".c"][[1]]) &/@ cFiles;

			distFolder = PathJoin[CurrentDirectory, "dist"];
			If[
				Not[DirectoryQ[distFolder]],
				CreateDirectory[distFolder]
			];

			s = "emcc " <> PathJoin[cFilesFolder, "*.c"] <>
			" -o " <> PathJoin[distFolder, "wolfrasm.html"] <>
			" -s WASM=1 " <>
			" -s 'EXPORTED_FUNCTIONS=[\"_" <> StringRiffle[funcNames, "\",\"_"] <>
			"\"]' -s 'EXPORTED_RUNTIME_METHODS=[\"ccall\",\"cwrap\"]' -I\""<>
			StringReplace[$InstallationDirectory, "\\"->"/"] <> 
			"/SystemFiles/IncludeFiles/C\" --shell-file " <> 
			PathJoin[distFolder, "index.html"];

			proc = StartProcess["bash"];
			WriteLine[proc, s<>"\n"];
			WriteLine[proc, "mv " <> PathJoin[distFolder, "wolfrasm.html"] <> " " <> indexPath];
		)
	];
)

WolfrASMScript[functions_List] := (
	GenerateC[#] &/@ functions;
)

WolfrASMScript[function_] := WolfrASMScript[{function}];

WolfrASM[f_] := (
	GenerateC[f];
)
