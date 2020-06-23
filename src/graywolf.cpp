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
    std::string name, text;

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

list<Component> buildComponents(string in);
void buildViewAndController(list<Component> tree);
void buildAPI();

//                      these four are in the cloud, while apiLink is the link to the cloud API
string controller, view, apiFuncsAndVars, apiHandler, apiDeployer, apiLink;
list<Function> functions;
int anonIncrement = 0;

/**
 * expected:
 * argc: 1
 * argv: [src_file_path]
 **/
void main (int argc, char *argv[]) {
    
    if (argc == 1) {

        printf("Please provide a source .m file");
        return;
    }

    else if (argc > 2) {

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
    
    ifstream src (argv[1]);
    
    if (src.is_open()) {

        while(src.get(in)) {

            printchar(in);
            printf(": ");

            //otherwise handle functions
            if (!isComment && !isString && in == '(' && src.peek() == '*') {

                printf("comment start\n");

                src.get(in);
                isComment = true;
                continue;
            }

            if (isComment && in == '*' && src.peek() == ')') {

                printf("comment end\n");

                src.get(in);
                isComment = false;
                continue;
            }

            if (isComment) {

                printf("comment skip\n");

                continue;
            }

            if (in == '\"') {

                printf("string togg\n");
                
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

                printf("string cont\n");

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

                if (l >= 5) {
                    
                    printf("\n checking isapp: ");
                    cout << tempAcc.substr(l - 4, 4);
                    printf("\n");
                }

                if (
                    (!isComment && !isString && l >= 5 && tempAcc.substr(l - 4, 4) == "App[" && isspace(tempAcc.at(l - 5))) ||
                    (tempAcc == "App[")
                ) {

                    printf("app start\n");

                    isApp = true;
                    brackets.push('[');
                    acc = "";
                    continue;
                }
            }

            //load in app
            if (isApp) {

                printf("app loading\n");

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

                    printf("function head done\n");

                    src.get(in);

                    functionHeader = acc;
                    isFunctionBody = true;
                    acc = "";
                    continue;
                }

                printf("var");

                acc += in;
                continue;
            }

            if ((in == ';' || in == '\n') && brackets.size() == 0) {

                if (isFunctionBody) {

                    printf("function body done\n");

                    acc += in;
                    Function newFunc;
                    newFunc.setHeader(functionHeader);
                    newFunc.setBody(acc);
                    functions.push_back(newFunc);
                    apiFuncsAndVars += functionHeader + " := " + acc;
                    functionHeader = "";

                    isFunctionBody = false;
                }

                else {

                    printf("var done\n");

                    acc += in;
                    apiFuncsAndVars += acc;
                }
                acc = "";
                continue;
            }

            if (isOpening(in)) {

                printf("bracket add\n");

                acc += in;
                brackets.push(in);
                continue;
            }

            if (isClosing(in) && brackets.top() == flip(in)) {

                printf("bracket remove\n");

                acc += in;
                brackets.pop();
                continue;
            }

            printf("regular load\n");
            
            acc += in;
        }
    }

    src.close();

    printf("%s\n", app);

    list<Component> tree = buildComponents(app);

    for (Component c : tree) {

        cout << c.toString();
    }

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
    apiF << apiFuncsAndVars + apiHandler + apiDeployer;

    viewF.close();
    controllerF.close();
    apiF.close();
}

