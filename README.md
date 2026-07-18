# SystemVerilog APB Protocol Implementation

This repository contains a modern **SystemVerilog** implementation of the ARM AMBA Advanced Peripheral Bus (APB) Protocol. It includes a fully functional Master, a Memory-mapped Slave, a Top-level interconnect, and a comprehensive simulation testbench. 

## Features

* **SystemVerilog Best Practices:** Utilizes modern SV constructs like `logic`, `always_ff`, and `always_comb` to prevent simulation-synthesis mismatches.
* **ARM AMBA Compliance:** Implements standard APB3/APB4 signals including `PREADY` for wait-state insertion and `PSLVERR` for slave error reporting.
* **Configurable Architecture:** Address width, data width, and memory depth are fully parameterizable.

##  File Structure

| File | Description |
| :--- | :--- |
| `APB_master.sv` | The APB Master block. Converts simple read/write control signals into standard APB bus transactions (IDLE $\rightarrow$ SETUP $\rightarrow$ ACCESS). |
| `APB_slave.sv` | The APB Slave block. Acts as a memory array that responds to Master requests, handles read/writes, and drives `PREADY` / `PSLVERR`. |
| `apb_top.sv` | The top-level wrapper that instantiates and connects the Master and Slave modules over the APB bus. |
| `APB_tb.sv` | A self-contained testbench demonstrating normal writes, normal reads, and out-of-bounds error handling. |

##  Protocol State Machine

The APB Master operates using the standard three-state AMBA specification:
1. **IDLE:** The default state when no transfers are active.
2. **SETUP:** Entered when a transfer is requested. `PSEL` is asserted, and the address/data/control signals are driven.
3. **ACCESS:** Entered on the next clock cycle. `PENABLE` is asserted. The master waits here if the slave drives `PREADY` low. Once `PREADY` is high, the data is captured, and the state returns to IDLE or jumps back to SETUP for back-to-back transfers.

