CC=clang
BUILD_TYPE := $(if $(BUILD_TYPE),$(BUILD_TYPE),"RelWithDebInfo")

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


compiler: shamon compiler-config
	+make -C vamos-compiler

compiler-config: compiler-init
	cd vamos-compiler && (test -f CMakeCache.txt || cmake . -DCMAKE_C_COMPILER=$(CC) -Dshamon_DIR=../shamon/cmake/shamon -DCMAKE_BUILD_TYPE=$(BUILD_TYPE) $(COMPILER_OPTS))

compiler-init:
	test -f vamos-compiler/CMakeLists.txt || git submodule update --init --recursive -- vamos-compiler


sources: shamon sources-config
	+make -C vamos-sources

sources-config: sources-init
	cd vamos-sources && (test -f CMakeCache.txt || cmake . -DCMAKE_C_COMPILER=$(CC) -DBUILD_DYNAMORIO_IF_MISSING=ON -Dshamon_DIR=../shamon/cmake/shamon -DCMAKE_BUILD_TYPE=$(BUILD_TYPE) $(SOURCES_OPTS)) || git clean -xdf

sources-init:
	test -f vamos-sources/CMakeLists.txt || git submodule update --init --recursive -- vamos-sources


experiments-config:
	test -f experiments/CMakeLists.txt || git clone git@github.com:ista-vamos/experiments.git
	cd experiments && (test -f CMakeCache.txt || cmake . -DCMAKE_C_COMPILER=$(CC) -Dshamon_DIR=../shamon/cmake/shamon -Dvamos_compiler_DIR=../vamos-compiler -DCMAKE_BUILD_TYPE=$(BUILD_TYPE)) || git clean -xdf

experiments: experiments-config all
	# FIXME: change this to use HTTPS after making it public
	make -C experiments
	echo -e "\n## Now you can go to the folder experiments and follow the README.md ##\n"

clean:
	make clean -C shamon
	make clean -C vamos-sources
	make clean -C vamos-compiler
	test -d experiments && make clean -C experiments
