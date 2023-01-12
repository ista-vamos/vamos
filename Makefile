CC=clang
BUILD_TYPE := $(if $(BUILD_TYPE),$(BUILD_TYPE),"RelWithDebInfo")
DYNAMORIO_SOURCES := $(if $(DYNAMORIO_SOURCES),$(DYNAMORIO_SOURCES),"ON")
ifdef $(DynamoRIO_DIR)
BUILD_DRIO := "yes"
else
DynamoRIO_DIR := "ext/dynamorio/build/cmake"
endif

all: shamon compiler sources

reconfigure:
	rm -f shamon/CMakeCache.txt
	rm -f vamos-compiler/CMakeCache.txt
	rm -f vamos-sources/CMakeCache.txt
	test -f vamos-sources/ext/dynamorio/build/CMakeCache.txt && rm -f vamos-sources/ext/dynamorio/build/CMakeCache.txt
	rm -f experiments/CMakeCache.txt
	make shamon-config
	make compiler-config
	make sources-config

shamon: shamon-config
	+make -C shamon

shamon-config: shamon-init
	cd shamon && (test -f CMakeCache.txt || cmake . -DCMAKE_C_COMPILER=$(CC) -DCMAKE_BUILD_TYPE=$(BUILD_TYPE) $(SHAMON_OPTS))

shamon-init:
	test -f shamon/CMakeLists.txt || git submodule update --init --recursive -- shamon


compiler: compiler-config
	+make -C vamos-compiler

compiler-config: shamon compiler-init
	cd vamos-compiler && (test -f CMakeCache.txt || cmake . -DCMAKE_C_COMPILER=$(CC) -Dshamon_DIR=../shamon/cmake/shamon -DCMAKE_BUILD_TYPE=$(BUILD_TYPE) $(COMPILER_OPTS))

# make inits dependent, because git locks config file
compiler-init: sources-init
	test -f vamos-compiler/CMakeLists.txt || git submodule update --init --recursive -- vamos-compiler


sources: shamon sources-config
	+make -C vamos-sources

dynamorio: sources-init
ifdef $(BUILD_DRIO)
	+make -C vamos-sources/ext dynamorio
else
	@echo "Using DynamoRIO_DIR = $(DynamoRIO_DIR)"
endif

sources-config: shamon sources-init dynamorio
	cd vamos-sources && (test -f CMakeCache.txt || cmake . -DCMAKE_C_COMPILER=$(CC) -Dshamon_DIR=../shamon/cmake/shamon -DDYNAMORIO_SOURCES=$(DYNAMORIO_SOURCES) -DDynamoRIO_DIR=$(DynamoRIO_DIR) -DCMAKE_BUILD_TYPE=$(BUILD_TYPE) $(SOURCES_OPTS)) || git clean -xdf

sources-init: shamon-init
	test -f vamos-sources/CMakeLists.txt || git submodule update --init --recursive -- vamos-sources


fase23-experiments-config: shamon
	test -f fase23-experiments/CMakeLists.txt || git clone git@github.com:ista-vamos/fase23-experiments.git
	cd fase23-experiments && (test -f CMakeCache.txt || cmake . -DCMAKE_C_COMPILER=$(CC) -Dshamon_DIR=../shamon/cmake/shamon -Dvamos_sources_DIR=../vamos-sources -Dvamos_compiler_DIR=../vamos-compiler -DCMAKE_BUILD_TYPE=$(BUILD_TYPE)) || git clean -xdf

fase23-experiments: fase23-experiments-config all
	# FIXME: change this to use HTTPS after making it public
	make -C fase23-experiments
	echo -e "\n## Now you can go to the folder fase23-experiments and follow the README.md ##\n"

clean:
	make clean -C shamon
	make clean -C vamos-sources
	make clean -C vamos-compiler
	test -d experiments && make clean -C experiments
