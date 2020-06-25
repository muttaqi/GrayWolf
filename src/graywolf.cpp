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

class Component {

    private:
                        //boolean stores whether the value is a function or not
    unordered_map<string, string> props;
    list<Component> children;
    string name;
    string text = "";

    public:

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

    string outPath = "";
    string flag = "";
    if (argc == 4) {

        flag = argv[2];
    }

    if (flag == "-o") {

        outPath = argv[3];
    }

    char in, next;
    string acc = "";
    stack<char> brackets;
    bool isComment = false, 
        isString = false, 
        isFunctionBody = false, 
        isApp = false,
        isComponent = false;
    string functionHeader = "";

    string currentProp, currentComponent;
    
    ifstream src (argv[1]);
    
    if (src.is_open()) {

        while(src.get(in)) {

            //otherwise handle functions
            if (!isComment && !isString && in == '(' && src.peek() == '*') {

                src.get(in);
                isComment = true;
                continue;
            }

            if (isComment && in == '*' && src.peek() == ')') {

                src.get(in);
                isComment = false;
                continue;
            }

            if (isComment) {

                continue;
            }

            if (in == '\"') {
                
                if (isApp) {
                    
                    app += in;
                }

                else {

                    acc += in;
                }

                isString = !isString;
                continue;
            }

            if (isString) {

                if (isApp) {

                    app += in;
                }

                else {

                    acc += in;
                }
                continue;
            }

            //check if app started
            if (!isApp) {

                string tempAcc = acc;
                tempAcc += in;
                int l = tempAcc.length();

                if (
                    (!isComment && !isString && l >= 5 && tempAcc.substr(l - 4, 4) == "App[" && isspace(tempAcc.at(l - 5))) ||
                    (tempAcc == "App[")
                ) {

                    isApp = true;
                    brackets.push('[');
                    acc = "";
                    continue;
                }
            }

            //load in app
            if (isApp) {

                if (in == ']') {

                    brackets.pop();
                    if (brackets.size() == 0) {

                        isApp = false;
                    }

                    else {
                        
                        app += in;
                    }
                    continue;
                }

                else if (in == '[') {

                    brackets.push('[');
                    app += in;
                    continue;
                }

                else {

                    app += in;
                    continue;
                }
            }

            if (in == ':' && src.peek() == '=') {
                
                if (acc.find_first_of('[') != string::npos && acc.find_first_of(']') != string::npos) {

                    src.get(in);

                    functionHeader = acc;
                    isFunctionBody = true;
                    acc = "";
                    continue;
                }

                acc += in;
                continue;
            }

            if ((in == ';' || in == '\n') && brackets.size() == 0) {

                if (isFunctionBody) {

                    acc += in;
                    apiFuncsAndVars += functionHeader + " := " + acc;
                    functionHeader = "";

                    isFunctionBody = false;
                }

                else {

                    acc += in;
                    apiFuncsAndVars += acc;
                }
                acc = "";
                continue;
            }

            if (isOpening(in)) {

                acc += in;
                brackets.push(in);
                continue;
            }

            if (isClosing(in) && brackets.top() == flip(in)) {

                acc += in;
                brackets.pop();
                continue;
            }
            
            acc += in;
        }
    }

    src.close();

    list<Component> tree = buildComponents();

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

    apiLink = apiLink.substr(12, apiLink.length() - 14);

    ifstream utilF ("bin/util.js", std::ifstream::in);

