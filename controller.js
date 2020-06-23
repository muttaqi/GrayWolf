window.addEventListener('load', async function() {
});await httpGet('https://www.wolframcloud.com/obj/33decoy330/api?funcName=setanon0Text', function(res) {
document.getElementById("anon0").textContent = res;
});
