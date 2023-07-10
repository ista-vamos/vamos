CONFIG:=Makefile.config
-include $(CONFIG)

CC ?= "clang"
CXX ?= "clang++"
BUILD_TYPE ?= "RelWithDebInfo"
DYNAMORIO_SOURCES ?= "ON"
TESSLA_SUPPORT ?= "ON"

CLONE_METHOD := "https://github.com/"

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

include makefiles/Makefile-buffers
include makefiles/Makefile-common
include makefiles/Makefile-compiler
include makefiles/Makefile-monitors
include makefiles/Makefile-sources
include makefiles/Makefile-hyper
include makefiles/Makefile-spec
include makefiles/Makefile-mpt

fase23-experiments-config: export_config buffers
	test -f fase23-experiments/CMakeLists.txt || git clone $(CLONE_METHOD)ista-vamos/fase23-experiments.git
	cd fase23-experiments && (test -f CMakeCache.txt || cmake . -DCMAKE_C_COMPILER=$(CC)\
		-Dvamos-buffers_DIR=../vamos-buffers/cmake/vamos-buffers\
		-Dvamos_sources_DIR=../vamos-sources\
		-Dvamos_compiler_DIR=../vamos-compiler\
		-DCMAKE_BUILD_TYPE=$(BUILD_TYPE)) || git clean -xdf

fase23-experiments: fase23-experiments-config all
	# FIXME: change this to use HTTPS after making it public
	make -C fase23-experiments
	echo -e "\n## Now you can go to the folder fase23-experiments and follow README there ##\n"

REPOS := vamos-buffers vamos-compiler vamos-sources vamos-monitors\
         vamos-common vamos-hyper vamos-mpt vamos-spec


clean:
	for REPO in $(REPOS); do\
		echo "Cleaning $$REPO";\
		test -d $$REPO && make clean -C $$REPO;\
	done
	test -d experiments && make clean -C experiments

reconfigure:
	for REPO in $(REPOS); do\
		rm -f $$REPO/CMakeCache.txt || true
	done
	-rm -f fase23-experiments/CMakeCache.txt
	make buffers-config
	make compiler-config
	make sources-config
	make monitors-config

set-dev: all
	for REPO in $(REPOS); do\
		echo "Setting url at $$REPO";\
		test -d $$REPO && cd $$REPO && git remote set-url origin git@github.com:ista-vamos/$$REPO.git && cd -;\
	done


reset:
	for REPO in $(REPOS); do\
		test -d $$REPO && cd $$REPO && git clean -xdf && cd -;\
	done

docs:
	cd .mdbook && mdbook build -d ../docs
