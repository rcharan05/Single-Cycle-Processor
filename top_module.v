
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 04/07/2025 02:16:21 PM
// Module Name: processor_top
// Description: Single-cycle MIPS with integer+FP, using dist_mem_gen IP cores.
//
//////////////////////////////////////////////////////////////////////////////////

module processor_top(
    input         clk,
    input         rst,
    output [9:0]  instr_addr,
    input  [31:0] instr,
    input         ins_we,
    output [9:0]  data_addr,
    inout  [31:0] data,
    input         data_we,
    output [31:0] out,
    output [31:0] hi,lo,
    output        done
);

  wire [31:0] PC;
  reg [31:0] PC_next;
 // assign PC_next = pp_next;
  reg         pc_write;
  PC u_pc (
    .clk      (clk),
    .rst      (rst),
    .pc_write (pc_write),
    .pc_in    (PC_next),
    .pc_out   (PC)
  );
  assign instr_addr = PC[9:0];

  wire [31:0] im_instr;
  dist_mem_gen_1 imem (
    .clk   (clk),
    .we    (ins_we),
    .a     (instr_addr),
    .d     (instr),
    .dpra  (PC[9:0]),
    .dpo   (im_instr)
  );

  wire [3:0]  ALU_Con;
  wire [1:0]  RegDst, ALUSrc, MemtoReg;
  wire        RegWrite, MemWrite, Branch, Jump;
  ControlUnit cu (
    .opcode   (im_instr[31:26]),
    .funct    (im_instr[5:0]),
    .ALU_Con  (ALU_Con),
    .RegDst   (RegDst),
    .ALUSrc   (ALUSrc),
    .MemtoReg (MemtoReg),
    .RegWrite (RegWrite),
    .MemWrite (MemWrite),
    .Branch   (Branch),
    .Jump     (Jump),
    .done     (done)
  );

  wire [4:0]  rf_ra1 = im_instr[25:21];
  wire [4:0]  rf_ra2 = im_instr[20:16];
  reg  [4:0]  rf_wa;
  wire [31:0] rf_rd1, rf_rd2;

  always @(*) begin
    case(RegDst)
      2'b00: rf_wa = im_instr[20:16]; // rt
      2'b01: rf_wa = im_instr[15:11]; // rd
      2'b10: rf_wa = 5'd31;           // link
      default: rf_wa = 5'd0;
    endcase
  end

  wire [31:0] imm   = {{16{im_instr[15]}}, im_instr[15:0]};
  wire [31:0] shmt  = {27'b0, im_instr[10:6]};

  reg [31:0] alu_b;
  always @(*) begin
    case(ALUSrc)
      2'b00: alu_b = rf_rd2;
      2'b01: alu_b = imm;
      2'b10: alu_b = shmt;
      default: alu_b = 32'b0;
    endcase
  end

  wire [31:0] alu_out;
  wire        alu_zero;
  ALU alu_unit (
    .opcode    (im_instr[31:26]),
    .funct     (im_instr[5:0]),
    .A         (rf_rd1),
    .B         (alu_b),
    .Immediate (imm),
    .Shamt     (im_instr[10:6]),
    .PC        (PC),
    .Result    (alu_out),
    .Zero      (alu_zero),
    .hi        (hi),
    .lo        (lo),
    .Overflow  ()
  );

  assign data_addr = alu_out[9:0];
  wire [31:0] dm_data;
  dist_mem_gen_0 dmem (
    .clk  (clk),
    .we   (MemWrite),
    .a    (alu_out[9:0]),
    .d    (rf_rd2),
    .dpra (data_addr),
    .dpo  (dm_data)
  );

  wire [31:0] rf_wd = (MemtoReg==2'b01) ? dm_data :       // load
                      (MemtoReg==2'b10) ? PC + 32'd1 :    // jal
                                          alu_out;        // ALU

  gpr regs (
    .clk        (clk),
    .reset      (rst),
    .reg_write  (RegWrite),
    .rs1        (rf_ra1),
    .rs2        (rf_ra2),
    .write_reg  (rf_wa),
    .write_data (rf_wd),
    .rd1        (rf_rd1),
    .rd2        (rf_rd2)
  );

  wire [31:0] pc_plus4   = PC + 32'd1;
  wire [31:0] branch_off = pc_plus4 + {{14{im_instr[15]}}, im_instr[15:0]};
  wire [31:0] jump_tgt   = {pc_plus4[31:28], im_instr[25:0], 2'b00};
  always @(*) begin
    pc_write = 1'b1;
    if (Branch && alu_zero)
      PC_next = branch_off;
    else if (Jump)
      PC_next = jump_tgt;
    else
      PC_next = pc_plus4;
  end

endmodule
module PC(
    input          clk,
    input          rst,
    input          pc_write,
    input  [31:0]  pc_in,
    output reg [31:0] pc_out
);
  always @(posedge clk or posedge rst) begin
    if (rst)         pc_out <= 32'b0;
    else if (pc_write) pc_out <= pc_in;
  end
endmodule
