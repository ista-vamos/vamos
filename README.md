# VAMOS

VAMOS is a framework containing libraries and a set of tools for monitoring
heterogeneous asynchronous events sources. Events are efficiently transferred
via concurrent buffers in the shared memory.

The current developement version can be found in the branch `dev`. Code in the `main` branch may be highly outdated. If you cannot find something that you  think should be here, write to <mchqwerty (at) gmail (dot) com>.

## Build:

You can use the `setup.sh` script for a fast set-up

```
# git clone ...
cd vamos
python -m venv venv/
source venv/bin/activate

./setup.sh
```

For a more detailed build with more control over things, you can build everything manually:

```
# git clone ...
cd vamos
python -m venv venv/
source venv/bin/activate

make [OPTIONS]
```

`OPTIONS` may include:
 - `BUILD_TYPE=[Debug|Release|RelWithDebInfo]` the type of build to pass to cmake
 - `LLVM_SOURCES=OFF` to turn off building event sources based on instrumentation of LLVM
 - `DYNAMORIO_SOURCES=OFF` to turn off building event sources based on DynamoRIO
 - `DynamoRIO_DIR=<path/to/dynamorio/cmake>` to use a particular DynamoRIO build
 - `TESSLA_SUPPORT=[ON|OFF]` enable support for TeSSLa monitors

The used OPTIONS are stored into `Makefile.config` and re-used in future `make`
runs. If you want to change the options, either delete the file or change
values in there and run `make reconfigure && make` or `make reset && make`
(warning: the latter will completely clean repositories, including all files
that are not under git).


## Using

Run `source venv/bin/activate` from the top-level directory and then run the desired script
from one of the sub-repositories. The sub-repositories have their own READMEs.

## Components

 - `vamos-buffers`  implementation of shared memory buffers used to transfer events
 - `vamos-common`   common parts shared by multiple VAMOS repositories (mostly python packages)
 - `vamos-sources`  implementation of tracing various standard events in programs (event sources)
                    and a specification language for that
 - `vamos-compiler` a compiler of the legacy VAMOS specifications
 - `vamos-monitors` manually written monitors, mostly for debugging and testing purposes
 - `vamos-mpt`      a compiler for multi-trace prefix transducers

