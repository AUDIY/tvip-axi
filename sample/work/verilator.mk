VERILATOR ?= verilator

UVM_HOME ?= /opt/accellera/1800.2-2020.3.2/src
UVM_PKG   = $(UVM_HOME)/uvm_pkg.sv

VERILATOR_ARGS += --binary
VERILATOR_ARGS += --timing
VERILATOR_ARGS += --assert
VERILATOR_ARGS += --top-module top
VERILATOR_ARGS += --timescale 1ns/1ps
VERILATOR_ARGS += --Mdir obj_dir
VERILATOR_ARGS += --prefix Vtop
VERILATOR_ARGS += --MMD

DISABLED_WARNINGS= -Wno-DECLFILENAME \
                   -Wno-CONSTRAINTIGN \
                   -Wno-MISINDENT \
                   -Wno-VARHIDDEN \
                   -Wno-WIDTHTRUNC \
                   -Wno-CASTCONST \
                   -Wno-WIDTHEXPAND \
                   -Wno-UNDRIVEN \
                   -Wno-UNUSEDSIGNAL \
                   -Wno-UNUSEDPARAM \
                   -Wno-SYMRSVDWORD \
                   -Wno-ZERODLY \
                   -Wno-CASEINCOMPLETE \
                   -Wno-SIDEEFFECT \
                   -Wno-fatal \
                   -Wno-REALCVT

VERILATOR_INCDIR_ARGS += +incdir+"$(UVM_HOME)"

VERILATOR_FILE_ARGS = $(foreach f,$(FILE_LISTS),-f $(f))

VERILATOR_TEST_ARGS = $(shell cat $(TEST)/test.f)

ifeq ($(strip $(RANDOM_SEED)),auto)
  VERILATOR_SEED_ARGS += +verilator+seed+0
else
  VERILATOR_SEED_ARGS += +verilator+seed+$(RANDOM_SEED)
endif

ifeq ($(strip $(DUMP)),vcd)
  VERILATOR_ARGS += --trace-vcd
endif

ifeq ($(strip $(DUMP)),fst)
  VERILATOR_ARGS += --trace-fst
endif

CLEAN_TARGET += obj_dir
CLEAN_TARGET += *.d
CLEAN_ALL_TARGET += *.vcd
CLEAN_ALL_TARGET += *.fst

.PHONY: sim_verilator compile_verilator

sim_verilator: compile_verilator
	cd $(TEST) && ../obj_dir/Vtop \
	  $(VERILATOR_TEST_ARGS) \
	  $(VERILATOR_SEED_ARGS)

compile_verilator:
	$(VERILATOR) $(VERILATOR_ARGS) \
	  $(DISABLED_WARNINGS) \
	  $(VERILATOR_INCDIR_ARGS) \
	  $(UVM_PKG) \
	  $(VERILATOR_FILE_ARGS) \
	  $(SOURCE_FILES)
