#!/bin/bash
set -euo pipefail
iverilog -o register_memory_out register_memory_tb.v register_memory.v &&  vvp register_memory_out

iverilog -o pc_out pc_tb.v pc.v  &&  vvp pc_out
iverilog -o alu_out alu_tb.v alu.v  &&  vvp alu_out

iverilog -o single_instruction_out single_instruction_tb.v single_instruction.v register_memory.v alu.v &&  vvp single_instruction_out
iverilog -o consecutive_instructions_out consecutive_instructions_tb.v multiple_instructions.v register_memory.v single_instruction.v pc.v alu.v &&  vvp consecutive_instructions_out
iverilog -o instructions_i_out instructions_i_tb.v multiple_instructions.v register_memory.v single_instruction.v pc.v alu.v &&  vvp instructions_i_out