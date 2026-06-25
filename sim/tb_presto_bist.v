`timescale 1ns/1ps
// =============================================================================
// TESTBENCH - tb_presto_bist.v
// Add this as SIMULATION SOURCE only in Vivado
// Set simulation top to: tb_presto_bist
// =============================================================================
module tb_presto_bist;

    reg        clk;
    reg        rst;
    reg  [3:0] switching_ip;
    reg  [3:0] hold_reg_in;
    reg  [3:0] toggle_reg_in;
    reg  [7:0] ckt_out;

    wire       z1;
    wire       z2;
    wire [2:0] s_op1;
    wire [2:0] s_op2;
    wire [7:0] ph_shf_op;

    presto_bist_top dut (
        .clk          (clk),
        .rst          (rst),
        .switching_ip (switching_ip),
        .hold_reg_in  (hold_reg_in),
        .toggle_reg_in(toggle_reg_in),
        .ckt_out      (ckt_out),
        .z1           (z1),
        .z2           (z2),
        .s_op1        (s_op1),
        .s_op2        (s_op2),
        .ph_shf_op    (ph_shf_op)
    );

    // 100 MHz clock
    initial clk = 0;
    always #5 clk = ~clk;

    // Registered CUT response - no combinational loop
    always @(posedge clk)
        ckt_out <= ph_shf_op ^ 8'hA5;

    initial begin
        rst           = 1;
        switching_ip  = 4'b0000;
        hold_reg_in   = 4'd3;
        toggle_reg_in = 4'd5;
        ckt_out       = 8'h00;

        repeat(4) @(posedge clk);
        @(negedge clk);
        rst = 0;

        // SCENARIO 1: LP OFF
        $display("=== S1: LP OFF (switching=0000) ===");
        switching_ip = 4'b0000;
        repeat(25) @(posedge clk);
        $display("ph=%h s_op1=%b s_op2=%b z1=%b z2=%b",
                  ph_shf_op,s_op1,s_op2,z1,z2);

        // SCENARIO 2: 50% toggle
        $display("=== S2: 50pct Toggle (switching=1000) ===");
        @(posedge clk); switching_ip = 4'b1000;
        repeat(25) @(posedge clk);
        $display("ph=%h s_op1=%b s_op2=%b z1=%b z2=%b",
                  ph_shf_op,s_op1,s_op2,z1,z2);

        // SCENARIO 3: 25% toggle
        $display("=== S3: 25pct Toggle (switching=0100) ===");
        @(posedge clk); switching_ip = 4'b0100;
        repeat(25) @(posedge clk);
        $display("ph=%h s_op1=%b s_op2=%b z1=%b z2=%b",
                  ph_shf_op,s_op1,s_op2,z1,z2);

        // SCENARIO 4: 12.5% toggle (Low Power)
        $display("=== S4: 12.5pct LP (switching=0010) ===");
        @(posedge clk); switching_ip = 4'b0010;
        repeat(25) @(posedge clk);
        $display("ph=%h s_op1=%b s_op2=%b z1=%b z2=%b",
                  ph_shf_op,s_op1,s_op2,z1,z2);

        // SCENARIO 5: Hold=3 Toggle=7
        $display("=== S5: Hold=3 Toggle=7 (switching=1100) ===");
        @(posedge clk);
        switching_ip  = 4'b1100;
        hold_reg_in   = 4'd3;
        toggle_reg_in = 4'd7;
        repeat(40) @(posedge clk);
        $display("ph=%h z1=%b z2=%b", ph_shf_op,z1,z2);

        $display("=== DONE - No X expected ===");
        $finish;
    end

    initial begin
        $dumpfile("presto_bist.vcd");
        $dumpvars(0, tb_presto_bist);
    end

endmodule
