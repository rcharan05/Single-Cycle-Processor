`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 04/22/2025 11:56:51 AM
// Design Name:
// Module Name: regfiles
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

module gpr (
    input  wire        clk,        // clock
    input  wire        reset,      // synchronous active-high reset
    input  wire        reg_write,  // write enable
    input  wire [4:0]  rs1,        // read address port 1
    input  wire [4:0]  rs2,        // read address port 2
    input  wire [4:0]  write_reg,  // write address
    input  wire [31:0] write_data, // data to write
    output wire [31:0] rd1,        // read data port 1
    output wire [31:0] rd2         // read data port 2
);

  // 32 registers of 32 bits each
  reg [31:0] regs [31:0];

  integer i;
  always @(posedge clk) begin
    if (reset) begin
      // clear all registers to zero on reset
      for (i = 0; i < 32; i = i + 1)
        regs[i] <= 32'b0;
    end else if (reg_write) begin
      // write on rising edge when enabled,
      // if you want x0 hardwired to zero (RISC-V style), uncomment:
      // if (write_reg != 5'd0)
      regs[write_reg] <= write_data;
    end
  end

  // Asynchronous read ports
  assign rd1 = regs[rs1];
  assign rd2 = regs[rs2];

endmodule

module fpr (
    input  wire        clk,        // clock
    input  wire        reset,      // synchronous active-high reset
    input  wire        reg_write,  // write enable
    input  wire [4:0]  rs1,        // read address port 1
    input  wire [4:0]  rs2,        // read address port 2
    input  wire [4:0]  write_reg,  // write address
    input  wire [31:0] write_data, // data to write
    output wire [31:0] rd1,        // read data port 1
    output wire [31:0] rd2         // read data port 2
);

  // 32 registers of 32 bits each
  reg [31:0] regs [31:0];

  integer i;
  always @(posedge clk) begin
    if (reset) begin
      // clear all registers to zero on reset
      for (i = 0; i < 32; i = i + 1)
        regs[i] <= 32'b0;
    end else if (reg_write) begin
      // write on rising edge when enabled,
      // if you want x0 hardwired to zero (RISC-V style), uncomment:
      // if (write_reg != 5'd0)
      regs[write_reg] <= write_data;
    end
  end

  // Asynchronous read ports
  assign rd1 = regs[rs1];
  assign rd2 = regs[rs2];

endmodule
