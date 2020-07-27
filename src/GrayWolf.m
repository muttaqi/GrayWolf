(* ::Package:: *)

ClearAll["Global`*"]

strip[_[x__]] := x;

GenerateJSON[tag_]:=(
	out = "{\n";
				
	Do[
		If[ToString[Head[r]]=="RuleDelayed",
			out = out <> "\"" <> ToString[r[[1]]] <> "\": \"(* WOLFRAM *)" <> StringSplit[ToString[r], ":>"][[2]] <> "\",\n",
			If[ToString[r[[1]]]=="children",
				out = out <> "\"children\": [\n" <> StringDrop[StringRiffle[r[[2]]], -2] <> "],\n", 
				out = out <> "\"" <> ToString[r[[1]]] <> "\": \"" <> r[[2]] <> "\",\n"]],
		{r, strip[tag]}
	];
	
	If[Length[tag]>0,
		out = StringDrop[out, -2]
	];
	
	out = out <> "},\n";
	
	Return[out];
);

p[props__]:=GenerateJSON[FullForm[List[name->"p", props]]];

param[props__]:=GenerateJSON[FullForm[List[name->"param", props]]];

head[props__]:=GenerateJSON[FullForm[List[name->"head", props]]];

html[props__]:=GenerateJSON[FullForm[List[name->"html", props]]];

meta[props__]:=GenerateJSON[FullForm[List[name->"meta", props]]];

title[props__]:=GenerateJSON[FullForm[List[name->"title", props]]];

style[props__]:=GenerateJSON[FullForm[List[name->"style", props]]];

applet[props__]:=GenerateJSON[FullForm[List[name->"applet", props]]];

br[props__]:=GenerateJSON[FullForm[List[name->"br", props]]];

frame[props__]:=GenerateJSON[FullForm[List[name->"frame", props]]];

frameset[props__]:=GenerateJSON[FullForm[List[name->"frameset", props]]];

iframe[props__]:=GenerateJSON[FullForm[List[name->"iframe", props]]];

basefont[props__]:=GenerateJSON[FullForm[List[name->"basefont", props]]];

center[props__]:=GenerateJSON[FullForm[List[name->"center", props]]];

dir[props__]:=GenerateJSON[FullForm[List[name->"dir", props]]];

font[props__]:=GenerateJSON[FullForm[List[name->"font", props]]];

menu[props__]:=GenerateJSON[FullForm[List[name->"menu", props]]];

strike[props__]:=GenerateJSON[FullForm[List[name->"strike", props]]];

u[props__]:=GenerateJSON[FullForm[List[name->"u", props]]];

abbr[props__]:=GenerateJSON[FullForm[List[name->"abbr", props]]];

acronym[props__]:=GenerateJSON[FullForm[List[name->"acronym", props]]];

address[props__]:=GenerateJSON[FullForm[List[name->"address", props]]];

b[props__]:=GenerateJSON[FullForm[List[name->"b", props]]];

big[props__]:=GenerateJSON[FullForm[List[name->"big", props]]];

blockquote[props__]:=GenerateJSON[FullForm[List[name->"blockquote", props]]];

body[props__]:=GenerateJSON[FullForm[List[name->"body", props]]];

caption[props__]:=GenerateJSON[FullForm[List[name->"caption", props]]];

cite[props__]:=GenerateJSON[FullForm[List[name->"cite", props]]];

code[props__]:=GenerateJSON[FullForm[List[name->"code", props]]];

col[props__]:=GenerateJSON[FullForm[List[name->"col", props]]];

colgroup[props__]:=GenerateJSON[FullForm[List[name->"colgroup", props]]];

dd[props__]:=GenerateJSON[FullForm[List[name->"dd", props]]];

del[props__]:=GenerateJSON[FullForm[List[name->"del", props]]];

dfn[props__]:=GenerateJSON[FullForm[List[name->"dfn", props]]];

div[props__]:=GenerateJSON[FullForm[List[name->"div", props]]];

dl[props__]:=GenerateJSON[FullForm[List[name->"dl", props]]];

dt[props__]:=GenerateJSON[FullForm[List[name->"dt", props]]];

em[props__]:=GenerateJSON[FullForm[List[name->"em", props]]];

fieldset[props__]:=GenerateJSON[FullForm[List[name->"fieldset", props]]];

