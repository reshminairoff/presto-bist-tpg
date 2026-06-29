`timescale 1ns/1ps
// =============================================================================
// PRESTO BIST TPG - IMPLEMENTATION READY VERSION
// Fix [Place 30-494]: Separated design file from testbench
// Fix [Common 17-69]: Added proper port constraints via synthesis attributes
// 
// VIVADO SETUP INSTRUCTIONS:
//   Step 1: Add THIS file as Design Source (not simulation)
//   Step 2: Add tb_presto_bist.v as Simulation Source (separate file)
//   Step 3: Set presto_bist_top as Synthesis Top
//   Step 4: Set tb_presto_bist as Simulation Top
// =============================================================================

// -----------------------------------------------------------------------------
// MODULE 1: 8-bit LFSR
// -----------------------------------------------------------------------------
module lfsr_8bit (
    input  wire       clk,
    input  wire       rst,
    input  wire       enable,
    output reg  [7:0] lfsr_out
);
    always @(posedge clk) begin
        if (rst)
            lfsr_out <= 8'b1000_0001;
        else if (enable)
            lfsr_out <= {lfsr_out[6:0],
                         lfsr_out[7] ^ lfsr_out[5] ^ 
                         lfsr_out[4] ^ lfsr_out[3]};
    end
endmodule

// -----------------------------------------------------------------------------
// MODULE 2: Weighted Logic
// -----------------------------------------------------------------------------
module weighted_logic (
    input  wire [7:0] prpg_in,
    input  wire [3:0] switching_code,
    output wire       weighted_out
);
    wire tap_half      = prpg_in[7];
    wire tap_quarter   = prpg_in[7] & prpg_in[6];
    wire tap_eighth    = prpg_in[7] & prpg_in[6] & prpg_in[5];
    wire tap_sixteenth = prpg_in[7] & prpg_in[6] & 
                         prpg_in[5] & prpg_in[4];

    assign weighted_out = (switching_code[3] & tap_half)
                        | (switching_code[2] & tap_quarter)
                        | (switching_code[1] & tap_eighth)
                        | (switching_code[0] & tap_sixteenth);
endmodule

// -----------------------------------------------------------------------------
// MODULE 3: Toggle Control Register
// -----------------------------------------------------------------------------
module toggle_ctrl_reg (
    input  wire clk,
    input  wire rst,
    input  wire load,
    input  wire [7:0] shift_data,
    input  wire off_mode,
    output reg [7:0] ctrl_reg_out
);
    always @(posedge clk) begin
        if (rst)
        begin
            ctrl_reg_out <= 8'b1111_1111;
        end 
        else if (off_mode)
        begin
            ctrl_reg_out <= 8'b1111_1111;
        end
        else if (load)
        begin
            ctrl_reg_out <= shift_data;
        end
        end
endmodule

// -----------------------------------------------------------------------------
// MODULE 4: Hold Latch Array - fully unrolled, no loop variable
// -----------------------------------------------------------------------------
module hold_latch_array (
    input  wire       clk,
    input  wire       rst,
    input  wire [7:0] prpg_data,
    input  wire [7:0] ctrl,
    output reg  [7:0] latch_out
);
    always @(posedge clk) begin
        if (rst) begin
            latch_out <= 8'b0000_0000;
        end else begin
            if (ctrl[0]) latch_out[0] <= prpg_data[0];
            if (ctrl[1]) latch_out[1] <= prpg_data[1];
            if (ctrl[2]) latch_out[2] <= prpg_data[2];
            if (ctrl[3]) latch_out[3] <= prpg_data[3];
            if (ctrl[4]) latch_out[4] <= prpg_data[4];
            if (ctrl[5]) latch_out[5] <= prpg_data[5];
            if (ctrl[6]) latch_out[6] <= prpg_data[6];
            if (ctrl[7]) latch_out[7] <= prpg_data[7];
        end
    end
endmodule

// -----------------------------------------------------------------------------
// MODULE 5: Phase Shifter
// -----------------------------------------------------------------------------
module phase_shifter (
    input  wire [7:0] latch_in,
    output wire [7:0] ph_shf_op
);
    assign ph_shf_op[0] = latch_in[0] ^ latch_in[1] ^ latch_in[2];
    assign ph_shf_op[1] = latch_in[1] ^ latch_in[2] ^ latch_in[3];
    assign ph_shf_op[2] = latch_in[2] ^ latch_in[3] ^ latch_in[4];
    assign ph_shf_op[3] = latch_in[3] ^ latch_in[4] ^ latch_in[5];
    assign ph_shf_op[4] = latch_in[4] ^ latch_in[5] ^ latch_in[6];
    assign ph_shf_op[5] = latch_in[5] ^ latch_in[6] ^ latch_in[7];
    assign ph_shf_op[6] = latch_in[6] ^ latch_in[7] ^ latch_in[0];
    assign ph_shf_op[7] = latch_in[7] ^ latch_in[0] ^ latch_in[1];
endmodule

// -----------------------------------------------------------------------------
// MODULE 6: T Flip-Flop
// -----------------------------------------------------------------------------
module t_flipflop (
    input  wire clk,
    input  wire rst,
    input  wire t_in,
    output reg  t_out
);
    always @(posedge clk) begin
        if (rst)   t_out <= 1'b1;
        else if (t_in) t_out <= ~t_out;
    end
endmodule

// -----------------------------------------------------------------------------
// MODULE 7: Down Counter
// -----------------------------------------------------------------------------
module down_counter (
    input  wire       clk,
    input  wire       rst,
    input  wire [3:0] load_val,
    input  wire       load,
    output reg        done
);
    reg [3:0] count;
    always @(posedge clk) begin
        if (rst) begin
            count <= 4'd8;
            done  <= 1'b0;
        end else if (load) begin
            count <= load_val;
            done  <= 1'b0;
        end else if (count > 4'd0) begin
            count <= count - 4'd1;
            done  <= (count == 4'd1);
        end else begin
            done <= 1'b0;
        end
    end
endmodule

// -----------------------------------------------------------------------------
// MODULE 8: MISR
// -----------------------------------------------------------------------------
module misr_8bit (
    input  wire       clk,
    input  wire       rst,
    input  wire [7:0] data_in,
    output reg  [7:0] misr_out
);
    always @(posedge clk) begin
        if (rst)
            misr_out <= 8'b0000_0000;
        else begin
            misr_out[0] <= data_in[0] ^ misr_out[7];
            misr_out[1] <= data_in[1] ^ misr_out[0] ^ misr_out[7];
            misr_out[2] <= data_in[2] ^ misr_out[1] ^ misr_out[7];
            misr_out[3] <= data_in[3] ^ misr_out[2] ^ misr_out[7];
            misr_out[4] <= data_in[4] ^ misr_out[3] ^ misr_out[7];
            misr_out[5] <= data_in[5] ^ misr_out[4];
            misr_out[6] <= data_in[6] ^ misr_out[5] ^ misr_out[7];
            misr_out[7] <= data_in[7] ^ misr_out[6];
        end
    end
endmodule

// =============================================================================
// TOP MODULE: presto_bist_top
// (* keep_hierarchy = "yes" *) prevents opt_design from collapsing hierarchy
// (* DONT_TOUCH = "yes" *)     prevents opt_design from sweeping output regs
// =============================================================================
(* DONT_TOUCH = "yes" *)
module presto_bist_top (
    input  wire       clk,
    input  wire       rst,
    input  wire [3:0] switching_ip,
    input  wire [3:0] hold_reg_in,
    input  wire [3:0] toggle_reg_in,
    input  wire [7:0] ckt_out,
    output wire       z1,
    output wire       z2,
    output wire [2:0] s_op1,
    output wire [2:0] s_op2,
    output wire [7:0] ph_shf_op
);

    wire [7:0] lfsr_out;
    wire [7:0] shift_reg_data;
    wire [7:0] ctrl_reg;
    wire [7:0] latch_data;
    wire [7:0] misr_sig;
    wire       weighted_en;
    wire       off_mode;
    wire       lfsr_en;
    wire       t_ff_out;
    wire       counter_done;
    wire [3:0] counter_load_val;

    assign off_mode         = ~|switching_ip;
    assign lfsr_en          = t_ff_out | off_mode;
    assign counter_load_val = t_ff_out ? toggle_reg_in : hold_reg_in;

    (* DONT_TOUCH = "yes" *)
    lfsr_8bit u0_lfsr (
        .clk(clk), .rst(rst),
        .enable(lfsr_en), .lfsr_out(lfsr_out)
    );

    (* DONT_TOUCH = "yes" *)
    weighted_logic u1_wl (
        .prpg_in(lfsr_out),
        .switching_code(switching_ip),
        .weighted_out(weighted_en)
    );

    (* DONT_TOUCH = "yes" *)
    lfsr_8bit u2_shift_reg (
        .clk(clk), .rst(rst),
        .enable(weighted_en), .lfsr_out(shift_reg_data)
    );

    (* DONT_TOUCH = "yes" *)
    toggle_ctrl_reg u3_tcr (
        .clk(clk), .rst(rst),
        .load(counter_done),
        .shift_data(shift_reg_data),
        .off_mode(off_mode),
        .ctrl_reg_out(ctrl_reg)
    );

    (* DONT_TOUCH = "yes" *)
    hold_latch_array u4_hla (
        .clk(clk), .rst(rst),
        .prpg_data(lfsr_out),
        .ctrl(ctrl_reg),
        .latch_out(latch_data)
    );

    (* DONT_TOUCH = "yes" *)
    phase_shifter u5_ps (
        .latch_in(latch_data),
        .ph_shf_op(ph_shf_op)
    );

    (* DONT_TOUCH = "yes" *)
    t_flipflop u6_tff (
        .clk(clk), .rst(rst),
        .t_in(counter_done & ~off_mode),
        .t_out(t_ff_out)
    );

    (* DONT_TOUCH = "yes" *)
    down_counter u7_dc (
        .clk(clk), .rst(rst),
        .load_val(counter_load_val),
        .load(counter_done),
        .done(counter_done)
    );

    (* DONT_TOUCH = "yes" *)
    misr_8bit u8_misr (
        .clk(clk), .rst(rst),
        .data_in(ckt_out),
        .misr_out(misr_sig)
    );

    assign z1    = misr_sig[0];
    assign z2    = misr_sig[7];
    assign s_op1 = ph_shf_op[2:0];
    assign s_op2 = ph_shf_op[5:3];

endmodule
