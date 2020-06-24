![Graywolf Banner](/images/graywolf-banner.png)

Graywolf is a lightweight web application framework for the Wolfram language.

## Installation

Simply clone the repository, and use the bin folder for the needed commands

```bash
git clone https://github.com/muttaqi/GrayWolf.git
```

## Usage

```bash
graywolf app.m
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

![GrayWolf Architecure](/images/graywolf-architecture.png)

## Restrictions

There are a few simple restrictions for the compiler to work:
* Children must be the last member of a component's association list
* String based properties only
* No '(*', '*)', '[', ']', or '->' can be present in a string in the app *tree
* Only atomic functions with no stateful parameters can be used, and only for components with ids (thus, no event properties yet)
* No empty ids, or ids of the form 'AnonX' where X is an integer
* No function can be named ApiHandler

I am working towards lifting most of these restrictions.