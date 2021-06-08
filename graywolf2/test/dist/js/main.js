window.addEventListener("load", function(){
    console.log("Hello world from JS!");

    Module.onRuntimeInitialized = () => {
        increment = Module.cwrap('increment', 'number', ['number']);
        console.log("From WASM: " + increment(1));
    }
});