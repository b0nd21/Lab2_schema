`timescale 1ns / 1ps

module accelerator(
	input rst_i,
	input clk_i,
	input [7:0] a_in,
	input [7:0] b_in,
	output busy_out,
	output [15:0] y_out
);

reg [7:0] a;
reg [7:0] b;
reg [8:0] x;
reg signed[8:0] s;
reg [7:0] r;
reg [3:0] state, state_next;
reg [7:0] mult_i1;
reg [7:0] mult_i2;
wire [15:0] mult_out;
reg mult_reset;
wire mult_busy;

reg [8:0] sum_i1;
reg [8:0] sum_i2;
wire [8:0] sum_o;

reg [8:0] sub_i1;
reg [8:0] sub_i2;
wire [8:0] sub_o;

adder adder1(
    .a(sum_i1),
    .b(sum_i2),
    .y(sum_o)
);

substractor sub1(
    .a(sub_i1),
    .b(sub_i2),
    .y(sub_o)
);

mult mult_1(
	.clk_i(clk_i),
	.rst_i(mult_reset),
	.a_bi(mult_i1),
	.b_bi(mult_i2),
	.busy_o(mult_busy),
	.y_bo(mult_out)
);

localparam STATE0 = 4'b0000;
localparam STATE1 = 4'b0001;
localparam STATE2 = 4'b0010;
localparam STATE3 = 4'b0011;
localparam STATE4 = 4'b0100;
localparam STATE5 = 4'b0101;
localparam STATE6 = 4'b0110;
localparam STATE7 = 4'b0111;
localparam STATE8 = 4'b1000;
localparam STATE9 = 4'b1001;
localparam STATE10 = 4'b1010;
localparam STATE11 = 4'b1011;
localparam STATE12 = 4'b1100;
localparam STATE13 = 4'b1101;
localparam STATE14 = 4'b1110;
localparam STATE15 = 4'b1111;

assign busy_out = rst_i | |state;
assign y_out = r;

always @(posedge clk_i) 
    if (rst_i) begin
        state <= STATE1;
    end else begin
        state <= state_next;
    end
    
always @* begin
        case(state)
            STATE0: state_next = STATE0;
            STATE1: state_next = (s > -3) ? STATE2 : STATE9;
            STATE2: state_next = STATE3;
            STATE3: state_next = mult_busy ? STATE3 : STATE4;
            STATE4: state_next = mult_busy ? STATE4 : STATE5;
            STATE5: state_next = STATE6;
            STATE6: state_next = (x >= b) ? STATE7 : STATE9;
            STATE7: state_next = STATE8;
            STATE8: state_next = STATE9;
            STATE9: state_next = (s > -3) ? STATE1 : STATE10;
            STATE10: state_next = STATE11;
            STATE11: state_next = mult_busy ? STATE11 : STATE12;
            STATE12: state_next = STATE0;
        endcase
end

always @(posedge rst_i) begin
    
end

always @(posedge clk_i) begin
    if (rst_i) begin
        a <= a_in;
        x <= b_in;
        s <= 6;
        r <= 0;
        mult_reset <= 0;
    end else begin
    case (state)
        STATE0:
            begin
            end
        STATE1:
            begin
                r = r << 1;
                sum_i1 <= r;
                sum_i2 <= 1;
            end
        STATE2:
            begin
                    mult_reset <= 1;
                    mult_i1 <= sum_o;
                    mult_i2 <= r;
            end
        STATE3:
            begin
                if (mult_busy) begin
                    mult_reset <= 0;
                end else begin
                    mult_reset <= 1;
                    mult_i1 <= mult_out;
                    mult_i2 <= 3;
            end end
        STATE4:
            begin
                if (mult_busy) begin
                    mult_reset <= 0;
                end else begin
                    sum_i1 = mult_out;
                    sum_i2 = 1;
            end end
        STATE5: b = sum_o << s;
        STATE6: 
            begin
                if (x >= b) begin
                    sub_i1 = x;
                    sub_i2 = b;    
                end else begin
                    sub_i1 = s;
                    sub_i2 = 3;
                end end
        STATE7:
            begin
              x <= sub_o;
              sum_i1 = r;
              sum_i2 = 1;
            end
        STATE8:
            begin
                r <= sum_o;
                sub_i1 = s;
                sub_i2 = 3;
             end
        STATE9: s <= sub_o;
        STATE10:
            begin
                r = r >> 1;
                mult_reset <= 1;
                mult_i1 <= a;
                mult_i2 <= a;
            end
        STATE11:
         begin
            if (mult_busy) begin
            mult_reset <= 0;
            end else begin
                mult_reset <= 1;
                sum_i1 <= mult_out;
                sum_i2 <= r;
          end
          end
        STATE12:r <= sum_o;
    endcase
    end
end

endmodule