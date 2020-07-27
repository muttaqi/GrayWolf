#include <stdlib.h>
#include <iostream>
#include <fstream>
#include <stack>
#include <unordered_map>
#include <list>
#include <tuple>
#include <string>
#include <stdio.h>
#include <stdexcept>
#include <sstream>
#include "dist/json/json.h"
#include "dist/jsoncpp.cpp"
using namespace std;

const std::string WHITESPACE = " \n\r\t\f\v";

class Function {

    private:

    string header, body;

    public:

    void setHeader(string h) {

        header = h;
    }

    void setBody(string b) {

        body = b;
    }

    string getHeader() {

        return header;
    }

    string getBody() {

        return body;
    }

    string toString() {

        return "Function(header: " + header + "\n" +
        "body: " + body + ")\n";
    }
};

bool isWolfram(string s) {

    if (s.length() <= 13) {

        return 0;
    }

    return s.substr(0, 13) == "(* WOLFRAM *)";
}

class Component {

    private:
                        //boolean stores whether the value is a function or not
    unordered_map<string, string> props;
    list<Component> children;
    string name;
    string text = "";

    public:

    void buildFromJSON(Json::Value tree) {

        for (auto rule = tree.begin(); rule != tree.end(); ++rule) {

            if (rule.key().asString() == "textContent") {
                
                text = (*rule).asString();
            }

            else if (rule.key().asString() == "name") {
                
                name = (*rule).asString();
            }

            else if (rule.key().asString() == "children") {

                for (int i = 0; i < (*rule).size(); i ++) {

                    Component newC;
                    newC.buildFromJSON((*rule)[i]);
                    children.push_back(newC);
                }
            }

            else {
                
                props[rule.key().asString()] = (*rule).asString();
            }
        }
    }

    void addProp(string name, string val) {

        props[name] = val;
    }

    void setProps(unordered_map<string, string> map) {

        props = map;
    }

    void setProp(string name, string val) {

        props[name] = val;
    }

    void addChild(Component c) {

        children.push_back(c);
    }

    void setChildren(list<Component> list) {

        children = list;
    }

    void setName(string s) {

        name = s;
    }

    void setText(string s) {

        text = s;
    }

    unordered_map<string, string> getProps() {
        
        return props;
    }

    list<Component> getChildren() {

        return children;
    }

    string getName() {

        return name;
    }

    string getText() {

        return text;
    }

    string toString() {

        string ret = "Component(name: " + name + "\n";
        ret += "text: " + text + "\n";

        for (pair<string, string> prop : props) {

            ret += prop.first + ": " + prop.second + "\n";
        }

        ret += "children: [\n";

        for (Component c : children) {

            ret += c.toString();
        }

        ret += "]\n";
        ret += ")\n";

        return ret;
    }
};

static void printchar(unsigned char theChar) {

    switch (theChar) {

        case '\n':
            printf("\\n");
            break;
        case '\r':
            printf("\\r");
            break;
        case '\t':
            printf("\\t");
            break;
        default:
            if ((theChar < 0x20) || (theChar > 0x7f)) {
                printf("\\%03o", (unsigned char)theChar);
            } else {
                printf("%c", theChar);
            }
        break;
   }
}

std::string ltrim(const std::string& s)
{
	size_t start = s.find_first_not_of(WHITESPACE);
	return (start == std::string::npos) ? "" : s.substr(start);
}

std::string rtrim(const std::string& s)
{
	size_t end = s.find_last_not_of(WHITESPACE);
	return (end == std::string::npos) ? "" : s.substr(0, end + 1);
}

std::string trim(const std::string& s)
{
	return rtrim(ltrim(s));
}

bool isOpening(char in) {

    return
    in == '[' || 
    in == '(';
}

bool isClosing(char in) {

    return
    in == ']' || 
    in == ')' ;
}

char flip(char c) {

    switch(c) {

        case '[':
            return ']';
        case '(':
            return ')';
        case '{':
            return '}';
        case '<':
            return '>';
        case ']':
            return '[';
        case ')':
            return '(';
        case '}': 
            return '{';
        case '>':
            return '<';
    }
}

int charCount(string s, char c) {

    int ret = 0;

    for (string::size_type i = 0; i < s.size(); i ++) {

        char sC = s[i];
        if (sC == c) {

            ret ++;
        }
    }

    return ret;
}

