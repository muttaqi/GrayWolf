(* ::Package:: *)

(* ::Input::Initialization:: *)
Execute[i_]:=i+1;

CloudDeploy[APIFunction[{"functionName"->"Number"}, Execute[#i]&],"compute", Permissions->"Public"]
