# VAMOS

VAMOS is a framework containing libraries and a set of tools for monitoring
heterogeneous asynchronous events sources. Events are efficiently transferred
via concurrent buffers in the shared memory.

The current developement version can be found in the branch `dev`. Code in this branch my be highly outdated.

## Build:

```
make [OPTIONS]
```

`OPTIONS` may include:
 - `BUILD_TYPE=[Debug|Release|RelWithDebInfo]` the type of build to pass to cmake
 - `DYNAMORIO_SOURCES=OFF` to turn off building event sources based on DynamoRIO
 - `DynamoRIO_DIR=<path/to/dynamorio/cmake>` to use a particular DynamoRIO build
 - `TESSLA_SUPPORT=[ON|OFF]` enable support for TeSSLa monitors

The used OPTIONS are stored into `Makefile.config` and re-used in future `make`
runs. If you want to change the options, either delete the file or change
values in there and run `make reconfigure && make` or `make reset && make`
(warning: the latter will completely clean repositories, including all files
that are not under git).

## Components

 - `vamos-buffers`  implementation of shared memory buffers used to transfer events
 - `vamos-sources`  implementation of tracing various standard events in programs (event sources)
 - `vamos-compiler` a compiler of VAMOS specifications
 - `vamos-monitors` manually written monitors, mostly for debugging and testing purposes

