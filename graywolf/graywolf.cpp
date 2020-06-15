#include "wstp.h"
#include <stdlib.h>
#include <iostream>
#include <fstream>
#include <stack>
#include <unordered_map>
#include <list>
using namespace std;

class Component {

    private:
    unordered_map<string, string> props;
    list<Component> children;

    void addProp(string name, string val) {

        props[name] = val;
    }

    void addChild(Component c) {

        children.push_back(c);
    }

    unordered_map<string, string> getProps() {
        
        return props;
    }

    list<Component> getChildren() {

        return children;
    }
};

string controller, view;

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

    string currentProp, currentComponent,
        functions, app;
    
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
                    app += "App[";
                    brackets.push('[');
                    continue;
                }
            }

            //load in app
            if (isApp) {

                if (in == ']') {

                    brackets.pop();
                    if (brackets.size() == 0) {

                        app += in;
                        isApp = false;
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

    Component tree = buildComponent(app);
    //adds to global view and controller strings
    buildViewAndController(tree);
}

Component buildComponent(string app) {

    Component c;



    return c;
}

void buildViewAndController(Component tree) {


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