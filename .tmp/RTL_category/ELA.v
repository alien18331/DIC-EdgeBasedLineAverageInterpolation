`timescale 1ns/10ps

module ELA(clk, rst, in_data, req, out_data, valid);
input clk, rst;
input [7:0] in_data;
output req;
output [7:0] out_data;
output valid;

//--------------------------------------
//  \^o^/   Write your code here~  \^o^/
//--------------------------------------

// ================================= FSM =================================
reg                current_state;
wire               next_state;
reg        [7:0]   out_data;
reg        [7:0]   w_out_data;
reg                valid_1;
reg                valid;
reg                w_valid;
reg                req;
reg                w_req;
reg                en_push;
reg                w_en_push;
reg                en_loop;
reg                w_loop;
reg                r_stall;
wire               w_stall;
// ============================== DATAPATH ===============================
reg        [7:0]   r_data [0:18];
wire       [7:0]   buffer [0:5];
reg        [4:0]   cnt;
wire       [8:0]   cross_add     [0:2];
wire       [7:0]   cross_result;
wire       [7:0]   cross_dif     [0:2];
wire       [7:0]   cross_dif_abs [0:2];
reg        [7:0]   r_cross_abs   [0:2];
reg        [8:0]   r_cross_add   [0:2];
wire       [2:0]   flag;
reg        [7:0]   cal_out;
reg        [7:0]   tmp_data;
reg                r_en_scan;
wire               w_en_scan;
wire               body;

integer            i;

// ================================= FSM =================================
// ---------------------------- Current State ----------------------------
always @(posedge clk) begin
    if (rst) current_state <= 1'b0;
    else current_state <= next_state;
end
// -----------------------------------------------------------------------

// ------------------------------ Next State -----------------------------
assign next_state = current_state | (cnt[4] & cnt[2]);
// -----------------------------------------------------------------------

// ---------------------------- Output - valid ---------------------------
always @(*) begin
    if (~current_state) begin
        case (cnt)
            5'b00000: w_valid = 1'b0;
            5'b10011: w_valid = 1'b0;
            default:  w_valid = 1'b1;
        endcase
    end
    else w_valid = 1'b1;
end
// -----------------------------------------------------------------------

// ----------------------------- Output - req ----------------------------
always @(*) begin
    if (~current_state) begin
        case (cnt)
            5'b10000: w_req = 1'b1;
            default:  w_req = 1'b0;
        endcase
    end
    else w_req = w_stall;
end
// -----------------------------------------------------------------------

// -------------------------- Output - PushData --------------------------
always @(*) begin
    if (~current_state) begin
        case (cnt[3:0])
            4'b1111: w_en_push = 1'b0;
            default: w_en_push = 1'b1;
        endcase
    end
    else w_en_push = ~(cnt == 5'h10);
end
// -----------------------------------------------------------------------

// -------------------------- Output - PushMode --------------------------
always @(*) begin
    if (~current_state) w_loop = 1'b0;
    else begin
        case ({w_stall, cnt})
            5'b00001: w_loop = ~en_loop;
            5'b10001: w_loop = ~en_loop;
            default:  w_loop = en_loop;
        endcase
    end
end
// -----------------------------------------------------------------------

// ------------------------ Output - CounterStall ------------------------
assign w_stall = ~current_state ? 1'b0 : (cnt == 5'h11) ^ r_stall;
// -----------------------------------------------------------------------

// ----------------------- Saving Data in Register -----------------------
always @(posedge clk) if (rst) valid_1  <= 1'b0; else valid_1  <= w_valid;
always @(posedge clk) if (rst) valid    <= 1'b0; else valid    <= w_valid & valid_1;
always @(posedge clk) if (rst) req      <= 1'b1; else req      <= w_req;
always @(posedge clk) if (rst) en_loop  <= 1'b0; else en_loop  <= w_loop;
always @(posedge clk) if (rst) en_push  <= 1'b0; else en_push  <= w_en_push;
always @(posedge clk) if (rst) r_stall  <= 1'b0; else r_stall  <= w_stall;
// -----------------------------------------------------------------------
// =======================================================================

// ============================== DATAPATH ===============================
// ---------------------------- Register File ----------------------------
always @(posedge clk) begin
    if (rst) begin
        for (i = 0; i < 19; i = i + 1)
            r_data[i] <= 8'b0;
    end
    else begin
        if (en_push) begin
            r_data[18] <= en_loop ? r_data[3] : in_data;
            for (i = 4; i < 19; i = i + 1)
                r_data[i - 1] <= r_data[i];
            if (~en_loop) 
                for (i = 1; i < 4; i = i + 1)
                    r_data[i - 1] <= r_data[i];
        end
    end
end
// -----------------------------------------------------------------------

// -------------------------- Pipeline Register --------------------------
always @(posedge clk) begin
    if (rst)
        for (i = 0; i < 3; i = i + 1) begin
            r_cross_abs[i] <= 8'b0;
            r_cross_add[i] <= 8'b0;
        end
    else
        for (i = 0; i < 3; i = i + 1) begin
            r_cross_abs[i] <= cross_dif_abs[i];
            r_cross_add[i] <= cross_add[i];
        end
end

always @(posedge clk) begin
    if (rst) tmp_data <= 8'hff;
    else begin
        if (cnt == 5'h3) tmp_data <= r_data[3];
        else tmp_data <= r_data[2];
    end
end
// -----------------------------------------------------------------------

// -------------------------------- Clock --------------------------------
always @(posedge clk) begin
    if (rst) cnt <= 5'b0;
    else if (~w_stall) cnt <= cnt + 5'b1;
end
// -----------------------------------------------------------------------

// --------------------------- out_data select ---------------------------
assign w_en_scan = cnt[3:0] == 4'h4 ? ~cnt[4] : r_en_scan;
// -----------------------------------------------------------------------

// ----------------------- Saving Data in Register -----------------------
always @(posedge clk) if (rst) r_en_scan = 1'b0; else r_en_scan <= w_en_scan;
// -----------------------------------------------------------------------

// -------------------------- Calculate Circuit --------------------------
// --- Stage 1 ---
assign buffer[0] = r_data[0];
assign buffer[1] = tmp_data;
assign buffer[2] = r_data[2];
assign buffer[3] = r_data[16];
assign buffer[4] = r_data[17];
assign buffer[5] = r_data[18];

assign cross_add[0] = {1'b0, buffer[0]} + {1'b0, buffer[5]};
assign cross_add[1] = {1'b0, buffer[1]} + {1'b0, buffer[4]};
assign cross_add[2] = {1'b0, buffer[2]} + {1'b0, buffer[3]};

assign cross_dif[0] = buffer[0] - buffer[5];
assign cross_dif[1] = buffer[1] - buffer[4];
assign cross_dif[2] = buffer[2] - buffer[3];

assign cross_dif_abs[0] = cross_dif[0][7] ? -cross_dif[0] : cross_dif[0];
assign cross_dif_abs[1] = cross_dif[1][7] ? -cross_dif[1] : cross_dif[1];
assign cross_dif_abs[2] = cross_dif[2][7] ? -cross_dif[2] : cross_dif[2];

// --- Stage 2 ---
assign flag[0] = cnt == 5'b00100 | cnt == 5'b10101;
assign flag[1] = r_cross_abs[0] <= r_cross_abs[2];
assign flag[2] = flag[0] | (r_cross_abs[1] <= (flag[1] ? r_cross_abs[0] : r_cross_abs[2]));

always @(posedge clk) begin
    if (rst) out_data <= 8'b0; 
    else begin
        casex ({flag[2:1], current_state, r_en_scan})
            4'bxx11: out_data <= r_data[16];
            4'b0110: out_data <= r_cross_add[0][8:1] + {7'b0, r_cross_add[0][0]};
            4'b1x10: out_data <= r_cross_add[1][8:1] + {7'b0, r_cross_add[1][0]};
            4'b0010: out_data <= r_cross_add[2][8:1] + {7'b0, r_cross_add[2][0]};
            default: out_data <= r_data[18];
        endcase
    end
end
// =======================================================================

endmodule