list<Component> buildComponents(string in) {

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

    for (string::size_type i = 0; i < in.size(); i ++) {

        char c = in[i];

        printf("%c: ", c);

        if (c == '{') {

            if (isPropertyName) {

                printf("loading property name");

                propertyName += c;
            }

            else if (isPropertyVal) {

                printf("loading property val");

                propertyVal += c;
            }

            else {

                printf("starting component name");

                isComponentName = true;
            }
        }

        else if (c == '}' && isComponentName) {
            
            printf("RETURNING\n");
            return l;
        }

        else if (c == '[') {

            if (isComponentName) {

                printf("starting property name");

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

                    printf("closing text");

                    componentText = trim(propertyName);
                    propertyName = "";
                }

                else if (isPropertyVal) {

                    printf("closing property, starting next");

                    props[trim(propertyName)] = trim(propertyVal);
                    propertyName = "";
                    propertyVal = "";
                }

                printf("starting component name");

                Component newComponent;
                
                newComponent.setProps(props);
                newComponent.setName(trim(componentName));
                newComponent.setChildren(children);
                newComponent.setText(trim(componentText));

                l.push_back(newComponent);

                props.clear();
                componentName = "";
                componentText = "";
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

        else if (c == '-' && in.length() >= i + 2 && in[i + 1] == '>') {

            i ++;
            isPropertyVal = true;
            isPropertyName = false;
            isComponentName = false;

            if (trim(propertyName) == "children") {

                printf("starting children with ");

                int closingBracket = in.find_last_of(']');
                int len = closingBracket - i;
                string newIn = in.substr(i, len);

                cout << newIn;
                
                children = buildComponents(newIn);

                

                printf("starting component name");

                Component newComponent;
                
                newComponent.setProps(props);
                newComponent.setName(trim(componentName));
                newComponent.setChildren(children);
                newComponent.setText(trim(componentText));

                l.push_back(newComponent);

                props.clear();
                componentName = "";
                componentText = "";
                children.clear();

                return l;
            }
        }

        else if (c == ',') {

            if (isPropertyName && brackets.size() == 1) {

                printf("closing text");

                componentText = trim(propertyName);
                propertyName = "";
            }

            else if (isPropertyVal && brackets.size() == 1) {

                printf("closing property, starting next");

                props[trim(propertyName)] = trim(propertyVal);
                propertyName = "";
                propertyVal = "";
            }

            isPropertyName = true;
            isPropertyVal = false;
            isComponentName = false;
        }

        else if (isComponentName) {

            printf("loading component name");

            componentName += c;
        }

        else if (isPropertyName) {

            printf("loading property name");

            propertyName += c;
        }

        else if (isPropertyVal) {

            printf("loading property val");

            propertyVal += c;
        }

        printf("\n");
    }

    return l;
}

void buildViewAndController(list<Component> tree) {

    for (Component c : tree) {

        view += "<" + c.getName() + "\n";

        if (c.getProps()["id"] == "") {
            
            c.setProp("id", "\"anon" + to_string(anonIncrement) + "\"");
        }
        
        view += "id = " + c.getProps()["id"] + "\n";

        cout << "building view for: " << c.toString() << "\n";
        
        for (pair<string, string> prop : c.getProps()) {
            
            if (prop.first != "id") {
            
                //check if just a string val
                if (charCount(prop.second, '\"') == 2 && prop.second.find_first_of('\"') == 0 && prop.second.find_last_of('\"') == prop.second.length() - 1) {

                    view += prop.first + "=" + prop.second + "\n";
                }
                
                else {

                    if (c.getProps()["id"] != "") {

                        cout << "function for id: " << c.getProps()["id"] << "\n";

                        Function newFunc;
                        newFunc.setHeader("set" + c.getProps()["id"] + prop.first);
                        newFunc.setBody(prop.second + "\n");
                        functions.push_back(newFunc);

                        controller += "await httpGet(\'" + apiLink + "?funcName=set" + c.getProps()["id"].substr(1, c.getProps()["id"].length() - 2) + prop.first + ", function(res) {\n"
                        + "document.getElementById(\"" + c.getProps()["id"].substr(1, c.getProps()["id"].length() - 2) + "\".textContent = res" + "\n"
                        + "});\n";
                        view += prop.first + "=" + "\"\"\n";
                    }
                }
            }
        }

        view += ">\n";

        //same as above but for text
        if (charCount(c.getText(), '\"') == 2 && c.getText().find_first_of('\"') == 0 && c.getText().find_last_of('\"') == c.getText().length() - 1) {

            cout << "773 " << c.getText() << "\n";

            view += c.getText() + "\n";
        }
        
        else {

            cout << "780 " << c.getText() << "\n";

            if (c.getProps()["id"] != "") {

                cout << "function for id: " << c.getProps()["id"] << "\n";

                Function newFunc;
                newFunc.setHeader("set" + c.getProps()["id"] + "Text");
                newFunc.setBody(c.getText() + "\n");
                functions.push_back(newFunc);

                controller += "await httpGet(\'" + apiLink + "?funcName=set" + c.getProps()["id"].substr(1, c.getProps()["id"].length() - 2) + "Text, function(res) {\n"
                + "document.getElementById(\"" + c.getProps()["id"].substr(1, c.getProps()["id"].length() - 2) + "\".textContent = res" + "\n"
                + "});\n";
            }
        }

        buildViewAndController(c.getChildren());

        view += "</" + c.getName() + ">\n";
    }
}

void buildAPI() {

    apiHandler += "APIHandler[func_] := Which[\n";

    apiDeployer += "CloudDeploy[APIFunction[{\"funcName\"->\"String\"}, APIHandler[#funcName]&], \"api\", Permissions -> \"Public\"]";

    for (Function f : functions) {

        cout << f.toString() << "\n";
        //                                              get rid of the [] at the end of the header
        apiHandler += "func == \"" + trim(f.getHeader()).substr(0, f.getHeader().length() - 2) + "\", " + trim(f.getHeader()) + ",\n";
    }

    apiHandler += "];\n";
}