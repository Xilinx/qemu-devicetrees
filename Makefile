 #
 # Makefile to build the device trees
 #
 # Copyright (c) 2016, Xilinx Inc
 # All rights reserved.
 #
 # Redistribution and use in source and binary forms, with or without
 # modification, are permitted provided that the following conditions are met:
 #     * Redistributions of source code must retain the above copyright
 #       notice, this list of conditions and the following disclaimer.
 #     * Redistributions in binary form must reproduce the above copyright
 #       notice, this list of conditions and the following disclaimer in the
 #       documentation and/or other materials provided with the distribution.
 #     * Neither the name of the <organization> nor the
 #       names of its contributors may be used to endorse or promote products
 #       derived from this software without specific prior written permission.
 #
 # THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 # ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 # WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 # DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
 # DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 # (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 # LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 # ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 # (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 # SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

OUTDIR 	?= ./
GCC		?= gcc
DTC		?= dtc
KSB_MM_VERSION	?= SSV_FC

ifeq ($V,)
QUIET=@
.SILENT:
else
QUIET=
endif

SKIP_AUTO_GEN= board-versal-xcvc2802-ps-cosim-vitis-virt.dts	\
		board-versal-xcve2302-ps-cosim-vitis-virt.dts

# Picks all versal varients except boards which are mentioned in SKIP_AUTO_GEN
AUTO_GEN_DTS	:= $(filter-out $(SKIP_AUTO_GEN),	\
				$(patsubst %ps-virt.dts, %ps-cosim-vitis-virt.dts, $(wildcard board-versal-*-ps-virt.dts)))

SINGLE_ARCH_OUTDIR		:= $(OUTDIR)/LATEST/SINGLE_ARCH
MULTI_ARCH_OUTDIR 		:= $(OUTDIR)/LATEST/MULTI_ARCH
LQSPI_XIP_OUTDIR		:= $(OUTDIR)/LATEST/LQSPI_XIP