string exec(string command) {
   char buffer[128];
   string result = "";

   // Open pipe to file
   FILE* pipe = _popen(command.c_str(), "r");
   if (!pipe) {
      return "popen failed!";
   }

   // read till end of process:
   while (!feof(pipe)) {

      // use buffer to read and add to result
      if (fgets(buffer, 128, pipe) != NULL)
         result += buffer;
   }

   _pclose(pipe);
   return result;
}

int findAppI(string s) {

    int i = 0;
    int out = 0;
    while(i < s.length() - 4) {
        
        if (s.substr(i, 4) == "App[") {

            out = i;
        }

        i++;
    }

    return out;
}

list<Component> buildComponents();
list<Component> buildViewAndFunctions(list<Component> tree);
void buildAPI();
void buildController(list<Component> tree);

//                      these four are in the cloud, while apiLink is the link to the cloud API
string app, controller, view, apiFuncsAndVars, apiHandler, apiDeployer, apiLink;
list<Function> functions;
int anonIncrement = 0;
string::size_type appI = 0;

/**
 * expected:
 * argc: 1
 * argv: [src_file_path]
 **/
void main (int argc, char *argv[]) {

    if (argc > 4) {

        printf("Too many arguments provided. Please only provide a source .m file");
        return;
    }

    if (argc == 1) {

        printf("Please provide a source .m file");
        return;
    }

    string srcName = argv[1];
    if (srcName.length() < 3 || srcName.substr(srcName.length() - 2, 2) != ".m") {

        printf("Please provide a source .m file");
        return;
    }

    string binPrepend = argv[0];
    int lastSlash = binPrepend.find_last_of("\\");

    if (lastSlash != string::npos) {

        binPrepend = binPrepend.substr(0, lastSlash + 1);
    }

    else {

        binPrepend = "";
    }

    string outPath = "";
    string flag = "";
    if (argc == 4) {

        flag = argv[2];
    }

    if (flag == "-o") {

        outPath = argv[3];
    }
    
    string src = argv[1];
    string app = exec(
        "cat " + src
    );

    int appI = findAppI(app);

    if (appI != string::npos) {

        app = app.substr(0, appI) + "Print[\n" + app.substr(appI, app.length()) + "\n]";
    }

    apiFuncsAndVars += app.substr(0, appI);

    ofstream appScript;

    appScript.open("app.wl");
    appScript << app;
    appScript.close();

    cout << "398\n";

    string json = exec(
        "wolframscript -file app.wl"
    );

    cout << "404 " << json << " \n";

    Json::Value root;
    Json::Reader reader;

    bool parsingSuccess = reader.parse(json.c_str(), root);

    cout << "409\n";
    if (!parsingSuccess) {

        cout << "Failed" << reader.getFormatedErrorMessages();
        return;
    }

    list<Component> tree;

    Json::Value jsonTree = root.get("app", "DNE");
    
    for (int i = 0; i < jsonTree.size(); i ++) {

        Component newC;
        newC.buildFromJSON(jsonTree[i]);
        cout << "413" + newC.toString() << "\n";
        tree.push_back(newC);
    }

    exec(
        "rm app.wl"
    );

    //adds to global view and functions variables
    tree = buildViewAndFunctions(tree);

    //adds to global apiFunctions, apiHandler and api strings (apiVariables is already set up at this point)
    buildAPI();

    ofstream viewF, controllerF, apiF;

    if (outPath != "") {
        
        viewF.open(outPath + "/index.html");
        controllerF.open(outPath + "/controller.js");

        apiF.open(outPath + "/api.wl");
        apiF << apiFuncsAndVars + apiHandler + apiDeployer;
        apiF.close();

        apiLink = exec(
            "wolframscript -file " + outPath + "/api.wl"
        );
    }

    else {
        viewF.open(outPath + "index.html");
        controllerF.open(outPath + "controller.js");

        apiF.open("api.wl");

        apiF << apiFuncsAndVars + apiHandler + apiDeployer;

        apiF.close();


        apiLink = exec(
            "wolframscript -file api.wl"
        );
    }

    viewF << view;
    viewF.close();

    if (apiLink.length() < 13 || apiLink.substr(0, 12) != "CloudObject[") {

        cout << "Deploying API failed. Aborting compilation.\n";
        return;
    }
    cout << "API deployed: " + apiLink;

    apiLink = apiLink.substr(12, apiLink.length() - 14);

    ifstream utilF (binPrepend + "util.js", std::ifstream::in);
    if (utilF.is_open()) {

        cout << binPrepend << "util.js" << "\n";

        std::stringstream utilBuffer;
        utilBuffer << utilF.rdbuf();
        
        controller += utilBuffer.str() + "\n";
    }

    controller += "window.addEventListener(\'load\', async function() {\n";
    //writes to global controller string
    buildController(tree);
    controller += "});";

    controllerF << controller;

    controllerF.close();
}