form[props__]:=GenerateJSON[FullForm[List[name->"form", props]]];

hn[props__]:=GenerateJSON[FullForm[List[name->"hn", props]]];

h1[props__]:=GenerateJSON[FullForm[List[name->"h1", props]]];

h2[props__]:=GenerateJSON[FullForm[List[name->"h2", props]]];

h3[props__]:=GenerateJSON[FullForm[List[name->"h3", props]]];

h4[props__]:=GenerateJSON[FullForm[List[name->"h4", props]]];

h5[props__]:=GenerateJSON[FullForm[List[name->"h5", props]]];

h6[props__]:=GenerateJSON[FullForm[List[name->"h6", props]]];

img[props__]:=GenerateJSON[FullForm[List[name->"img", props]]];

ins[props__]:=GenerateJSON[FullForm[List[name->"ins", props]]];

kbd[props__]:=GenerateJSON[FullForm[List[name->"kbd", props]]];

li[props__]:=GenerateJSON[FullForm[List[name->"li", props]]];

link[props__]:=GenerateJSON[FullForm[List[name->"link", props]]];

map[props__]:=GenerateJSON[FullForm[List[name->"map", props]]];

noframes[props__]:=GenerateJSON[FullForm[List[name->"noframes", props]]];

noscript[props__]:=GenerateJSON[FullForm[List[name->"noscript", props]]];

ol[props__]:=GenerateJSON[FullForm[List[name->"ol", props]]];

optgroup[props__]:=GenerateJSON[FullForm[List[name->"optgroup", props]]];

option[props__]:=GenerateJSON[FullForm[List[name->"option", props]]];

p[props__]:=GenerateJSON[FullForm[List[name->"p", props]]];

pre[props__]:=GenerateJSON[FullForm[List[name->"pre", props]]];

q[props__]:=GenerateJSON[FullForm[List[name->"q", props]]];

samp[props__]:=GenerateJSON[FullForm[List[name->"samp", props]]];

small[props__]:=GenerateJSON[FullForm[List[name->"small", props]]];

span[props__]:=GenerateJSON[FullForm[List[name->"span", props]]];

strong[props__]:=GenerateJSON[FullForm[List[name->"strong", props]]];

sub[props__]:=GenerateJSON[FullForm[List[name->"sub", props]]];

sup[props__]:=GenerateJSON[FullForm[List[name->"sup", props]]];

table[props__]:=GenerateJSON[FullForm[List[name->"table", props]]];

tbody[props__]:=GenerateJSON[FullForm[List[name->"tbody", props]]];

td[props__]:=GenerateJSON[FullForm[List[name->"td", props]]];

tfoot[props__]:=GenerateJSON[FullForm[List[name->"tfoot", props]]];

th[props__]:=GenerateJSON[FullForm[List[name->"th", props]]];

thead[props__]:=GenerateJSON[FullForm[List[name->"thead", props]]];

tr[props__]:=GenerateJSON[FullForm[List[name->"tr", props]]];

tt[props__]:=GenerateJSON[FullForm[List[name->"tt", props]]];

ul[props__]:=GenerateJSON[FullForm[List[name->"ul", props]]];

label[props__]:=GenerateJSON[FullForm[List[name->"label", props]]];

legend[props__]:=GenerateJSON[FullForm[List[name->"legend", props]]];

object[props__]:=GenerateJSON[FullForm[List[name->"object", props]]];

select[props__]:=GenerateJSON[FullForm[List[name->"select", props]]];

a[props__]:=GenerateJSON[FullForm[List[name->"a", props]]];

area[props__]:=GenerateJSON[FullForm[List[name->"area", props]]];

button[props__]:=GenerateJSON[FullForm[List[name->"button", props]]];

input[props__]:=GenerateJSON[FullForm[List[name->"input", props]]];

textarea[props__]:=GenerateJSON[FullForm[List[name->"textarea", props]]];

script[props__]:=GenerateJSON[FullForm[List[name->"script", props]]];

App[tree_]:=(
	out = "{\n \"app\": [\n";
	
	Do[
		out = out <> tag,
		{tag, tree}
	];
	
	If[Length[tree] > 0,
		out = StringDrop[out, -2]];
	
	out = out <> "]\n}\n";
	
	Return[out];
)        
