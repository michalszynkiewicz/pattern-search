# Location of the CUDA Toolkit
CUDA_PATH       ?= /usr/local/cuda-7.5

# architecture
HOST_ARCH   := $(shell uname -m)

# host compiler
HOST_COMPILER ?= g++
NVCC          := $(CUDA_PATH)/bin/nvcc -ccbin $(HOST_COMPILER)

# internal flags
NVCCFLAGS   := -m64
CCFLAGS     :=
LDFLAGS     :=

# Debug build flags
ifeq ($(dbg),1)
      NVCCFLAGS += -g -G
      BUILD_TYPE := debug
else
      BUILD_TYPE := release
endif

ALL_CCFLAGS := "-std=c++11"
ALL_CCFLAGS += "-O3"
ALL_CCFLAGS += $(NVCCFLAGS)
ALL_CCFLAGS += $(EXTRA_NVCCFLAGS)
ALL_CCFLAGS += $(addprefix -Xcompiler ,$(CCFLAGS))
ALL_CCFLAGS += $(addprefix -Xcompiler ,$(EXTRA_CCFLAGS))

ALL_LDFLAGS :=
ALL_LDFLAGS += $(ALL_CCFLAGS)
ALL_LDFLAGS += $(addprefix -Xlinker ,$(LDFLAGS))
ALL_LDFLAGS += $(addprefix -Xlinker ,$(EXTRA_LDFLAGS))

# Common includes and paths for CUDA
LIBRARIES :=

sm := 20

GENCODE_FLAGS := -gencode arch=compute_$(sm),code=sm_$(sm)

PROGRAM := __PROGRAM_NAME__

################################################################################

# Target rules
all: build build-debug

build: $(PROGRAM)

build-debug: $(PROGRAM)-debug

$(PROGRAM).o:$(PROGRAM).cu
	$(EXEC) $(NVCC) $(INCLUDES) $(ALL_CCFLAGS) $(GENCODE_FLAGS) -o $@ -c $<

$(PROGRAM)-debug.o:$(PROGRAM).cu
	$(EXEC) $(NVCC) $(INCLUDES) $(ALL_CCFLAGS) -g -G $(GENCODE_FLAGS) -o $@ -c $<

$(PROGRAM): $(PROGRAM).o
	$(EXEC) $(NVCC) $(ALL_LDFLAGS) $(GENCODE_FLAGS) -o $@ $+ $(LIBRARIES)

$(PROGRAM)-debug: $(PROGRAM)-debug.o
	$(EXEC) $(NVCC) $(ALL_LDFLAGS) $(GENCODE_FLAGS) -g -G -o $@ $+ $(LIBRARIES)

run: build
	$(EXEC) ./$(PROGRAM)

debug: build-debug
	$(EXEC) cuda-gdb ./$(PROGRAM)-debug

clean:
	rm -f $(PROGRAM) $(PROGRAM).o $(PROGRAM)-debug $(PROGRAM)-debug.o

clobber: clean
