## =============================================================================
## Constraints File: presto_bist.xdc
## Target: Artix-7 xc7a35tcpg236-1 (adjust pin numbers for your board)
## =============================================================================

## Clock - 100 MHz on pin W5 (Basys3) or adjust for your board
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -add -name sys_clk -period 10.00 -waveform {0 5} [get_ports clk]

## Reset - active high, mapped to center button on Basys3
set_property PACKAGE_PIN U18 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]

## switching_ip[3:0] - mapped to SW3..SW0 on Basys3
set_property PACKAGE_PIN V17 [get_ports {switching_ip[0]}]
set_property PACKAGE_PIN V16 [get_ports {switching_ip[1]}]
set_property PACKAGE_PIN W16 [get_ports {switching_ip[2]}]
set_property PACKAGE_PIN W17 [get_ports {switching_ip[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {switching_ip[*]}]

## hold_reg_in[3:0] - SW7..SW4
set_property PACKAGE_PIN W15 [get_ports {hold_reg_in[0]}]
set_property PACKAGE_PIN V15 [get_ports {hold_reg_in[1]}]
set_property PACKAGE_PIN W14 [get_ports {hold_reg_in[2]}]
set_property PACKAGE_PIN W13 [get_ports {hold_reg_in[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {hold_reg_in[*]}]

## toggle_reg_in[3:0] - SW11..SW8
set_property PACKAGE_PIN V2  [get_ports {toggle_reg_in[0]}]
set_property PACKAGE_PIN T3  [get_ports {toggle_reg_in[1]}]
set_property PACKAGE_PIN T2  [get_ports {toggle_reg_in[2]}]
set_property PACKAGE_PIN R3  [get_ports {toggle_reg_in[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {toggle_reg_in[*]}]

## ckt_out[7:0] - SW15..SW8 (or tie to GND if no board)
set_property PACKAGE_PIN W2  [get_ports {ckt_out[0]}]
set_property PACKAGE_PIN U1  [get_ports {ckt_out[1]}]
set_property PACKAGE_PIN T1  [get_ports {ckt_out[2]}]
set_property PACKAGE_PIN R2  [get_ports {ckt_out[3]}]
set_property PACKAGE_PIN R1  [get_ports {ckt_out[4]}]
set_property PACKAGE_PIN P3  [get_ports {ckt_out[5]}]
set_property PACKAGE_PIN P1  [get_ports {ckt_out[6]}]
set_property PACKAGE_PIN N3  [get_ports {ckt_out[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ckt_out[*]}]

## ph_shf_op[7:0] - LED outputs LD7..LD0 on Basys3
set_property PACKAGE_PIN U16 [get_ports {ph_shf_op[0]}]
set_property PACKAGE_PIN E19 [get_ports {ph_shf_op[1]}]
set_property PACKAGE_PIN U19 [get_ports {ph_shf_op[2]}]
set_property PACKAGE_PIN V19 [get_ports {ph_shf_op[3]}]
set_property PACKAGE_PIN W18 [get_ports {ph_shf_op[4]}]
set_property PACKAGE_PIN U15 [get_ports {ph_shf_op[5]}]
set_property PACKAGE_PIN U14 [get_ports {ph_shf_op[6]}]
set_property PACKAGE_PIN V14 [get_ports {ph_shf_op[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ph_shf_op[*]}]

## z1, z2 - LD8, LD9
set_property PACKAGE_PIN V13 [get_ports z1]
set_property PACKAGE_PIN V3  [get_ports z2]
set_property IOSTANDARD LVCMOS33 [get_ports z1]
set_property IOSTANDARD LVCMOS33 [get_ports z2]

## s_op1[2:0] - LD12..LD10
set_property PACKAGE_PIN W3  [get_ports {s_op1[0]}]
set_property PACKAGE_PIN U3  [get_ports {s_op1[1]}]
set_property PACKAGE_PIN P3  [get_ports {s_op1[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {s_op1[*]}]

## s_op2[2:0] - LD15..LD13
set_property PACKAGE_PIN N2  [get_ports {s_op2[0]}]
set_property PACKAGE_PIN P1  [get_ports {s_op2[1]}]
set_property PACKAGE_PIN L1  [get_ports {s_op2[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {s_op2[*]}]