    if (utilF.is_open()) {
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

list<Component> buildComponents() {

    list<Component> l;

    unordered_map<string, string> props;
    list<Component> children;
    string componentName = "";
    string componentText = "";

    string propertyName = "";
    string propertyVal = "";

    bool isPropertyName = false;
    bool isPropertyVal = false;
    bool isComponentName = false;
    bool isComment = false;
    stack<char> brackets;

    while(appI < app.size()) {

        char c = app[appI];

        if (c == '{') {

            if (isPropertyName) {

                propertyName += c;
            }

            else if (isPropertyVal) {

                propertyVal += c;
            }

            else {

                isComponentName = true;
            }
        }

        else if (c == '}' && isComponentName) {
            
            while (app[appI] != ',' && appI < app.length()) {

                appI ++;
            }
            appI ++;

            return l;
        }

        else if (c == '[') {

            if (isComponentName) {

                isPropertyName = true;
                isPropertyVal = false;
                isComponentName = false;
            }

            else if (isPropertyName) {

                propertyName += c;
            }

            else if (isPropertyVal) {

                propertyVal += c;
            }

            brackets.push('[');
        }

        else if (c == ']') {

            if (brackets.size() == 1) {

                if (isPropertyName) {

                    componentText = trim(propertyName);
                    propertyName = "";
                }

                else if (isPropertyVal) {

                    props[trim(propertyName)] = trim(propertyVal);
                    propertyName = "";
                    propertyVal = "";
                }

                Component newComponent;
                
                newComponent.setProps(props);
                newComponent.setName(trim(componentName));
                newComponent.setChildren(children);
                newComponent.setText(trim(componentText));

                l.push_back(newComponent);

                props.clear();
                componentName = "";
                componentText = "";
                propertyName = "";
                propertyVal = "";
                children.clear();

                isComponentName = true;
                isPropertyName = false;
                isPropertyVal = false;
            }

            else if (isPropertyName) {

                propertyName += c;
            }

            else if (isPropertyVal) {

                propertyVal += c;
            }
            brackets.pop();
        }

        else if (c == '-' && app.length() >= appI + 2 && app[appI + 1] == '>') {

            appI ++;
            isPropertyVal = true;
            isPropertyName = false;
            isComponentName = false;

            if (trim(propertyName) == "children") {
                
                children = buildComponents();

                Component newComponent;
                
                newComponent.setProps(props);
                newComponent.setName(trim(componentName));
                newComponent.setChildren(children);
                newComponent.setText(trim(componentText));

                l.push_back(newComponent);

                props.clear();
                componentName = "";
                componentText = "";
                propertyName = "";
                propertyVal = "";
                children.clear();

                isComponentName = true;
                isPropertyName = false;
                isPropertyVal = false;
            }
        }

        else if (c == ',') {

            if (isPropertyName && brackets.size() == 1) {

                componentText = trim(propertyName);
                propertyName = "";
            }

            else if (isPropertyVal && brackets.size() == 1) {

                props[trim(propertyName)] = trim(propertyVal);
                propertyName = "";
                propertyVal = "";
            }

            isPropertyName = true;
            isPropertyVal = false;
            isComponentName = false;
        }

        else if (isComponentName) {

            componentName += c;
        }

        else if (isPropertyName) {

            propertyName += c;
        }

        else if (isPropertyVal) {

            propertyVal += c;
        }

        appI ++;
    }

    return l;
}

list<Component> buildViewAndFunctions(list<Component> tree) {

    list<Component> newTree;

    for (auto it = tree.begin(); it != tree.end(); it ++) {

        view += "<" + it->getName() + "\n";

        if (it->getProps()["id"] == "") {
            
            it->setProp("id", "\"anon" + to_string(anonIncrement) + "\"");
            anonIncrement++;
        }
        
        view += "id = " + it->getProps()["id"] + "\n";
        
        for (pair<string, string> prop : it->getProps()) {
            
            if (prop.first != "id") {
            
                //check if just a string val
                if (charCount(prop.second, '\"') == 2 && prop.second.find_first_of('\"') == 0 && prop.second.find_last_of('\"') == prop.second.length() - 1) {

                    view += prop.first + "=" + prop.second + "\n";
                }
                
                else {

                    if (it->getProps()["id"] != "") {

                        Function newFunc;
                        newFunc.setHeader("set" + it->getProps()["id"] + prop.first);
                        newFunc.setBody(prop.second + "\n");
                        functions.push_back(newFunc);

                        view += prop.first + "=" + "\"\"\n";
                    }
                }
            }
        }

        view += ">\n";

        //same as above but for text
        if (charCount(it->getText(), '\"') == 2 && it->getText().find_first_of('\"') == 0 && it->getText().find_last_of('\"') == it->getText().length() - 1) {

            view += it->getText().substr(1, it->getText().length() - 2) + "\n";
        }
        
        else if (it->getText() != "") {

            if (it->getProps()["id"] != "") {

                Function newFunc;
                newFunc.setHeader("set" + it->getProps()["id"].substr(1, it->getProps()["id"].length() - 2) + "Text");
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
                if (!(
                    charCount(prop.second, '\"') == 2 && prop.second.find_first_of('\"') == 0 && prop.second.find_last_of('\"') == prop.second.length() - 1
                )) {

                    if (c.getProps()["id"] != "") {

                        controller += "await httpGet(\'" + apiLink + "?funcName=set" + c.getProps()["id"].substr(1, c.getProps()["id"].length() - 2) + prop.first + ", function(res) {\n"
                        + "document.getElementById(\"" + c.getProps()["id"].substr(1, c.getProps()["id"].length() - 2) + "\".textContent = res" + "\n"
                        + "});\n";
                    }
                }
            }
        }

        //same as above but for text
        if (!(
            charCount(c.getText(), '\"') == 2 && c.getText().find_first_of('\"') == 0 && c.getText().find_last_of('\"') == c.getText().length() - 1
        ) && c.getText() != ""
        ) {

            if (c.getProps()["id"] != "") {

                controller += "await httpGet(\'" + apiLink + "?funcName=set" + c.getProps()["id"].substr(1, c.getProps()["id"].length() - 2) + "Text\', function(res) {\n"
                + "document.getElementById(\"" + c.getProps()["id"].substr(1, c.getProps()["id"].length() - 2) + "\").textContent = res;\n"
                + "});\n";
            }
        }

        buildController(c.getChildren());
    }
}