![Graywolf Banner](/images/graywolf-banner.png)

Graywolf is a lightweight web application framework for the Wolfram language.

## Installation

Install Wolfram Mathematica and Wolframscript. Then clone the repository

```bash
git clone https://github.com/muttaqi/GrayWolf.git
```

Bash into the graywolf folder and run requirements.sh

```bash
./requirements.sh
```

Finally, add the path to Graywolf.m as an environment variable called GW_DIR

```bash
export GW_DIR=/path/to/Graywolf.m
```

Also add Graywolf.m to your path variables.

## Usage

Load the GW_DIR environment variable and Graywolf.m into your Main.m Wolfram file

```mathematica
GWDir := Environment["GW_DIR"]

Import[GWDir <> "/Graywolf.m"]
```

```bash
Graywolf.m [folder]
```
See the example folder for an example project structure. The default port is localhost:58000.

## Future Plans

* Client-side statefulness
* URL parameter handling
* Database model interface