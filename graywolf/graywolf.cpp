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

string controller, view, functions, apiLink;
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
        isFunctionHeader = false, 
        isFunctionBody = false, 
        isApp = false,
        isComponent = false;
    string functionHeader;

    string currentProp, currentComponent, app;
    
    ifstream src (argv[0]);
    
    if (src.is_open()) {

        while(src.get(in)) {

            //check if app started
            if (!isApp) {

                functions += in;
                int l = functions.length();

                if (
                    (!isComment && !isString && l >= 5 && functions.substr(l - 4, 4) == "App[" && isspace(functions.at(l - 5))) ||
                    (functions == "App[")
                ) {

                    isApp = true;
                    functions = functions.substr(0, l - 4);
                    brackets.push('[');
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

            //otherwise handle functions
            if (!isComment && in == '(' && src.peek() == '*') {

                isComment = true;
            }

            else if (in == '\"') {

                isString = !isString;
            }

            functions += in;
            continue;
        }
    }

    src.close();

    list<Component> tree = buildComponents(app);

    controller += "window.addEventListener(\'load\', async function() {\n";
    //adds to global view and controller strings
    buildViewAndController(tree);
    controller += "});";
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

                        functions += "set" + c.getProps()["id"] + prop.first + " := " + prop.second + "\n";
                        controller += "await httpGet(\'" + apiLink + "?funcName=set" + c.getProps()["id"] + prop.first + ", function(res) {\n"
                        + "document.getElementById(\"" + c.getProps()["id"] + "\".textContent = res" + "\n"
                        + "});\n";
                        view += prop.first + "=" + "\"\"\n";
                    }
                }
            }
        }

        view += ">\n";

        for (Component c : c.getChildren()) {

            buildViewAndController(c);
        }

        view += "</" + c.getName() + ">\n";
    }
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