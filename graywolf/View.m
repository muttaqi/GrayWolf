(* ::Package:: *)

(* ::Input::Initialization:: *)
(*$Messages={};
a:=0;
b:=0;
s:={{5,30},{1,Infinity}};

View[d_]:=Deploy[d];
LinearView[content_,style_]:=View[
Style@@Join[{
(*Panel@@Join[{*)
Grid@@Join[content,ItemSize\[Rule]Fit,Alignment\[Rule]Center,style["Grid"]]
(*},style["Panel"]]*)
},style["View"]]
];

MyView=LinearView[{{
Framed[Style["Home","MenuStyle"],FrameMargins\[Rule]{{1,1},{20,20}},FrameStyle\[Rule]None],
Framed[Style["About","MenuStyle"],FrameMargins\[Rule]{{1,1},{20,20}},FrameStyle\[Rule]None],
Framed[Style["Docs","MenuStyle"],FrameMargins\[Rule]{{1,1},{20,20}},FrameStyle\[Rule]None]
}},
<|"Grid"\[Rule]{Background\[Rule]Red, Spacings\[Rule]{0,100}},
"Panel"\[Rule]{DefaultOptions\[Rule]{InputField\[Rule]{ContinuousAction\[Rule]True,FieldSize\[Rule]s}},ImageMargins\[Rule]0},
"View"\[Rule]{}|>];
app=View[MyView]

MyView=LinearView[{{Style["input a number",Red],InputField[Dynamic[a],Number]},{Style["input another number",Red],InputField[Dynamic[b],Number]},{"here is their sum",InputField[Dynamic[a+b],Enabled\[Rule]False]},{"their difference",InputField[Dynamic[a-b],Enabled\[Rule]False]},{"their product",InputField[Dynamic[a*b],Enabled\[Rule]False]}},DefaultOptions\[Rule]{InputField\[Rule]{ContinuousAction\[Rule]True,FieldSize\[Rule]s}}];

app=DynamicModule[{a=a,b=b,s=s},MyView];*)

(*app=DynamicModule[{a=0,b=0,s={{5,30},{1,Infinity}}},Deploy[Style[Panel[Grid[Transpose[{{Style["input a number",Red],Style["input another number",Red],"here is their sum","their difference","their product"},{InputField[Dynamic[a],Number],InputField[Dynamic[b],Number],InputField[Dynamic[a+b],Enabled\[Rule]False],InputField[Dynamic[a-b],Enabled\[Rule]False],InputField[Dynamic[a b],Enabled\[Rule]False]}}],Alignment\[Rule]Right],ImageMargins\[Rule]10],DefaultOptions\[Rule]{InputField\[Rule]{ContinuousAction\[Rule]True,FieldSize\[Rule]s}}]]];
app=DynamicModule[{},Dynamic[x],SaveDefinitions\[Rule]True,Initialization\[RuleDelayed](x=CloudExpression["test"][])]*)

StringifyProps[props_]:=(
ret="";
l=Length[Keys[props]];
For[i=1,i<=l,i++,
ret=ret<>" "<>Keys[props][[i]]<>"="<>props[Keys[props][[i]]]
];
ret
);
StringifyChildren[children_]:=(
ret="";
l=Length[children];
For[i=1,i<=l,i++,
ret=ret<>Stringify[children[[i]]]
];
ret
);
Stringify[a[props_,children_,text_]]:="<a"<>StringifyProps[props]<>">"<>StringifyChildren[children]<>text<>"</a>";
Stringify[html[props_,children_,text_]]:="<html"<>StringifyProps[props]<>">"<>StringifyChildren[children]<>text<>"</html>";
Stringify[body[props_,children_,text_]]:="<body"<>StringifyProps[props]<>">"<>StringifyChildren[children]<>text<>"</body>";
Stringify[br[props_,children_,text_]]:="<br"<>StringifyProps[props]<>">"<>StringifyChildren[children]<>text<>"</br>";
Stringify[head[props_,children_,text_]]:="<head"<>StringifyProps[props]<>">"<>StringifyChildren[children]<>text<>"</head>";
Stringify[title[props_,children_,text_]]:="<title"<>StringifyProps[props]<>">"<>StringifyChildren[children]<>text<>"</title>";
Stringify[h1[props_,children_,text_]]:="<h1"<>StringifyProps[props]<>">"<>StringifyChildren[children]<>text<>"</h1>";
Stringify[p[props_,children_,text_]]:="<p"<>StringifyProps[props]<>">"<>StringifyChildren[children]<>text<>"</p>";
Stringify[img[props_,children_,text_]]:="<img"<>StringifyProps[props]<>">"<>StringifyChildren[children]<>text<>"</img>";
Stringify[b[props_,children_,text_]]:="<b"<>StringifyProps[props]<>">"<>StringifyChildren[children]<>text<>"</b>";
Stringify[ul[props_,children_,text_]]:="<ul"<>StringifyProps[props]<>">"<>StringifyChildren[children]<>text<>"</ul>";
Stringify[li[props_,children_,text_]]:="<li"<>StringifyProps[props]<>">"<>StringifyChildren[children]<>text<>"</li>";
Stringify[div[props_,children_,text_]]:="<div"<>StringifyProps[props]<>">"<>StringifyChildren[children]<>text<>"</div>";
Stringify[hr[props_,children_,text_]]:="<hr"<>StringifyProps[props]<>">"<>StringifyChildren[children]<>text<>"</hr>";
Stringify[header[props_,children_,text_]]:="<header"<>StringifyProps[props]<>">"<>StringifyChildren[children]<>text<>"</header>";
Stringify[footer[props_,children_,text_]]:="<footer"<>StringifyProps[props]<>">"<>StringifyChildren[children]<>text<>"</footer>";

Stringify[
a[
<|"k1"->"v1", "k2"->"v2"|>,
{},
"text"
]
]