DTS_FILES			:= $(wildcard *.dts) $(AUTO_GEN_DTS)
DTSI_FILES			:= $(wildcard *.dtsi)
HEADER_FILES			:= $(wildcard *.dtsh)
HEADER_FILES			+= $(wildcard include/*.dtsh)


CPPFLAGS = -I. -Iinclude/ -Iinclude/memmap/ksb/$(KSB_MM_VERSION)

.PHONY:	all source

TARGETS = \
	$(patsubst %.dts,$(SINGLE_ARCH_OUTDIR)/%.$(1),$(DTS_FILES))    \
	$(patsubst %.dts,$(MULTI_ARCH_OUTDIR)/%.$(1),$(DTS_FILES))     \
	$(patsubst %.dts,$(LQSPI_XIP_OUTDIR)/%.$(1),$(DTS_FILES))

COMPILE = \
	$(QUIET)mkdir -p $(1); \
	$(GCC) -E -nostdinc ${CPPFLAGS} -x assembler-with-cpp $(3) -MD -MF $@.cd -o $(@:.dtb=.dts.i) $<; \
	$(DTC) -q -O $(2) -@ -I dts -o $@ $(@:.dtb=.dts.i) -b 0;

all:	$(AUTO_GEN_DTS) $(call TARGETS,dtb)

-include $(call TARGETS, cd)

source:	all $(call TARGETS,dts)
auto-gen-dts:	$(AUTO_GEN_DTS)

$(SINGLE_ARCH_OUTDIR)/%.dtb:	%.dts $(DTSI_FILES) $(HEADER_FILES)
	$(call COMPILE,$(SINGLE_ARCH_OUTDIR),dtb)
$(SINGLE_ARCH_OUTDIR)/%.dts:	%.dts $(DTSI_FILES) $(HEADER_FILES)
	$(call COMPILE,$(SINGLE_ARCH_OUTDIR),dts)

$(MULTI_ARCH_OUTDIR)/%.dtb:	%.dts $(DTSI_FILES) $(HEADER_FILES)
	$(call COMPILE,$(MULTI_ARCH_OUTDIR),dtb,-DMULTI_ARCH)
$(MULTI_ARCH_OUTDIR)/%.dts:	%.dts $(DTSI_FILES) $(HEADER_FILES)
	$(call COMPILE,$(MULTI_ARCH_OUTDIR),dts,-DMULTI_ARCH)

$(MULTI_ARCH_CSU_OUTDIR)/%.dtb:	%.dts $(DTSI_FILES) $(HEADER_FILES)
	$(call COMPILE,$(MULTI_ARCH_CSU_OUTDIR),dtb,-DMULTI_ARCH -DINCLUDE_CSU)
$(MULTI_ARCH_CSU_OUTDIR)/%.dts:	%.dts $(DTSI_FILES) $(HEADER_FILES)
	$(call COMPILE,$(MULTI_ARCH_CSU_OUTDIR),dts,-DMULTI_ARCH -DINCLUDE_CSU)

$(LQSPI_XIP_OUTDIR)/%.dtb:	%.dts $(DTSI_FILES) $(HEADER_FILES)
	$(call COMPILE,$(LQSPI_XIP_OUTDIR),dtb,-DLQSPI_XIP)
$(LQSPI_XIP_OUTDIR)/%.dts:	%.dts $(DTSI_FILES) $(HEADER_FILES)
	$(call COMPILE,$(LQSPI_XIP_OUTDIR),dts,-DLQSPI_XIP)

# Auto-generated Versal fragments
# TODO: Add support for auto-generated dependency list
define AUTO_GEN_HEAD
/* Auto-Generated via Makefile
 *
 * Copyright (c) 2022, AMD Inc
 * All rights reserved.
 *
 * SPDX-License-Identifier: BSD-3-Clause
 */
endef

define AUTO_GEN_VERSAL_DEV

#include "board-versal-$*-ps-virt.dts"
#include "versal-ps-pl-remoteport.dtsi"
#include "versal-vitis.dtsi"
endef

export AUTO_GEN_HEAD
export AUTO_GEN_VERSAL_DEV

versal-pmc-npi.dtsi: versal-pmc-npi-nxx.dtsi versal-h10-pmc-npi-nxx.dtsi versal-gty-npi.dtsi
versal-pmc-npi-nxx.dtsi: Makefile
	@python3 -c 'for a in range(0, 54): print("\tGEN_NMU(" + str(a) + ")")' > $@
	@python3 -c 'for a in range(0, 50): print("\tGEN_NSU(" + str(a) + ")")' >> $@
	@python3 -c 'for a in range(0, 146): print("\tGEN_NPS(" + str(a) + ")")' >> $@
versal-h10-pmc-npi-nxx.dtsi: Makefile
	@python3 -c 'for a in range(0, 37): print("\tGEN_NMU(" + str(a) + ")")' > $@
	@python3 -c 'for a in range(0, 33): print("\tGEN_NSU(" + str(a) + ")")' >> $@
	@python3 -c 'for a in range(0, 135): print("\tGEN_NPS(" + str(a) + ")")' >> $@
versal-gty-npi.dtsi: Makefile
	@python3 -c 'for a in range(0, 4): print("#ifdef MM_NPI_GTYP_NPI_SLAVE_" + str(a) + "\n" + \
						"\tGEN_GTYP(" + str(a) + ");\n" + \
						"#endif")' > $@
	@python3 -c 'for a in range(0, 24): print("#ifdef MM_NPI_GTM_NPI_SLAVE_" + str(a) + "\n" + \
						"\tGEN_GTM(" + str(a) + ");\n" + \
						"#endif")' >> $@
board-versal-%-ps-cosim-vitis-virt.dts: Makefile
	$(if $(or $(findstring LATEST, $@), $(filter $(SKIP_AUTO_GEN), $@)), \
			  @exit 0, \
			  @echo "$$AUTO_GEN_HEAD""$$AUTO_GEN_VERSAL_DEV" > $@)

clean:
	$(RM) versal-pmc-npi-nxx.dtsi
	$(RM) versal-h10-pmc-npi-nxx.dtsi
	$(RM) versal-gty-npi.dtsi
	$(RM) $(AUTO_GEN_DTS)
	@rm -rf LATEST;
