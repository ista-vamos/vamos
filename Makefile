CONFIG:=Makefile.config
-include $(CONFIG)

CC ?= "clang"
CXX ?= "clang++"
BUILD_TYPE ?= "RelWithDebInfo"
DYNAMORIO_SOURCES ?= "ON"
TESSLA_SUPPORT ?= "ON"

ifeq ($(DYNAMORIO_SOURCES), "ON")
ifndef DynamoRIO_DIR
BUILD_DRIO := "yes"
DynamoRIO_DIR := "ext/dynamorio/build/cmake"
endif
endif

ifeq ($(TESSLA_SUPPORT), "ON")
DOWNLOAD_TESSLA_RUST_JAR := "ON"
else
DOWNLOAD_TESSLA_RUST_JAR := "OFF"
endif

all: export_config buffers compiler sources monitors

# dump current config into a file that will be used on the next run
export_config:
	@echo "CC:=$(CC)" > $(CONFIG)
	@echo "CXX:=$(CXX)" >> $(CONFIG)
	@echo "BUILD_TYPE:=$(BUILD_TYPE)" >> $(CONFIG)
	@echo "DYNAMORIO_SOURCES:=$(DYNAMORIO_SOURCES)" >> $(CONFIG)
	@echo "TESSLA_SUPPORT:=$(TESSLA_SUPPORT)" >> $(CONFIG)
	@echo "Config has been written to $(CONFIG)"

.PHONY: all export_config docs

buffers: buffers-config
	+make -C vamos-buffers

buffers-config: export_config buffers-init
	cd vamos-buffers && (test -f CMakeCache.txt || cmake . -DCMAKE_C_COMPILER=$(CC) -DCMAKE_BUILD_TYPE=$(BUILD_TYPE) $(SHAMON_OPTS))

buffers-init:
	test -f vamos-buffers/CMakeLists.txt || git submodule update --init --recursive -- vamos-buffers


compiler: compiler-config
	+make -C vamos-compiler

compiler-config: export_config buffers compiler-init
	cd vamos-compiler && (test -f CMakeCache.txt || cmake . -DCMAKE_C_COMPILER=$(CC) -Dvamos-buffers_DIR=../vamos-buffers/cmake/vamos-buffers -DCMAKE_BUILD_TYPE=$(BUILD_TYPE)  -DDOWNLOAD_TESSLA_RUST_JAR=$(DOWNLOAD_TESSLA_RUST_JAR) $(COMPILER_OPTS))

# make inits dependent, because git locks config file
compiler-init: sources-init
	test -f vamos-compiler/CMakeLists.txt || git submodule update --init --recursive -- vamos-compiler


sources: buffers sources-config
	+make -C vamos-sources

dynamorio: sources-init
ifdef BUILD_DRIO
	+make -C vamos-sources/ext dynamorio
else
ifeq ($(DYNAMORIO_SOURCES), "ON")
	@echo "Using DynamoRIO_DIR = $(DynamoRIO_DIR)"
endif
endif

sources-config: export_config buffers sources-init dynamorio
	cd vamos-sources && (test -f CMakeCache.txt || cmake . -DCMAKE_C_COMPILER=$(CC) -Dvamos-buffers_DIR=../vamos-buffers/cmake/vamos-buffers -DDYNAMORIO_SOURCES=$(DYNAMORIO_SOURCES) -DDynamoRIO_DIR=$(DynamoRIO_DIR) -DCMAKE_BUILD_TYPE=$(BUILD_TYPE) $(SOURCES_OPTS)) || git clean -xdf

sources-init: buffers-init
	test -f vamos-sources/CMakeLists.txt || git submodule update --init --recursive -- vamos-sources

monitors: monitors-config
	+make -C vamos-monitors

monitors-config: export_config buffers monitors-init
	cd vamos-monitors && (test -f CMakeCache.txt || cmake . -DCMAKE_C_COMPILER=$(CC) -Dvamos-buffers_DIR=../vamos-buffers/cmake/vamos-buffers -DCMAKE_BUILD_TYPE=$(BUILD_TYPE) $(COMPILER_OPTS))

# make inits dependent, because git locks config file
monitors-init: compiler-init
	test -f vamos-monitors/CMakeLists.txt || git submodule update --init --recursive -- vamos-monitors


fase23-experiments-config: export_config buffers
	test -f fase23-experiments/CMakeLists.txt || git clone https://github.com/ista-vamos/fase23-experiments.git
	cd fase23-experiments && (test -f CMakeCache.txt || cmake . -DCMAKE_C_COMPILER=$(CC) -Dvamos-buffers_DIR=../vamos-buffers/cmake/vamos-buffers -Dvamos_sources_DIR=../vamos-sources -Dvamos_compiler_DIR=../vamos-compiler -DCMAKE_BUILD_TYPE=$(BUILD_TYPE)) || git clean -xdf

fase23-experiments: fase23-experiments-config all
	# FIXME: change this to use HTTPS after making it public
	make -C fase23-experiments
	echo -e "\n## Now you can go to the folder fase23-experiments and follow README there ##\n"

clean:
	make clean -C vamos-buffers
	make clean -C vamos-sources
	make clean -C vamos-compiler
	make clean -C vamos-monitors
	test -d experiments && make clean -C experiments

reconfigure:
	-rm -f vamos-buffers/CMakeCache.txt
	-rm -f vamos-compiler/CMakeCache.txt
	-rm -f vamos-sources/CMakeCache.txt
	-rm -f vamos-monitors/CMakeCache.txt
	-rm -f vamos-sources/ext/dynamorio/build/CMakeCache.txt
	-rm -f fase23-experiments/CMakeCache.txt
	make buffers-config
	make compiler-config
	make sources-config
	make monitors-config

reset:
	cd vamos-buffers && git clean -xdf
	cd vamos-compiler && git clean -xdf
	cd vamos-sources && git clean -xdf
	cd vamos-monitors && git clean -xdf

docs:
	cd .mdbook && mdbook build -d ../docs
