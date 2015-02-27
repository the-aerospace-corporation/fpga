#
# Copyright 2014 Ettus Research
#

# -------------------------------------------------------------------
# Mode switches

# Calling with GUI:=1 will launch Vivado GUI for build
ifeq ($(GUI),1)
VIVADO_MODE=gui
else
VIVADO_MODE=batch
endif

# Calling with FAST:=1 will switch to using unifast libs
ifeq ($(FAST),1)
SIM_FAST=true
else
SIM_FAST=false
endif

# -------------------------------------------------------------------

# -------------------------------------------------------------------
# Path variables

SIMLIB_DIR = $(BASE_DIR)/../sim
ifdef SIM_COMPLIBDIR
COMPLIBDIR = $(SIM_COMPLIBDIR)
endif

# -------------------------------------------------------------------

# Parse part name from ID
PART_NAME=$(subst /,,$(PART_ID))

# -------------------------------------------------------------------
# Usage: SETUP_AND_LAUNCH_SIMULATION
# Args: $1 = Simulator Name
# -------------------------------------------------------------------
SETUP_AND_LAUNCH_SIMULATION = \
	@ \
	export VIV_SIMULATOR=$1; \
	export VIV_DESIGN_SRCS="$(DESIGN_SRCS)"; \
	export VIV_SIM_SRCS="$(SIM_SRCS)"; \
	export VIV_SIM_TOP=$(SIM_TOP); \
	export VIV_PART_NAME=$(PART_NAME); \
	export VIV_SIM_RUNTIME=$(SIM_RUNTIME_NS); \
	export VIV_SIM_FAST="$(SIM_FAST)"; \
	export VIV_SIM_COMPLIBDIR="$(COMPLIBDIR)"; \
	export VIV_MODE=$(VIVADO_MODE); \
	vivado -mode $(VIVADO_MODE) -source $(BASE_DIR)/../tools/scripts/viv_sim_project.tcl -log xsim.log -nojournal

.SECONDEXPANSION:

xsim:
	$(call SETUP_AND_LAUNCH_SIMULATION,XSim)

xclean:
	@rm -f xsim*.log
	@rm -rf xsim_proj
	@rm -f xvhdl.log
	@rm -f xvhdl.pb
	@rm -f xvlog.log
	@rm -f xvlog.pb
	@rm -f vivado_pid*.str

vsim: $(COMPLIBDIR)
	$(call SETUP_AND_LAUNCH_SIMULATION,Modelsim)

vclean:
	@rm -f modelsim*.log
	@rm -rf modelsim_proj
	@rm -f vivado_pid*.str

# Use clean with :: to support allow "make clean" to work with multiple makefiles
clean:: xclean vclean

.PHONY: sim clean