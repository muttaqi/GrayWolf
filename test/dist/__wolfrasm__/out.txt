#include "math.h"

#include "WolframRTL.h"

static WolframCompileLibrary_Functions funStructCompile;

static void * E0 = 0;


static mbool initialize = 1;


DLLEXPORT int Initialize_func(WolframLibraryData libData)
{
if( initialize)
{
funStructCompile = libData->compileLibraryFunctions;
{
E0 = funStructCompile->getExpressionFunctionPointer(libData, "Hold[Function[List[args$], func[ReplaceAll[args$, Rule[List, Squence]]]]]");
}
if( E0 == 0)
{
return LIBRARY_FUNCTION_ERROR;
}
initialize = 0;
}
return 0;
}

DLLEXPORT void Uninitialize_func(WolframLibraryData libData)
{
if( !initialize)
{
initialize = 1;
}
}

DLLEXPORT mreal func( mreal A1) {
return 1 + A1;
}