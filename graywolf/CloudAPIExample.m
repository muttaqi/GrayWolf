(* ::Package:: *)

(* ::Input::Initialization:: *)

MyDB=CloudGet["https://www.wolframcloud.com/obj/ca321619-bf2e-462a-bd6b-245bc3cdb83c"];

CloudDeploy[APIFunction[{"doc"->"String"}, MyDB[#doc]&],"api", Permissions->"Public"]
