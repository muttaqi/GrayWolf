//graywolf.js
function assocToJSON(assoc) {
    assoc.replace("{", "[");
    assoc.replace("}", "]");
    assoc.replace("<|", "{");
    assoc.replace("|>", "}");
    assoc.replace("->", ":");
    return assoc;
}
function httpGet(url, callback) {
    var xmlHttp = new XMLHttpRequest();
    xmlHttp.onreadystatechange = function () {
        if (xmlHttp.readyState == 4 && xmlHttp.status == 200) {
            callback(xmlHttp.responseText);
        }
    };
    xmlHttp.open("GET", url, true);
    xmlHttp.send(null);
}

window.addEventListener('load', async function() {
await httpGet('https://www.wolframcloud.com/obj/INSERT_USER_HERE/api?funcName=setanon3Text', function(res) {
document.getElementById("anon3").textContent = res;
});
});