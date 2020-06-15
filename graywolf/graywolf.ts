function assocToJSON(assoc: string) {

    assoc.replace("{", "[");
    assoc.replace("}", "]");
    assoc.replace("<|", "{");
    assoc.replace("|>", "}");
    assoc.replace("->", ":");

    return assoc;
}

function httpGet(url: string, callback: Function) {

    var xmlHttp = new XMLHttpRequest();
    xmlHttp.onreadystatechange = function() {
        if (xmlHttp.readyState == 4 && xmlHttp.status == 200) {

            callback(xmlHttp.responseText);
        }
    }
    xmlHttp.open("GET", url, true);
    xmlHttp.send(null);
}