# VAMOS

VAMOS is a framework containing libraries and a set of tools for monitoring
heterogeneous asynchronous events sources. Events are efficiently transferred
via concurrent buffers in the shared memory.

## Build:

```
make [OPTIONS]
```

`OPTIONS` may include:
 - `BUILD_TYPE=[Debug|Release|RelWithDebInfo]` the type of build to pass to cmake
 - `DYNAMORIO_SOURCES=OFF` to turn off building event sources based on DynamoRIO
 - `DynamoRIO_DIR=<path/to/dynamorio/cmake>` to use a particular DynamoRIO build
 - `TESSLA_SUPPORT=[ON|OFF]` enable support for TeSSLa monitors

## Components

 - `vamos-buffers`  implementation of shared memory buffers used to transfer events
 - `vamos-sources`  implementation of tracing various standard events in programs (event sources)
 - `vamos-compiler` a compiler of VAMOS specifications
 - `vamos-monitors` manually written monitors, mostly for debugging and testing purposes

