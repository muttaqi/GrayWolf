//graywolf
function assocToJSON(assoc) {
    assoc.replace("{", "[");
    assoc.replace("}", "]");
    assoc.replace("<|", "{");
    assoc.replace("|>", "}");
    assoc.replace("->", ":");
    return assoc;
}

function httpGet(url, callback) {
    var proxyUrl = "https://cors-anywhere.herokuapp.com/";
    
    let headers = new Headers();

    headers.append('Content-Type', 'application/json');
    headers.append('Accept', 'application/json');
  
    headers.append('Access-Control-Allow-Origin', 'http://localhost:3000');
    headers.append('Access-Control-Allow-Credentials', 'true');
  
    fetch(proxyUrl + url, {headers: headers})
    .then(response => {
        
        console.log(response);
        return response.text();
    })
    .then(function(content) {
        console.log("24");
        console.log(content);
        callback(content);
    })
    .catch((e) => console.log("Can't access " + url + " response. " + e));
}

async function loadText() {

    await httpGet('https://www.wolframcloud.com/obj/33decoy330/api?doc=Doc1', function(res) {

        document.getElementById("text").textContent = res;
    });
}

async function loadCalc() {

    await httpGet('https://www.wolframcloud.com/obj/33decoy330/compute?i=1', function(res) {

        document.getElementById("calc").textContent = res;
    })
}

//controller
window.addEventListener('load', function() {

    loadText();
    loadCalc();
});