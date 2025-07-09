`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 04/22/2025 11:56:36 AM
// Design Name:
// Module Name: ALU
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

module ALU(
    input [5:0] opcode,
    input [5:0] funct,
    input [31:0] A,
    input [31:0] B,
    input [31:0] Immediate,
    input [4:0] Shamt,
    input [31:0] PC,
    output reg [31:0] Result,
//    output reg [31:0] BranchAddr,
//    output reg MemRead,
//    output reg MemWrite,
//    output reg [31:0] MemAddr,
//    output reg [31:0] MemWriteData,
    output reg Zero,
    output reg[31:0] hi,
    output reg[31:0] lo,
    output reg Overflow
);
    parameter R_TYPE = 6'b000000;
    parameter ADD    = 6'b100000;
    parameter SUB    = 6'b100001;
    parameter ADDU   = 6'b100010;
    parameter SUBU   = 6'b100011;
    parameter MADD   = 6'b100100;
    parameter MADDU  = 6'b100101;
    parameter MUL    = 6'b100110;
    parameter AND    = 6'b100111;
    parameter OR     = 6'b101000;
    parameter NOT    = 6'b101001;
    parameter XOR    = 6'b101010;
    parameter SLL    = 6'b000000;
    parameter SRL    = 6'b000001;
    parameter SLA    = 6'b000010;
    parameter SRA    = 6'b000011;
    parameter SEQ    = 6'b101011;
    parameter SLT    = 6'b101100;
    parameter JR     = 6'b001000;

    parameter ADDI   = 6'b001000;
    parameter ADDIU  = 6'b001001;
    parameter ANDI   = 6'b001010;
    parameter ORI    = 6'b001011;
    parameter XORI   = 6'b001100;
    parameter LW     = 6'b100011;
    parameter SW     = 6'b101011;
    parameter LI     = 6'b001101;
    parameter BEQ    = 6'b000100;
    parameter BNE    = 6'b000101;
    parameter BGT    = 6'b000110;
    parameter BGTE   = 6'b000111;
    parameter BLT    = 6'b001110;
    parameter BLTE   = 6'b001111;
    parameter BGTU   = 6'b010000;
    parameter BLTU   = 6'b010001;
    parameter J      = 6'b000010;
    parameter JAL    = 6'b000011;

    parameter FPU_OP   = 6'b010001;

parameter fmt_mfc1       = 5'b00000;
parameter fmt_mfc2       = 5'b00100;
parameter fmt_single     = 5'b10000;

parameter adds  = 6'b000000;
parameter subs    = 6'b000001;
parameter muls    = 6'b000010;
parameter divs    = 6'b000011;
parameter movs    = 6'b000110;

parameter ceqs    = 6'b110010;
parameter clts    = 6'b110100;
parameter cles    = 6'b110110;
parameter cgts    = 6'b110111;
parameter cges    = 6'b110101;
wire [31:0] fp_result_add;
wire[31:0] fp_result_mult;
    reg [63:0] mul_result;
    reg [31:0] temp_result;
    wire [31:0] fp_add_res;
wire [31:0] fp_sub_res;
wire        eq;
wire        lt;
wire        le;
wire        gt;
wire        ge;
wire [31:0] negB;

assign negB = {~B[31], B[30:0]};

fp_add_only   fpadd(.a(A),    .b(B),    .result(fp_add_res));
fp_add_only   fpsub(.a(A),    .b(negB), .result(fp_sub_res));
ieee754_compare fpcmp(.a(A),  .b(B),    .eq(eq), .lt(lt), .le(le), .gt(gt), .ge(ge));
    always @(*) begin
//        Result = 32'b0;
//        BranchAddr = 32'b0;

//        MemRead = 1'b0;
//        MemWrite = 1'b0;
//        MemAddr = 32'b0;
//        MemWriteData = 32'b0;
//        Overflow = 1'b0;
        case(opcode)
            R_TYPE: begin
                case(funct)
                    ADD: begin
                        temp_result = $signed(A) + $signed(B);
                        Result = temp_result;
                        Overflow = (A[31] == B[31]) && (Result[31] != A[31]);
                    end
                    SUB: begin
                        temp_result = $signed(A) - $signed(B);
                        Result = temp_result;
                        Overflow = (A[31] != B[31]) && (Result[31] != A[31]);
                    end
                    ADDU: Result = A + B;
                    SUBU: Result = A - B;
                    MADD: begin
                        mul_result = $signed(A) * $signed(B);
                        {hi, lo} = {hi, lo} + mul_result;
                        Result = lo;
                    end
                    MADDU: begin
                        mul_result = A * B;
                        {hi, lo} = {hi, lo} + mul_result;
                        Result = lo;
                    end
                    MUL: begin
                        {hi,lo} = $signed(A) * $signed(B);
                    end
                    AND: Result = A & B;
                    OR:  Result = A | B;
                    NOT: Result = ~A;
                    XOR: Result = A ^ B;
                    SLL: Result = A << Shamt;
                    SRL: Result = A >> Shamt;
                    SLA: Result = A << Shamt;
                    SRA: Result = $signed(A) >>> Shamt;
                    SEQ: Result = (A == B) ? 32'd1 : 32'd0;
                    SLT: Result = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0;
                    JR: begin
                        Zero = 1'b1;
//                        BranchAddr = A;
                    end
                    default: Result = 32'b0;
                endcase
            end
            ADDI: begin
                temp_result = $signed(A) + $signed(Immediate);
                Result = temp_result;
                Overflow = (A[31] == Immediate[31]) && (Result[31] != A[31]);
            end
            ADDIU: Result = A + Immediate;
            ANDI: Result = A & Immediate;
            ORI:  Result = A | Immediate;
            XORI: Result = A ^ Immediate;
            LW: begin
                 Result = A+Immediate;
            end
            SW: begin
                Result = A+Immediate;
            end
            LI: Result = Immediate;
            BEQ: begin
                Zero = (A == B);
                Result=Immediate;
            end
            BNE: begin
                Zero = (A != B);
                Result=Immediate;
            end
            BGT: begin
                Zero = ($signed(A) > $signed(B));
                Result=Immediate;
            end
            BGTE: begin
                Zero = ($signed(A) >= $signed(B));
                Result=Immediate;
            end
            BLT: begin
                Zero = ($signed(A) < $signed(B));
                Result=Immediate;
            end
            BLTE: begin
                Zero = ($signed(A) <= $signed(B));
                Result=Immediate;
            end
            BGTU: begin
                Zero = (A > B);
                Result=Immediate;
            end
            BLTU: begin
                Zero = (A < B);
                Result=Immediate;
            end
            J: begin
                Zero = 1'b1;
                Result=Immediate;
            end
            JAL: begin
                Zero = 1'b1;
                Result=Immediate;
                Result = PC + 4;
            end
            FPU_OP: begin
            case (funct)
                adds:  Result = fp_add_res;
                subs:  Result = fp_sub_res;
                ceqs:  Zero = eq;
                cles:  Zero = le;
                clts:  Zero = lt;
                cges:  Zero = ge;
                cgts:  Zero = gt;
                movs:  Result = B;
                default: Result = 32'b0;
            endcase
            end
            default: Result = 32'b0;
        endcase
        //Zero = (Result == 32'b0);
    end
endmodule

module fp_add_only (
    input  [31:0] a,       // 32-bit IEEE-754 float operand A
    input  [31:0] b,       // 32-bit IEEE-754 float operand B
    output [31:0] result,  // 32-bit IEEE-754 float result
    output reg    overflow,   // Set to 1 if overflow is detected (exp = 255)
    output reg    underflow   // Set to 1 if underflow is detected (exp = 0 and nonzero mantissa)
);

    wire        signA, signB;
    wire [7:0]  expA, expB;
    wire [22:0] fracA, fracB;

    assign signA = a[31];
    assign expA  = a[30:23];
    assign fracA = a[22:0];

    assign signB = b[31];
    assign expB  = b[30:23];
    assign fracB = b[22:0];

    reg  [7:0]  expDiff, expMax;
    reg  [23:0] mantA, mantB;  // 1 extra bit for the hidden '1'

    reg         signOut;
    reg  [7:0]  expOut;
    reg [24:0] mantSum;
    integer i;
    reg [7:0]  expFinal;
    reg [23:0] mantFinal;
     reg [31:0] result_reg;
     assign result = result_reg;
    always @* begin
        signOut = signA;

        if (expA > expB) begin
            expDiff = expA - expB;
            expMax  = expA;
        end else begin
            expDiff = expB - expA;
            expMax  = expB;
        end

        mantA = (expA == 0) ? {1'b0, fracA} : {1'b1, fracA};
        mantB = (expB == 0) ? {1'b0, fracB} : {1'b1, fracB};

        if (expA > expB)
            mantB = mantB >> expDiff;
        else if (expB > expA)
            mantA = mantA >> expDiff;

        expOut = expMax;

        mantSum = mantA + mantB;

        if (mantSum[24] == 1'b1) begin
            mantSum = mantSum >> 1;
            expOut  = expOut + 1;
        end
        else begin

            for(i=0;i<23 && (mantSum[23] == 1'b0) && (mantSum != 0) && (expOut > 0);i=i+1)
            begin
//                if((mantSum[23] == 1'b0) && (mantSum != 0) && (expOut > 0))
//                    break;
                mantSum = mantSum << 1;
                expOut  = expOut - 1;
            end
        end

        overflow  = 1'b0;
        underflow = 1'b0;

        mantFinal = mantSum[23:0];

        if (expOut >= 8'd255) begin
            expFinal = 8'd255; // All ones for exponent => Infinity/NaN region.
            mantFinal = 24'd0;  // Represent as Infinity.
            overflow = 1'b1;
        end

        else if ((expOut == 8'd0) && (mantSum != 0)) begin
            expFinal = 8'd0;
            mantFinal = mantSum[23:0]; // Remains subnormal.
            underflow = 1'b1;
        end
        else begin
            expFinal = expOut;
        end

        result_reg = { signOut, expFinal, mantFinal[22:0] };
    end

endmodule

module fp_mul_only (
    input  [31:0] a,          // IEEE-754 single-precision float operand A
    input  [31:0] b,          // IEEE-754 single-precision float operand B
    output [31:0] result,     // IEEE-754 single-precision float result
    output reg    overflow,   // 1 if overflow detected
    output reg    underflow   // 1 if underflow detected
);

    wire        signA, signB;
    wire [7:0]  expA, expB;
    wire [22:0] fracA, fracB;

    assign signA = a[31];
    assign expA  = a[30:23];
    assign fracA = a[22:0];

    assign signB = b[31];
    assign expB  = b[30:23];
    assign fracB = b[22:0];
    reg [23:0] mantA, mantB;
    reg [47:0] mantProd; // 24+24=48 bits for product
    reg  [10:0]  expSum;  // 1 extra bit to avoid overflow in exponent sum
    reg         signOut; // final sign = signA ^ signB
    reg  [10:0] expOut;
    reg [47:0] mantNorm; // normalized mantissa product
    reg  [7:0]  expFinal;
    reg  [22:0] fracFinal;
    reg [23:0]  roundMant;  // 1 hidden bit + 23 fraction bits
    reg [31:0] result_reg;
    integer i;
    assign result = result_reg;

    always @* begin

        overflow  = 1'b0;
        underflow = 1'b0;
        signOut = signA ^ signB;
        expSum = (expA + expB) - 8'd127;
//        if(expSum>='d255)
//        overflow=1'b1;
        mantA = {1'b1, fracA};
        mantB = {1'b1, fracB};
        mantProd = mantA * mantB;

        mantNorm = mantProd;
        expOut   = expSum[10:0];

        if (mantNorm[47] == 1'b1) begin
            mantNorm = mantNorm >> 1;
            expOut   = expOut + 1;
        end
        else begin

           for(i=0;i<50&&(mantNorm[46] == 1'b0 && mantNorm != 0 && expOut > 0);i=i+1) begin
                mantNorm = mantNorm << 1;
                expOut   = expOut - 1;
            end
        end

        roundMant = mantNorm[46:23];

        if (expOut >= 10'd255) begin
            expFinal = 8'd255;
            fracFinal = 23'd0;
            overflow = 1'b1;
        end
        else if (expOut <= 10'd0) begin
            expFinal = 8'd0;
            if (roundMant[22:0] != 0) begin
                underflow = 1'b1;
            end
            fracFinal = 23'd0;
        end
        else begin
            expFinal  = expOut[7:0];
            fracFinal = roundMant[22:0];
        end
        result_reg = { signOut, expFinal, fracFinal };
    end

endmodule
module ieee754_compare (
    input  [31:0] a,
    input  [31:0] b,
    output reg eq,
    output reg lt,
    output reg le,
    output reg gt,
    output reg ge
);
    wire sign_a = a[31];
    wire sign_b = b[31];
    wire [7:0] exp_a = a[30:23];
    wire [7:0] exp_b = b[30:23];
    wire [22:0] frac_a = a[22:0];
    wire [22:0] frac_b = b[22:0];
    // NaN check: exponent = 255 and mantissa != 0
    wire is_nan_a = (exp_a == 8'hFF) && (frac_a != 0);
    wire is_nan_b = (exp_b == 8'hFF) && (frac_b != 0);
    wire is_nan = is_nan_a || is_nan_b;
    // Zero check (treat +0 and -0 as equal)
    wire is_zero_a = (exp_a == 0) && (frac_a == 0);
    wire is_zero_b = (exp_b == 0) && (frac_b == 0);
    wire is_zero_cmp = is_zero_a && is_zero_b;
    always @(*) begin
        // Default all false
        eq = 0;
        lt = 0;
        le = 0;
        gt = 0;
        ge = 0;
        if (is_nan) begin
            // All comparisons with NaN are false
            eq = 0;
            lt = 0;
            le = 0;
            gt = 0;
            ge = 0;
        end
        else if (is_zero_cmp) begin
            // +0 == -0
            eq = 1;
            le = 1;
            ge = 1;
        end
        else if (a == b) begin
            eq = 1;
            le = 1;
            ge = 1;
        end
        else if (sign_a && !sign_b) begin
            // a negative, b positive
            lt = 1;
            le = 1;
        end
        else if (!sign_a && sign_b) begin
            // a positive, b negative
            gt = 1;
            ge = 1;
        end
        else if (!sign_a && !sign_b) begin
            // Both positive
            if (a < b) begin
                lt = 1;
                le = 1;
            end else begin
                gt = 1;
                ge = 1;
            end
        end
        end
 endmodule
