`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 04/22/2025 11:57:13 AM
// Design Name:
// Module Name: ControlUnit
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

module ControlUnit(
    input  [5:0] opcode,
    input  [5:0] funct,
    output reg [3:0] ALU_Con,
    output reg [1:0] RegDst,
    output reg [1:0] ALUSrc,
    output reg [1:0] MemtoReg,
    output reg       RegWrite,
    output reg       MemWrite,
    output reg       Branch,
    output reg       Jump,
    output reg       done
);
  always @(*) begin
    // defaults
    {RegDst,ALUSrc,MemtoReg,RegWrite,MemWrite,Branch,Jump,done,ALU_Con} =
      {2'b00,2'b00,2'b00,1'b0,1'b0,1'b0,1'b0,1'b0,4'b0000};

    case (opcode)
      6'b000000: begin  // R-type
        RegDst   = 2'b01;
        ALUSrc   = 2'b00;
        MemtoReg = 2'b00;
        RegWrite = 1;
        ALU_Con  = funct[3:0];  // assume funct low-4 encode ADD/SUB/AND/OR
        if (funct == 6'h08) Jump = 1; // jr
      end
      6'b100011: begin // lw
        ALUSrc   = 2'b01;
        MemtoReg = 2'b01;
        RegWrite = 1;
        ALU_Con  = 4'b0000;  // ADD
      end
      6'b101011: begin // sw
        ALUSrc   = 2'b01;
        MemWrite = 1;
        ALU_Con  = 4'b0000;  // ADD
      end
      6'b000100: begin // beq
        ALUSrc   = 2'b00;
        Branch   = 1;
        ALU_Con  = 4'b0001;  // SUB
      end
      6'b000010: begin // j
        Jump     = 1;
      end
      6'b001000: begin // addi
        ALUSrc   = 2'b01;
        RegWrite = 1;
        ALU_Con  = 4'b0000;  // ADD
      end
      6'b010001: begin // COP1 (FP) - handle MFC1/MTC1/jalr etc.
        // leave for top-level to route to FPR/GPR
        if (funct[5]==1'b0) begin
          // MFC1 (fmt=00000) → move from FPR to GPR
          MemtoReg = 2'b10;
          RegWrite = 1;
        end else if (funct[5:3] == 3'b100) begin
          // single-precision FP op
          // no GPR writes
        end
      end
      6'b001111: begin // lui
        ALUSrc   = 2'b01;
        RegWrite = 1;
        ALU_Con  = 4'b0111;  // LUI
      end
      6'b001100: begin // andi
        ALUSrc   = 2'b01;
        RegWrite = 1;
        ALU_Con  = 4'b0010;  // AND
      end
      6'b001101: begin // ori
        ALUSrc   = 2'b01;
        RegWrite = 1;
        ALU_Con  = 4'b0011;  // OR
      end
      6'b001110: begin // xori
        ALUSrc   = 2'b01;
        RegWrite = 1;
        ALU_Con  = 4'b0100;  // XOR
      end
      6'b001010: begin // slti
        ALUSrc   = 2'b01;
        RegWrite = 1;
        ALU_Con  = 4'b0101;  // SLT
      end
      default: begin
        if (opcode==6'b111111) done = 1; // e.g. treat ORI as "done" for demo
      end
    endcase
  end
endmodule
