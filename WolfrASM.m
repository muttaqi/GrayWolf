GWDir := Environment["GW_DIR"];

Import[GWDir <> "/Util.m"]
Import[GWDir <> "/Component.m"]

CurrentDirectory = StringRiffle[Drop[StringSplit[ExpandFileName[First[$ScriptCommandLine]], "\\"], -1], "/"];

Needs["CCodeGenerator`"];
Needs["CCompilerDriver`"];
Needs["SymbolicC`"];

(* count args takes a function and determines how many arguments it accepts *)
ClearAll[countArgs];
SetAttributes[countArgs,{HoldAll,Listable}];
countArgs[f_Symbol]:=With[{dv=DownValues[f]},countArgs[dv]];
countArgs[Verbatim[HoldPattern][HoldPattern[f_Symbol[args___]]]:>_]:=countArgs[f[args]];
countArgs[f_[Except[_Optional|_OptionsPattern|Verbatim[Pattern][_,_OptionsPattern]],rest___]]:={1,0,0}+countArgs[f[rest]];
countArgs[f_[o__Optional,rest___]]:={0,Length[HoldComplete[o]],0}+countArgs[f[rest]];
countArgs[f_[_OptionsPattern|Verbatim[Pattern][_,_OptionsPattern]]]:={0,0,1};
countArgs[f_[]]:={0,0,0};

(* take a function and generate c code from it in the dist/__wolfrasm__ folder *)
GenerateC[f_] := (

	(* get args of a function as a list of variables A1, A2, ... *)
	args = (Symbol["A"<>ToString[#]])&/@Range[countArgs[f][[1]][[1]]];
	(* get the C form of the function *)
	cForm = CForm[Apply[f,args]];

	(* compile the C form to a c file in dist/__wolfrasm__ *)
	c=Compile[{args},f[args/.List->Squence]];
	cFile = Quiet[CCodeGenerate[c, ToString[f], PathJoin[CurrentDirectory, "dist", "__wolfrasm__", ToString[f] <> ".c"]]];

	(* read back compiled c file *)
	cCode = ReadString[cFile];
	lines= StringSplit[cCode, "\n"];

	(* mathematica code compiled to c doesn't return directly, but rather modifies a pointer. change this behaviour to directly return the output of the compiled function *)
	
	(* get func header *)
	funcHeaderI = Position[lines, _?(StringContainsQ[ToString[#]," "<>ToString[f]<>"("]&)][[1]][[1]];
	lines[[funcHeaderI]];
	funcHeader = StringSplit[lines[[funcHeaderI]], {"(", ","}];
	
	(* replace void with return type *)
	returnType = StringSplit[Last[funcHeader], " "][[1]];
	funcHeader[[1]] = StringReplace[funcHeader[[1]], "int"->returnType];
	funcHeader = Delete[funcHeader, {{2},{Length[funcHeader]}}];
	lines[[funcHeaderI]] = funcHeader[[1]] <> "(" <> StringRiffle[Drop[funcHeader,1], ","] <> ") {";

	(* add return statement*)
	lines = Take[lines, funcHeaderI];
	lines = Append[lines, "return " <> ToString[cForm] <> ";"];
	lines = Append[lines,"}"];

	(* remove function header include; this is incompatible with emcc *)
	lines = Delete[lines, Position[lines, _?(StringContainsQ[ToString[#],ToString[f]<>".h"]&)][[1]][[1]]];
	out = StringRiffle[lines, "\n"];

	(* output the modified c code to out.txt, then copy it to our original c file *)
	outFilePath = PathJoin[CurrentDirectory, "dist", "__wolfrasm__", "out.txt"];
	OpenWrite[outFilePath];
	WriteString[outFilePath, out];
	CopyFile[outFilePath, cFile, OverwriteTarget->True];
	Close[outFilePath];

	(* return the c file *)
	cFile
)

(* given a folder of wolfram functions compiled to c files, compile them to wasm *)
GenerateWASM[] := (
	If[
		DirectoryQ[PathJoin[CurrentDirectory, "dist", "__wolfrasm__"]],
		(
    		indexPath = PathJoin[CurrentDirectory, "dist", "index.html"];
			cFilesFolder = PathJoin[CurrentDirectory, "dist", "__wolfrasm__"];

			(* function names are the names of the c files *)
			cFiles = FileNames["*.c", cFilesFolder];
			funcNames = (StringSplit[FileNameTake[#], ".c"][[1]]) &/@ cFiles;

			distFolder = PathJoin[CurrentDirectory, "dist"];
			If[
				Not[DirectoryQ[distFolder]],
				CreateDirectory[distFolder]
			];

			(* compile all specified functions from the c files in the folder, using dist/index.html as a shell file *)
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
			(* write the output to wolfrasm.html *)
			WriteLine[proc, "mv " <> PathJoin[distFolder, "wolfrasm.html"] <> " " <> indexPath];
		)
	];
)

(* given a list of wolfram functions, generate the c code for it *)
WolfrASMScript[functions_List] := (
	GenerateC[#] &/@ functions;
)

WolfrASMScript[function_] := WolfrASMScript[{function}];

WolfrASM[f_] := (
	GenerateC[f];
)
