CONFIG:=Makefile.config
-include $(CONFIG)

CC ?= "clang"
CXX ?= "clang++"
BUILD_TYPE ?= "RelWithDebInfo"
DYNAMORIO_SOURCES ?= "ON"
LLVM_SOURCES ?= "ON"
TESSLA_SUPPORT ?= "ON"
LIBINPUT_SOURCES ?= "ON"
WLDBG_SOURCES ?= "OFF"


CLONE_METHOD := "https://github.com/"

all: check-dependencies export_config buffers compiler sources

check-dependencies:
	python3 --version > /dev/null || (echo "Need python 3 installed"; exit 1)
	cmake --version > /dev/null || (echo "Need cmake installed"; exit 1)
	#python3 -c "import lark" || (echo "Need lark installed (pip install lark)"; exit 1)


# dump current config into a file that will be used on the next run
export_config:
	@echo "CC:=$(CC)" > $(CONFIG)
	@echo "CXX:=$(CXX)" >> $(CONFIG)
	@echo "BUILD_TYPE:=$(BUILD_TYPE)" >> $(CONFIG)
	@echo "DYNAMORIO_SOURCES:=$(DYNAMORIO_SOURCES)" >> $(CONFIG)
	@echo "TESSLA_SUPPORT:=$(TESSLA_SUPPORT)" >> $(CONFIG)
	@echo "LLVM_SOURCES:=$(LLVM_SOURCES)" >> $(CONFIG)
	@echo "LIBINPUT_SOURCES:=$(LIBINPUT_SOURCES)" >> $(CONFIG)
	@echo "WLDBG_SOURCES:=$(WLDBG_SOURCES)" >> $(CONFIG)
	@echo "Config has been written to $(CONFIG)"

.PHONY: all export_config docs

include makefiles/Makefile-buffers
include makefiles/Makefile-common
include makefiles/Makefile-compiler
include makefiles/Makefile-sources

fase23-experiments-config: export_config buffers
	test -f fase23-experiments/CMakeLists.txt || git clone $(CLONE_METHOD)ista-vamos/fase23-experiments.git
	cd fase23-experiments && (test -f CMakeCache.txt || cmake . -DCMAKE_C_COMPILER=$(CC)\
		-Dvamos-buffers_DIR=../vamos-buffers/cmake/vamos-buffers\
		-Dvamos_sources_DIR=../vamos-sources\
		-Dvamos_compiler_DIR=../vamos-compiler\
		-DCMAKE_C_COMPILER=$(CC)\
		-DCMAKE_CXX_COMPILER=$(CXX)\
		-DCMAKE_BUILD_TYPE=$(BUILD_TYPE)) || git clean -xdf

fase23-experiments: fase23-experiments-config all
	# FIXME: change this to use HTTPS after making it public
	make -C fase23-experiments
	echo -e "\n## Now you can go to the folder fase23-experiments and follow README there ##\n"

sttt-experiments-config: export_config buffers
	test -f sttt-experiments/CMakeLists.txt || git clone $(CLONE_METHOD)ista-vamos/sttt-experiments.git
	cd sttt-experiments && (test -f CMakeCache.txt || cmake .\
		-DCMAKE_C_COMPILER=$(CC)\
		-DCMAKE_CXX_COMPILER=$(CXX)
		-Dvamos-buffers_DIR=../vamos-buffers/cmake/vamos-buffers\
		-Dvamos_sources_DIR=../vamos-sources\
		-Dvamos_compiler_DIR=../vamos-compiler\
		-DCMAKE_BUILD_TYPE=$(BUILD_TYPE)) || git clean -xdf

sttt-experiments: sttt-experiments-config all
	# FIXME: change this to use HTTPS after making it public
	make -C sttt-experiments
	echo -e "\n## Now you can go to the folder sttt-experiments and follow README there ##\n"



REPOS := vamos-buffers vamos-compiler vamos-sources vamos-common 


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
