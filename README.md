# PRESTO BIST Test Pattern Generator
**High-Performance Pattern Test Generator for Built-In Self-Test (BIST)**  
Verilog Implementation for Xilinx Basys3 FPGA (Artix-7) | Vivado 2020+

> Based on: *High-Performance Pattern Test Generator for BIST* — Reshmi Nair & Nandini Maheshwari, Sathyabama Institute of Science and Technology, 2022

---

## Overview

Modern chips are tested using **Built-In Self-Test (BIST)** — circuits embedded on the chip itself that generate test patterns, apply them to internal logic, and check the responses, all without external test equipment. The problem: standard BIST pattern generators switch every signal on every clock cycle, consuming far more power during testing than the chip ever would in normal operation. This can cause overheating, voltage droops, and even permanent damage during production test.

**PRESTO** (Probabilistic Test Pattern Generator) solves this by intelligently controlling *which* scan chains receive new patterns each cycle and *which* are frozen. Frozen chains draw no switching power. The result is dramatically lower test power with no loss in fault coverage.

This implementation realises the complete PRESTO architecture in **synthesizable Verilog**, targeting the Xilinx **Basys3 FPGA (Artix-7)**. The switching activity level — from 6.25% up to 100% — is controlled in real time via on-board slide switches, making the trade-off between power and test speed directly observable on hardware.

### Why PRESTO over standard LFSR-based BIST?

| Feature | Standard LFSR BIST | PRESTO BIST |
|---|---|---|
| Switching activity | ~100% every cycle | Configurable: 6.25% – 100% |
| Test power | High — can exceed normal operating power | Significantly reduced |
| Fault coverage | Good | Equivalent (phase shifter maintains independence) |
| Flexibility | Fixed | Programmable hold/toggle durations |
| Hardware overhead | Minimal | Small (hold latches + weighted logic) |

---

## Architecture

The design is composed of 9 hardware modules that together implement the PRESTO BIST TPG:

```
LFSR (PRPG) ──► Weighted Logic ──► Toggle Ctrl Reg ──► Hold Latch Array ──► Phase Shifter ──► Scan Chains
     │                                      ▲                                         │
     └──► Shift Register (secondary LFSR) ──┘                                         │
                                                                                       ▼
T Flip-Flop ◄── Down Counter ◄── Mode MUX                               MISR (Response Analyser)
```

| Module | Purpose |
|--------|---------|
| `lfsr_8bit` | 8-bit Galois LFSR — generates pseudorandom test patterns (PRPG) |
| `weighted_logic` | AND-gate tree — produces enable signals at controlled probabilities (6.25% / 12.5% / 25% / 50%) |
| `toggle_ctrl_reg` | 8-bit register — decides which hold latches are in toggle vs. hold mode |
| `hold_latch_array` | Per-bit hold latches — freezes scan chain inputs to eliminate unnecessary transitions |
| `phase_shifter` | XOR tree — decorrelates latch outputs so scan chains receive statistically independent patterns |
| `t_flipflop` | Toggle flip-flop — alternates the generator between hold phase and toggle phase |
| `down_counter` | 4-bit down counter — controls the duration of each hold/toggle phase |
| `misr_8bit` | Multiple Input Signature Register — compresses CUT responses into an 8-bit signature for pass/fail |
| `presto_bist_top` | Top-level integration of all modules |

---

## Repository Structure

```
presto-bist-tpg/
├── src/
│   └── presto_bist_impl.v       # All 9 synthesizable hardware modules
├── sim/
│   └── tb_presto_bist.v         # 5-scenario self-checking testbench
├── constraints/
│   └── presto_bist.xdc          # Basys3 (Artix-7) pin and timing constraints
└── README.md
```

---

## Test Scenarios

The testbench exercises 5 operating modes:

| Scenario | `switching_ip` | Behaviour |
|----------|---------------|-----------|
| LP OFF (100%) | `4'b0000` | All hold latches transparent — maximum activity |
| 50% Toggle | `4'b1000` | ~50% of scan chains toggle per pattern |
| 25% Toggle | `4'b0100` | Matches the report's primary example |
| 12.5% Low Power | `4'b0010` | Very few transitions — minimal power draw |
| Hold/Toggle Phase | `4'b1100` | Phases alternate: stable for N cycles, then active for M cycles |

