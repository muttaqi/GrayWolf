#!wolframscript

PathJoin[names__] := (
    StringReplace[FileNameJoin[List[names]], "\\"->"/"]
);