list<Component> buildViewAndFunctions(list<Component> tree) {

    list<Component> newTree;

    for (auto it = tree.begin(); it != tree.end(); it ++) {

        view += "<" + it->getName() + "\n";

        //add some arbitrary id if not set
        if (it->getProps()["id"] == "") {
            
            it->setProp("id", "anon" + to_string(anonIncrement));
            anonIncrement++;
        }
        
        view += "id = " + it->getProps()["id"] + "\n";
        
        for (pair<string, string> prop : it->getProps()) {
            
            if (prop.first != "id") {
            
                //check if just a string val
                if (!isWolfram(prop.second)) {

                    view += prop.first + "=\"" + prop.second + "\"\n";
                }

                //check if an image source
                else if (it->getName() == "img" && prop.first == "src") {
                    
                    Function newFunc;
                    newFunc.setHeader("set" + it->getProps()["id"] + prop.first);
                    newFunc.setBody("BaseEncode[ExportByteArray[" + prop.second.substr(14, prop.second.length()) + ", \"JPG\"]]");
                    functions.push_back(newFunc);

                    view += prop.first + "=" + "\"\"\n";
                }
                
                else {

                    //at this point id is already set
                    Function newFunc;
                    newFunc.setHeader("set" + it->getProps()["id"] + prop.first);
                    newFunc.setBody(prop.second.substr(14, prop.second.length()) + "\n");
                    functions.push_back(newFunc);

                    view += prop.first + "=" + "\"\"\n";
                }
            }
        }

        view += ">\n";

        //same as above but for text
        if (!isWolfram(it->getText())) {

            view += it->getText() + "\n";
        }
        
        else if (it->getText() != "") {

            if (it->getProps()["id"] != "") {

                Function newFunc;
                newFunc.setHeader("set" + it->getProps()["id"] + "Text");
                newFunc.setBody(it->getText() + "\n");
                functions.push_back(newFunc);
            }
        }

        it->setChildren(buildViewAndFunctions(it->getChildren()));

        view += "</" + it->getName() + ">\n";

        newTree.push_back(*it);
    }

    return newTree;
}

void buildAPI() {

    apiHandler += "APIHandler[func_] := Which[\n";

    apiDeployer += "Print[CloudDeploy[APIFunction[{\"funcName\"->\"String\"}, APIHandler[#funcName]&], \"api\", Permissions -> \"Public\"]]";

    for (Function f : functions) {

        apiFuncsAndVars += f.getHeader() + "[] := " + trim(f.getBody()) + ";\n";

        //                                              get rid of the [] at the end of the header
        apiHandler += "func == \"" + trim(f.getHeader()) + "\", " + trim(f.getHeader()) + "[],\n";
    }

    if (functions.size() > 0) {
    
        apiHandler = apiHandler.substr(0, apiHandler.length() - 2);
    }

    apiHandler += "];\n";
}

void buildController(list<Component> tree) {

    for (Component c : tree) {
        
        for (pair<string, string> prop : c.getProps()) {

            if (prop.first != "id") {
            
                //check if just a string val
                if (isWolfram(prop.second)) {

                    if (c.getProps()["id"] != "") {

                        //check if image src
                        if (c.getName() == "img" && prop.first == "src") {
                            
                            controller += "await httpGet(\'" + apiLink + "?funcName=set" + c.getProps()["id"] + prop.first + "\', function(res) {\n"
                            + "document.getElementById(\"" + c.getProps()["id"] + "\")." + prop.first + " = \"data:image/png;base64,\" + res.substring(1, res.length - 1);\n"
                            + "});\n";
                        }

                        else {

                            controller += "await httpGet(\'" + apiLink + "?funcName=set" + c.getProps()["id"] + prop.first + "\', function(res) {\n"
                            + "document.getElementById(\"" + c.getProps()["id"] + "\")." + prop.first + " = res\n"
                            + "});\n";
                        }
                    }
                }
            }
        }

        //same as above but for text
        if (isWolfram(c.getText()) && c.getText() != "") {

            if (c.getProps()["id"] != "") {

                controller += "await httpGet(\'" + apiLink + "?funcName=set" + c.getProps()["id"] + "Text\', function(res) {\n"
                + "document.getElementById(\"" + c.getProps()["id"] + "\").textContent = res;\n"
                + "});\n";
            }
        }

        buildController(c.getChildren());
    }
}