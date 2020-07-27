![Graywolf Banner](/images/graywolf-banner.png)

Graywolf is a lightweight web application framework for the Wolfram language.

## Installation

Simply clone the repository, and use the bin folder for the needed commands

```bash
git clone https://github.com/muttaqi/GrayWolf.git
```

## Usage

In your notebook/editor:

```mathematica
SetDirectory["PATH_TO_SRC/src"];
Import["./GrayWolf.m"];
```

Build your app, then compile your code:

```bash
graywolf MyApp/app.m -o MyApp
```

An example app can be found under the 'example' folder.

## Why use GrayWolf?

GrayWolf lets you:
* Build complex views through a powerful templating engine
* Serve views through your choice of server, or none at all
* Generate optimized server request code for your controller
* Compile Wolfram code with a simple and instant CLI
* Build progressive web apps with high performance
* Leverage Wolfram's knowledge base for visuals
* Use Wolfram's powerful notebook IDE to develop code
 
## Architecture

![GrayWolf Architecure](/images/architecture.png)

## Restrictions

There are a few restrictions to be followed for the compiler to work:
* Only atomic functions with no stateful parameters can be used, and only for components with ids (thus, no event properties yet)
* No function can be named ApiHandler

I am working towards lifting most of these restrictions.

## Future Plans

Here are some features I am currently working on implementing:
* API variable handling
* Stateful views and variable binding
* Secure APIs through authorization middleware
* Model interface for cloud databases