---

## FPGA Pin Mapping (Basys3)

| Verilog Port | Direction | Board Component | Pin(s) |
|---|---|---|---|
| `clk` | IN | 100 MHz Oscillator | W5 |
| `rst` | IN | Center Button | U18 |
| `switching_ip[3:0]` | IN | Slide Switches SW3–SW0 | W17, W16, V16, V17 |
| `hold_reg_in[3:0]` | IN | Slide Switches SW7–SW4 | W13, W14, V15, W15 |
| `toggle_reg_in[3:0]` | IN | Slide Switches SW11–SW8 | R3, T2, T3, V2 |
| `ckt_out[7:0]` | IN | Slide Switches SW15–SW8 | N3..W2 |
| `ph_shf_op[7:0]` | OUT | LEDs LD7–LD0 | V14..U16 |
| `z1` | OUT | LED LD8 | V13 |
| `z2` | OUT | LED LD9 | V3 |

---

## How to Use in Vivado

### Simulation
1. Create a new Vivado project targeting `xc7a35tcpg236-1` (Basys3)
2. Add `src/presto_bist_impl.v` as a **Design Source**
3. Add `sim/tb_presto_bist.v` as a **Simulation Source**
4. Right-click `tb_presto_bist` → **Set as Top** (simulation only)
5. Run **Flow → Run Simulation → Run Behavioral Simulation**

### Synthesis & Implementation
1. Right-click `presto_bist_top` → **Set as Top**
2. Add `constraints/presto_bist.xdc` as a **Constraints file**
3. Run **Flow → Run Synthesis**, then **Flow → Run Implementation**
4. Generate bitstream and program the board

> **Note:** Never synthesize the testbench file. `$display` and `$finish` are simulation-only constructs.

---

## Key Implementation Notes

- **`(* DONT_TOUCH = "yes" *)`** is applied to `presto_bist_top` to prevent Vivado's `opt_design` from removing logic whose outputs appear unused during synthesis without a testbench (fixes `[Place 30-494] Design is Empty`).
- The `hold_latch_array` uses explicit per-bit `if` statements instead of a `for` loop to avoid an implicit 32-bit loop variable (`i[31:0]`) appearing as `XXXXXXXX` in simulation.
- The MISR is explicitly initialized on reset to prevent X-propagation through XOR chains.
- `timescale 1ns/1ps` is declared once at the top of the design file and applies to all modules.

---

## Applications

PRESTO BIST is applicable wherever test power is a concern — which in practice means almost every modern chip:

**Semiconductor Manufacturing & Production Test**
Chips are tested at high clock speeds after fabrication. Excessive switching can cause IR-drop (supply voltage sagging) and false failures. PRESTO reduces this risk by limiting unnecessary transitions, making test results more reliable.

**Embedded Systems & IoT Devices**
Battery-powered devices cannot afford the power spike that full-switching BIST causes. PRESTO allows self-test to run during idle periods without draining the battery.

**Automotive & Safety-Critical ICs**
ISO 26262 (automotive functional safety) requires periodic self-test of embedded processors during vehicle operation. Low-power BIST ensures self-test doesn't interfere with normal circuit operation or violate thermal budgets.

**SoC (System-on-Chip) Design**
Large SoCs have thousands of scan chains. Running all of them at full toggle rate during test can exceed the chip's power delivery network limits. PRESTO's configurable switching activity allows designers to stay within power budgets while still achieving high fault coverage.

**Academic & Research Use**
This implementation serves as a complete, working reference for students and researchers studying:
- Low-power design-for-testability (DFT)
- LFSR-based pseudorandom pattern generation
- Weighted random pattern testing
- MISR-based response compaction
- FPGA prototyping of ASIC test architectures

---

## Reference

> R. Nair and N. Maheshwari, "High-Performance Pattern Test Generator for BIST," Sathyabama Institute of Science and Technology, 2022.
