SHELL=/bin/bash -euo pipefail

VLOG=iverilog -Wall -g2012

CC=clang --target=riscv32 -march=rv32i -Wall

SOURCES       			:= $(shell find rtl/ -name '*.v' -not -name '*_tb.v')
COMP_TEST_SOURCES       := $(shell find tests/01_components -name '*.v')
SYSTEM_TEST_SOURCES		:= $(shell find tests/02_system -name '*.v')
ASM_TEST_SOURCES       	:= $(shell find tests/03_assembly -name '*.v')
INCLUDES       			:= $(shell find rtl/ -name '*.vh')
PCF_FILE				:= $(shell find rtl/ -name '*.pcf')

.PHONY: test
test: verilog_component_test verilog_system_test assembly_test
#CPU_I_TESTS.test.o: $(SOURCES)
#	$(VLOG) $(SOURCES) -s memory_tb -I $(INCLUDES) -DVCDFILEPATH=\"$*.vcd\" -o $(@:.test.o=.test.o)
.PHONY: verilog_component_test
verilog_component_test:
	@echo 	================ VERILOG COMPONENT TESTS ================
	$(VLOG) $(SOURCES) $(COMP_TEST_SOURCES) -I $(INCLUDES)  -o register_memory_out.o                       -s register_memory_tb       	&&    vvp register_memory_out.o
	$(VLOG) $(SOURCES) $(COMP_TEST_SOURCES) -I $(INCLUDES)  -o pc_out.o                                    -s program_counter_tb                   	&&    vvp pc_out.o
	$(VLOG) $(SOURCES) $(COMP_TEST_SOURCES) -I $(INCLUDES)  -o alu_out.o                                   -s tb_alu                   	&&    vvp alu_out.o
	$(VLOG) $(SOURCES) $(COMP_TEST_SOURCES) -I $(INCLUDES)  -o mem_out.o                                   -s memory_tb               	&&    vvp mem_out.o
	

.PHONY: verilog_system_test
verilog_system_test:
	@echo 	================ VERILOG SYSTEM TESTS ================
	$(VLOG) $(SOURCES) $(SYSTEM_TEST_SOURCES) -I $(INCLUDES) -o single_instruction_out.o                    -s single_instruction_tb        	&&    vvp single_instruction_out.o
	$(VLOG) $(SOURCES) $(SYSTEM_TEST_SOURCES) -I $(INCLUDES) -o instructions_i_out.o                        -s instructions_i_tb           	&&    vvp instructions_i_out.o
	$(VLOG) $(SOURCES) $(SYSTEM_TEST_SOURCES) -I $(INCLUDES) -o consecutive_instructions_out.o              -s consecutive_instructions_tb	&&    vvp consecutive_instructions_out.o
	$(VLOG) $(SOURCES) $(SYSTEM_TEST_SOURCES) -I $(INCLUDES) -o branch_instructions_out.o                   -s branch_instructions_tb			&&    vvp branch_instructions_out.o

