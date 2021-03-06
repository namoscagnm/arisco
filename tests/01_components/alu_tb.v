`default_nettype none

`include "rtl/parameters.vh"

module tb_alu ();

reg [ALU_LENGTH-1:0] opcode;
reg [31:0] left;
reg [31:0] right;
wire [31:0] result;

task enforce_result;
    input [ALU_LENGTH-1:0] opcode_;
    input [31:0] left_, right_, result_should;
     
    begin
      // demonstrates driving external Global Reg
      #1;
      left=left_;
      right=right_;
      opcode=opcode_;

      #1;
      if (result != result_should) begin
        $display("%c[1;31m",27);
        $fatal();
        $display("%c[0m",27);
      end
    end
  endtask


ALU mut (
    .opcode (opcode),
    .left (left),
    .right (right),
    .result (result)
);

initial
begin
    $dumpfile("ALU.vcd");
    $dumpvars(0,mut);
    //$monitor("%2t,opcode=%d,left=%d,right=%d,result=%d",$time,opcode,left,right,result);

    $info("ALU unit test");
    enforce_result(ALU_ADD,32'h4,32'h3,32'h7); //ADD
    enforce_result(ALU_AND,32'b1100,32'b1010,32'b1000); //AND
    enforce_result(ALU_SUB,32'd 7,32'd 3,32'd 4); //SUB

    #1;
    $display("Simulation finished");
    $finish;
end
endmodule
