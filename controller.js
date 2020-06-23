window.addEventListener('load', async function() {
await httpGet('?funcName=setanon0Text, function(res) {
document.getElementById("anon0".textContent = res
});
});