.PHONY: assembly_test
assembly_test:
	@echo 	================ ASSEMBLY TESTS ================
	$(CC) tests/03_assembly/test_addi.S						-c -o test_addi.o       && llvm-objcopy -O binary test_addi.o	--only-section .text\* test_addi.bin	&& hexdump -ve '1/4 "%08x\n"' test_addi.bin		>   test_addi.mem
	$(CC) tests/03_assembly/test_sw_lw.S					-c -o test_sw_lw.o      && llvm-objcopy -O binary test_sw_lw.o	--only-section .text\* test_sw_lw.bin	&& hexdump -ve '1/4 "%08x\n"' test_sw_lw.bin	>   test_sw_lw.mem
	$(CC) tests/03_assembly/test_lbu.S						-c -o test_lbu.o		&& llvm-objcopy -O binary test_lbu.o	--only-section .text\* test_lbu.bin		&& hexdump -ve '1/4 "%08x\n"' test_lbu.bin		>   test_lbu.mem
	$(CC) tests/03_assembly/test_r_inst.S					-c -o test_r_inst.o		&& llvm-objcopy -O binary test_r_inst.o	--only-section .text\* test_r_inst.bin	&& hexdump -ve '1/4 "%08x\n"' test_r_inst.bin	>   test_r_inst.mem
	$(CC) tests/03_assembly/test_i_inst.S					-c -o test_i_inst.o		&& llvm-objcopy -O binary test_i_inst.o	--only-section .text\* test_i_inst.bin	&& hexdump -ve '1/4 "%08x\n"' test_i_inst.bin	>   test_i_inst.mem
	$(CC) tests/03_assembly/test_b_inst.S					-c -o test_b_inst.o		&& llvm-objcopy -O binary test_b_inst.o	--only-section .text\* test_b_inst.bin	&& hexdump -ve '1/4 "%08x\n"' test_b_inst.bin	>   test_b_inst.mem
	
	$(VLOG) $(SOURCES) $(ASM_TEST_SOURCES) -I $(INCLUDES) -o assembly_instructions_out.o                	-s assembly_instructions_memory_lbu_tb -DMEMFILEPATH=\"test_addi.mem\"	-DVCDFILEPATH=\"test_addi.vcd\"		&& vvp assembly_instructions_out.o
	$(VLOG) $(SOURCES) $(ASM_TEST_SOURCES) -I $(INCLUDES) -o assembly_instructions_memory_out.o         	-s assembly_instructions_memory_lbu_tb -DMEMFILEPATH=\"test_sw_lw.mem\"	-DVCDFILEPATH=\"test_sw_lw.vcd\"	&& vvp assembly_instructions_memory_out.o
	$(VLOG) $(SOURCES) $(ASM_TEST_SOURCES) -I $(INCLUDES) -o assembly_instructions_memory_lbu_out.o     	-s assembly_instructions_memory_lbu_tb -DMEMFILEPATH=\"test_lbu.mem\"		-DVCDFILEPATH=\"test_lbu.vcd\"		&& vvp assembly_instructions_memory_lbu_out.o
	$(VLOG) $(SOURCES) $(ASM_TEST_SOURCES) -I $(INCLUDES) -o assembly_instructions_type_r_out.o      		-s assembly_instructions_memory_lbu_new_tb -DMEMFILEPATH=\"test_r_inst.mem\"	-DVCDFILEPATH=\"test_r_inst.vcd\"	&& vvp assembly_instructions_type_r_out.o
	$(VLOG) $(SOURCES) $(ASM_TEST_SOURCES) -I $(INCLUDES) -o assembly_instructions_type_i_out.o      		-s assembly_instructions_memory_lbu_new_tb -DMEMFILEPATH=\"test_i_inst.mem\"	-DVCDFILEPATH=\"test_i_inst.vcd\"	&& vvp assembly_instructions_type_i_out.o
	$(VLOG) $(SOURCES) $(ASM_TEST_SOURCES) -I $(INCLUDES) -o assembly_instructions_type_b_out.o      		-s assembly_instructions_memory_lbu_new_tb -DMEMFILEPATH=\"test_b_inst.mem\"	-DVCDFILEPATH=\"test_b_inst.vcd\"	&& vvp assembly_instructions_type_b_out.o

https://www.sas.upenn.edu/~jesusfv/Chapter_HPC_6_Make.pdf

%.json: $(SOURCES)
	yosys -p "synth_ice40 -json $*.json -top $*" -q $(SOURCES)

%.bin: %.asc 
	icepack $*.asc $*.bin

%.asc: %.json $(PCF_FILE)
	nextpnr-ice40 --up5k --package sg48 --json $*.json --pcf $(PCF_FILE) --freq 48 -q --opt-timing --asc $*.asc
	icetime -mit $*.asc -d up5k

%.svg: $(SOURCES)
	yosys -p "prep -top $*; write_json $*.diagram.json" -q $(SOURCES)
	npx netlistsvg $*.diagram.json -o $*.svg
	

.PHONY: lint
lint: $(SOURCES)
	verilator --lint-only -Wall -Wno-EOFNEWLINE $(SOURCES) 

.PHONY : clean
clean:
	rm -rf *.vcd *.bin *.o *.vvp *.mem *.asc *.svg build *.json

#yosys -p "read_verilog -sv rtl/MultipleInstructions.v ; synth_ecp5 -json top.json -top MultipleInstructions"
