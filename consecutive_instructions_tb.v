`default_nettype none
`include "utilities.v"
module consecutive_instructions_tb ();

reg clk;
reg reset;

multiple_instructions mut (
    .clk (clk), .reset (reset)
);
initial begin
    clk=0;
end
always begin
    #5;clk=~clk;
end

initial
begin
    $dumpfile("multiple_instructions_out.vcd");
    $dumpvars(0,mut);
    $monitor("%2t,reset=%b,clk=%b,pc=%d,current instruction=%h, x5=%d",$time,reset,clk,mut.pc,mut.instruction,mut.single_instr.reg_mem.memory[5]);

    //I-Type instructions
    $display("I-Type instructions");
    reset=1;#1;
    mut.program_memory[0]={12'd120, 5'd0, 3'b000, 5'd5, 7'b0010011};//imm[11:0] rs1 000 rd 0010011 I addi
    mut.program_memory[1]={12'd200, 5'd0, 3'b000, 5'd5, 7'b0010011};//imm[11:0] rs1 000 rd 0010011 I addi
    mut.program_memory[2]={12'd2000, 5'd5, 3'b000, 5'd5, 7'b0010011};//imm[11:0] rs1 000 rd 0010011 I addi
    mut.program_memory[3]={12'b111111111111, 5'd0, 3'b111, 5'd5, 7'b0010011};// imm[11:0] rs1 111 rd 0010011 I andi
    mut.program_memory[4]={12'b1010,5'd0,3'b110,5'd5,7'b0010011}; // imm[11:0] rs1 110 rd 0010011 I ori
    @(negedge clk) #1; reset=0;
    @(posedge clk) #1; `assertCaseEqual(mut.single_instr.reg_mem.memory[5], 32'd120,"ADDI: Register 5 should contain 120");
    @(posedge clk) #1; `assertCaseEqual(mut.single_instr.reg_mem.memory[5], 32'd200,"ADDI: Register 5 should contain 200");
    @(posedge clk) #1; `assertCaseEqual(mut.single_instr.reg_mem.memory[5], 32'd2200,"ADDI: Register 5 should contain 2200");
    @(posedge clk) #1; `assertCaseEqual(mut.single_instr.reg_mem.memory[5], 32'b0,"ANDI: Register 5 should contain all zeroes");
    @(posedge clk) #1; `assertCaseEqual(mut.single_instr.reg_mem.memory[5], 32'b1010,"ORI: Register 5 should end with 1010");

    //R-Type instructions
    $display("R-Type instructions");
    reset=1;#1;
    mut.program_memory[0]={12'd 2, 5'd 0, 3'b 000, 5'd 29, 7'b 0010011}; //imm[11:0] rs1 000 rd 0010011 I addi
    mut.program_memory[1]={12'd 5, 5'd 0, 3'b 000, 5'd 31, 7'b 0010011}; //imm[11:0] rs1 000 rd 0010011 I addi
    mut.program_memory[2]={12'b 0, 5'd 29, 5'd 31, 3'b 000, 5'd 5, 7'b 0110011}; // 0000000 rs2 rs1 000 rd 0110011 R add
    @(negedge clk) #1; reset=0;
    @(posedge clk) #1; `assertCaseEqual(mut.single_instr.reg_mem.memory[29], 32'd 2,"ADDI: Register 29 should contain 2");
    @(posedge clk) #1; `assertCaseEqual(mut.single_instr.reg_mem.memory[31], 32'd 5,"ADDI: Register 31 should contain 5");
    @(posedge clk) #1; `assertCaseEqual(mut.single_instr.reg_mem.memory[5], 32'd 7,"ADD: Register 5 should contain 7");


    #1;
    $display("Simulation finished");
    $finish;
end
endmodule