#include "wstp.h"
#include <stdlib.h>
#include <iostream>
#include <fstream>
#include <stack>
#include <unordered_map>
#include <list>
#include <tuple>
#include <string>
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
};

class Component {

    private:
                        //boolean stores whether the value is a function or not
    unordered_map<string, string> props;
    list<Component> children;
    string name;

    public:

    void addProp(string name, string val) {

        props[name] = val;
    }

    void setProps(unordered_map<string, string> map) {

        props = map;
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

    unordered_map<string, string> getProps() {
        
        return props;
    }

    list<Component> getChildren() {

        return children;
    }

    string getName() {

        return name;
    }
};
//                      these four are in the cloud, while apiLink is the link to the cloud API
string controller, view, apiFunctions, apiVariables, apiHandler, api, apiLink;
list<Function> functions;
int anonIncrement = 0;

/**
 * expected:
 * argc: 1
 * argv: [src_file_path]
 **/
int main (int argc, char *argv[]) {

    if (argc == 0) {

        printf("Please provide a source .m file");
        return;
    }

    else if (argc > 1) {

        printf("Too many arguments provided. Please only provide a source .m file");
        return;
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

    string currentProp, currentComponent, app;
    
    ifstream src (argv[0]);
    
    if (src.is_open()) {

        while(src.get(in)) {

            //otherwise handle functions
            if (!isComment && in == '(' && src.peek() == '*') {

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
                
                acc += in;
                isString = !isString;
                continue;
            }

            if (isString) {

                acc += in;
                continue;
            }

            //check if app started
            if (!isApp) {

                acc += in;
                int l = acc.length();

                if (
                    (!isComment && !isString && l >= 5 && acc.substr(l - 4, 4) == "App[" && isspace(acc.at(l - 5))) ||
                    (acc == "App[")
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
                    Function newFunc;
                    newFunc.setHeader(functionHeader);
                    newFunc.setBody(acc);
                    functions.push_back(newFunc);

                    isFunctionBody = false;
                }

                else {

                    acc += in;
                    apiVariables += acc;
                }
                acc = "";
                continue;
            }

            if (isOpening(in)) {

                acc += in;
                brackets.push(in);
                continue;
            }

            if (isClosing(in) && brackets.top() == in) {

                acc += in;
                brackets.pop();
                continue;
            }
            
            acc += in;
        }
    }

    src.close();

    list<Component> tree = buildComponents(app);

    controller += "window.addEventListener(\'load\', async function() {\n";
    //adds to global view and controller strings
    buildViewAndController(tree);
    controller += "});";

    //adds to global apiFunctions, apiHandler and api strings (apiVariables is already set up at this point)
    buildAPI();

    ofstream viewF, controllerF, apiF;
    viewF.open("index.html");
    controllerF.open("controller.js");
    apiF.open("api.wls");

    viewF << view;
    controllerF << controller;
    apiF << apiVariables + apiFunctions + apiHandler + api;

    viewF.close();
    controllerF.close();
    apiF.close();
}

list<Component> buildComponents(string in) {

    list<Component> l;

    unordered_map<string, string> props;
    list<Component> children;
    string componentName = "";

    string propertyName = "";
    string propertyVal = "";

    bool isPropertyName = false;
    bool isPropertyVal = false;
    bool isComponentName = false;
    bool isComment = false;
    stack<char> brackets;

    for (string::size_type i = 0; i < in.size(); i ++) {

        char c = in[i];

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

        else if (c == '[') {

            if (isComponentName) {

                isPropertyName = true;
                isPropertyVal = false;
                isComponentName = false;
            }

            brackets.push('[');
        }

        else if (c == ']') {

            if (brackets.size() == 1) {

                Component newComponent;
                
                newComponent.setProps(props);
                newComponent.setName(componentName);
                newComponent.setChildren(children);

                l.push_back(newComponent);

                props.clear();
                componentName = "";
                children.clear();

                isComponentName = true;
                isPropertyName = false;
                isPropertyVal = false;
            }
            brackets.pop();
        }

        else if (c == '-' && in.length() >= i + 2 && in[i + 1] == '>') {

            i ++;
            isPropertyVal = false;
            isPropertyName = false;
            isComponentName = false;

            if (propertyName == "children") {

                int closingBracket = in.find_last_of(']');
                int len = closingBracket - i;
                string newIn = in.substr(i, len);
                
                children = buildComponents(newIn);
            }
        }

        else if (c == ',') {

            if (brackets.size() == 1) {

                isPropertyName = true;
                isPropertyVal = false;
                isComponentName = false;

                props[propertyName] = propertyVal;
            }
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
    }

    return l;
}

void buildViewAndController(list<Component> tree) {

    for (Component c : tree) {

        view += "<" + c.getName() + "\n";

        if (c.getProps()["id"] != "") {

            view += "id = " + c.getProps()["id"] + "\n";
        }
        
        for (pair<string, string> prop : c.getProps()) {
            
            if (prop.first != "id") {
            
                //check if just a string val
                if (count(prop.second.begin(), prop.second.end(), '\"') == 2 && prop.second.find_first_of('\"') == 0 && prop.second.find_last_of('\"') == prop.second.length() - 1) {


                    view += prop.first + "=" + prop.second + "\n";
                }
                
                else {

                    if (c.getProps()["id"] != "") {

                        Function newFunc;
                        newFunc.setHeader("set" + c.getProps()["id"] + prop.first);
                        newFunc.setBody(prop.second + "\n");
                        functions.push_back(newFunc);

                        controller += "await httpGet(\'" + apiLink + "?funcName=set" + c.getProps()["id"] + prop.first + ", function(res) {\n"
                        + "document.getElementById(\"" + c.getProps()["id"] + "\".textContent = res" + "\n"
                        + "});\n";
                        view += prop.first + "=" + "\"\"\n";
                    }
                }
            }
        }

        view += ">\n";

        buildViewAndController(c.getChildren());

        view += "</" + c.getName() + ">\n";
    }
}

void buildAPI() {

    apiHandler += "APIHandler[func_] := Which[\n";

    api += "CloudDeploy[APIFunction[{\"funcName\"->\"String\"}, APIHandler[#funcName]&], \"api\", Permissions -> \"Public\"]";

    for (Function f : functions) {

        apiFunctions += f.getHeader() + " := " + f.getBody();
        //                                              get rid of the [] at the end of the header
        apiHandler += "func == \"" + trim(f.getHeader()).substr(0, f.getHeader().length() - 2) + "\", " + trim(f.getHeader()) + ",\n";
    }

    apiHandler += "];\n";
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