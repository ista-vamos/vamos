# Getting started

## Building

```shell
$ make [OPTIONS]
```

OPTIONS may include:

 - `BUILD_TYPE=[Debug|Release|RelWithDebInfo]` the type of build to pass to cmake
 - `DYNAMORIO_SOURCES=OFF` to turn off building event sources based on DynamoRIO
 - `DynamoRIO_DIR=<path/to/dynamorio/cmake>` to use a particular DynamoRIO build
 - `TESSLA_SUPPORT=[ON|OFF]` enable support for TeSSLa monitors

The used `OPTIONS` are stored into `Makefile.config` and re-used in future `make` runs.
If you want to change the options, either delete the file or change values in there and run
`make reconfigure && make` or `make reset && make` (warning: the latter will completely clean
repositories, including all files that are not under git).
