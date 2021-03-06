`default_nettype none
`include "rtl/utilities.v"
`include "rtl/parameters.vh"

module assembly_instructions_memory_lbu_new_tb ();
//Tests memory behaviour. Is separated from rest because on the future 
//it might spend more than one cycle to coplete each instruction

//localparam PROGRAM_MEMORY_SIZE=100;
//
//x31 register: Checks if expected and as-is inputs are equal by checking if
//their difference is 0, via reg x31
//x1 register: The number of the current test in file (helpful for debugging)

reg clk;
reg reset;

SoC mut (
    .clk (clk), .reset (reset)
);
initial begin
    clk=0;
end
always begin
    #5;clk=~clk;

    //Some test started, but didnt finish, so there was probably an error jumping instructions and this is bad.
    if (mut.cpu.instruction === 32'h xxxxxxxx && mut.cpu.single_instr.reg_mem.memory[31] === 32'd 0) begin
           $display("%c[1;31m",27);
           $display("Some test didnt finish properly, as x(31) is %d. Its probably linked to a branch/jump test!", mut.cpu.single_instr.reg_mem.memory[31]);
           $fatal();
        end
end

integer approximate_clock_count;
integer current_test=-1;
integer last_test=-1;

initial
begin
    $info("Testing memory behaviour from assembly file. x31 is probed for pass, must always be zero!!!");
    $dumpfile(`VCDFILEPATH);
    $dumpvars(0,mut);
    //$monitor("%2t,reset=%b,clk=%b,pc=%d,current instruction=%h, x1=%h, x10=%h,x11=%h, x31=%h",$time,reset,clk,mut.cpu.pc,mut.cpu.instruction,mut.cpu.single_instr.reg_mem.memory[1],mut.cpu.single_instr.reg_mem.memory[10],mut.cpu.single_instr.reg_mem.memory[11],mut.cpu.single_instr.reg_mem.memory[31]);

    $readmemh(`MEMFILEPATH, mut.rom.program_memory,0,PROGRAM_MEMORY_SIZE_WORDS-1);

    reset=1;#20;

    @(negedge clk) #1; reset=0;
    approximate_clock_count=0;
    while (approximate_clock_count < PROGRAM_MEMORY_SIZE_WORDS &&  !(mut.cpu.instruction === 32'h xxxxxxxx)) begin // Stops on invalid instruction or end of memory

        current_test=mut.cpu.single_instr.reg_mem.memory[1];
        if(current_test!==last_test) begin
            last_test=current_test;
        $display("Running sub-test number: %d",current_test);
        end

	    $display("PC is %d, instruction: %h", mut.cpu.pc, mut.cpu.instruction);
	    @(posedge clk) #1; if (mut.cpu.single_instr.reg_mem.memory[31] !== 32'd 0) begin 
            if (mut.cpu.single_instr.reg_mem.memory[31] !== mut.cpu.single_instr.reg_mem.memory[1]) begin 
                $display("%c[1;31m",27);
                $display("Test %d didnt finish properly and was taken over by %d. Its probably linked to a branch/jump test!", mut.cpu.single_instr.reg_mem.memory[1],mut.cpu.single_instr.reg_mem.memory[31]);
                $fatal();
            end
            `assertCaseEqual(mut.cpu.single_instr.reg_mem.memory[29],mut.cpu.single_instr.reg_mem.memory[30], {"x29 register should be as x30 (benchmark)"});
        end

        approximate_clock_count+=1;

        // Possible infinite loop is detected 
        // This onyl makes sense if there is one cycle per instruction
        // Otherwise, it makes no sense.       
        if (PROGRAM_MEMORY_SIZE_WORDS <= approximate_clock_count) begin 
                $display("%c[1;31m",27);
                $display("Probalbe infinite loop. If you are sure this is not a bug, increase the size of program memory");
                $fatal();
        end
    end
    #1;
    $display("Simulation finished");
    $finish;
end
endmodule
