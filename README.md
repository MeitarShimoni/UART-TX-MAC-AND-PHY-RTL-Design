# UART TX MAC & PHY — RTL Design

A complete **SystemVerilog implementation** of a UART Transmit Controller supporting configurable inter-byte delays, matrix-formatted multi-byte transmissions, and a fully integrated **seven-segment display subsystem**.

Validated through testbenches and hardware implementation on the **Nexys A7-100T (Artix-7)** board.

![Demo](design/images/putty_reciving_tx_data.gif)

![Design Waveform](design/images/waveform_test_1_3x3_transactions.png)

## Key Features
* **Configurable Matrix Transmission:** Supports sending single bytes or formatted data matrices ($32^2$, $128^2$, $256^2$).
* [cite_start]**Automatic Formatting:** The controller automatically inserts Space characters (`0x20`) between data bytes and CR/LF (`0x0D`, `0x0A`) sequences at end-of-row.
* [cite_start]**Programmable Delay:** Hardware timers insert delays (0ms, 50ms, 100ms, 200ms) between transactions to accommodate slow receivers.
* **Debounced Input:** Implements a long-press safety mechanism for the Start button.
* **Status Indication:** Real-time feedback via RGB LEDs (Busy/Idle) and Seven-Segment Display (Hexadecimal counters).

---

## Hardware Specifications
* **Board:** Digilent Nexys A7-100T
* **Clock:** 100 MHz System Clock
* **Baud Rate:** 57,600 bps (Derived via `clock_divider` parameter `1736`).
* **Protocol:** 8 Data bits, 1 Stop bit, No Parity.

### Port Map
![Top TX UART Controller](design/images/Top_TX_UART_Controller.png)

| Signal | Direction | Width | Description |
|--------|-----------|-------|-------------|
| `system_clock` | Input | 1 | 100 MHz FPGA system clock |
| `cpu_rst_n` | Input | 1 | Active-low asynchronous reset |
| `SW[7:0]` | Input | 8 | **Data Value:** The byte to be transmitted |
| `SW[9:8]` | Input | 2 | **Delay Config:** Sets inter-byte delay |
| `SW[14:13]` | Input | 2 | **Matrix Config:** Sets number of bytes to send |
| `center_button` | Input | 1 | **Start:** Long-press latch input |
| `TX` | Output | 1 | UART serial line (connect to USB-UART) |
| `LED[0]` | Output | 1 | Toggles on every transmitted byte |
| `busy` / `not_busy`| Output | 1 | Controls RGB LEDs (Red=Busy, Green=Idle) |
| `anode/cathode` | Output | - | Controls 7-segment display content |

---

## Configuration & Usage

The system behavior is controlled via the FPGA switches (`SW`) and the Center Button. The configuration is latched only when the start sequence is initiated.

### 1. Transmission Mode (`SW[14:13]`)
[cite_start]Determines the volume of data sent.

| SW[14:13] | Mode | Description |
| :---: | :--- | :--- |
| `00` | **Single Byte** | Sends `SW[7:0]` once. |
| `01` | **32x32 Matrix** | Sends 1,024 bytes formatted in 32 rows. |
| `10` | **128x128 Matrix** | Sends 16,384 bytes formatted in 128 rows. |
| `11` | **256x256 Matrix** | Sends 65,536 bytes formatted in 256 rows. |

### 2. Inter-Byte Delay (`SW[9:8]`)
[cite_start]Inserts a hardware wait state after every byte sent.

| SW[9:8] | Delay Time |
| :---: | :--- |
| `00` | **0 ms** (Maximum throughput) |
| `01` | **50 ms** |
| `10` | **100 ms** |
| `11` | **200 ms** |

### 3. Initiating Transmission
To avoid accidental transmissions, the design uses a **Long Press** mechanism:
1.  Set switches.
2.  Hold **Center Button** (BTNC).
3.  [cite_start]Wait for the internal counter to reach 64 cycles (approx. 20ms debounce) to latch data and trigger the FSM.

---

## System Architecture

![TX UART Controller Micro Architecture](design/images/micro-architecture.png)

The design is separated into two primary FSMs (Application & Physical layers) and a modular display subsystem.

### 1. Finite State Machines
* **Transmitter FSM (`transmitter.sv`):** Orchestrates matrix formatting (Rows/Columns), injects Special Characters (Space `0x20`, Newline `0x0D 0x0A`), and manages the handshake with the UART core.
* [cite_start]**UART FSM (`uart_fsm_1.sv`):** Handles physical serialization (`START` $\to$ `DATA` $\to$ `STOP`) and implements the programmable `WAIT` state for inter-byte delays.

### 2. Display Subsystem (`top_seven_segment_controller.sv`)
Displays current transaction status using Time-Division Multiplexing:
* [cite_start]**`rotate_register.sv`:** Generates the walking-one sequence to scan the anodes.
* [cite_start]**`anode_decoder.sv`:** Decodes the active anode to select the corresponding 4-bit data nibble.
* [cite_start]**`mux4x1.sv`:** Routes the selected nibble to the segment decoder.
* [cite_start]**`decoder_bin2hex.sv`:** Converts 4-bit binary to 7-segment Hex patterns.

---

### Directory Structure
```text
/design
  ├── Chip_Top_TX.sv                  # Top Level Wrapper
  ├── Top_Transmitter.sv              # Controller Subsystem
  ├── transmitter.sv                  # Application Layer FSM (Matrix Logic)
  ├── uart_fsm_1.sv                   # Physical Layer FSM (UART Protocol)
  ├── button_counter.sv               # Debounce & Latch Logic
  ├── clock_divider.sv                # Baud Rate Generator
  ├── clock_divider32.sv              # Display Refresh Clock
  │
  └── /display
      ├── top_seven_segment_controller.sv # Display Top Level
      ├── rotate_register.sv          # Anode Scanner
      ├── anode_decoder.sv            # Anode Selector Logic
      ├── mux4x1.sv                   # Data Nibble Selector
      └── decoder_bin2hex.sv          # Hex to 7-Seg Decoder
/testbench
  ├── tb_Chip_Top.sv
  ├── tb_top_transmitter.sv
  └── tb_uart_fsm_1.sv
/constraints
  └── Nexys_TX_Controller.xdc
/docs
  └── lab4_meitar_shimoni.pdf
