# UART TX Controller — FPGA RTL Design

A complete **SystemVerilog implementation** of a UART Transmit Controller supporting configurable inter-byte delays, matrix-formatted multi-byte transmissions, and a fully integrated **seven-segment display subsystem**.

Validated through testbenches and hardware implementation on the **Nexys A7-100T (Artix-7)** board.

![Design Waveform](design/images/waveform_test_1_3x3_transactions.png)

## 🚀 Key Features
* **Configurable Matrix Transmission:** Supports sending single bytes or formatted data matrices ($32^2$, $128^2$, $256^2$).
* [cite_start]**Automatic Formatting:** The controller automatically inserts Space characters (`0x20`) between data bytes and CR/LF (`0x0D`, `0x0A`) sequences at end-of-row [cite: 16-18, 255].
* [cite_start]**Programmable Delay:** Hardware timers insert delays (0ms, 50ms, 100ms, 200ms) between transactions to accommodate slow receivers [cite: 637-640].
* [cite_start]**Debounced Input:** Implements a long-press safety mechanism for the Start button [cite: 36-37].
* [cite_start]**Status Indication:** Real-time feedback via RGB LEDs (Busy/Idle) and Seven-Segment Display (Hexadecimal counters) [cite: 287-289].

---

## 🛠 Hardware Specifications
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

## ⚙️ Configuration & Usage

The system behavior is controlled via the FPGA switches (`SW`) and the Center Button. The configuration is latched only when the start sequence is initiated.

### 1. Transmission Mode (`SW[14:13]`)
[cite_start]Determines the volume of data sent [cite: 43-45, 69-70].

| SW[14:13] | Mode | Description |
| :---: | :--- | :--- |
| `00` | **Single Byte** | Sends `SW[7:0]` once. |
| `01` | **32x32 Matrix** | Sends 1,024 bytes formatted in 32 rows. |
| `10` | **128x128 Matrix** | Sends 16,384 bytes formatted in 128 rows. |
| `11` | **256x256 Matrix** | Sends 65,536 bytes formatted in 256 rows. |

### 2. Inter-Byte Delay (`SW[9:8]`)
[cite_start]Inserts a hardware wait state after every byte sent [cite: 39-42, 636-640].

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
3.  [cite_start]Wait for the internal counter to reach 64 cycles (approx. 20ms debounce) to latch data and trigger the FSM [cite: 36-37].

---

## 🏗 System Architecture

![TX UART Controller Micro Architecture](design/images/micro-architecture.png)

The design is separated into two primary Finite State Machines (FSMs) to decouple protocol handling from application logic.

### 1. High-Level Transmitter FSM (`transmitter.sv`)
This module acts as the "Application Layer." It orchestrates the entire matrix transmission.
* **Logic:** It tracks `row_counter` and `line_counter`.
* **Formatting:**
    * [cite_start]**Space Injection:** If `row_counter` is odd, it requests the UART to send `0x20` (Space)[cite: 18].
    * [cite_start]**Newline Injection:** At the end of a row (`num_bytes*2`), it requests `0x0D` (CR) and `0x0A` (LF) [cite: 16-17].
* [cite_start]**Handshake:** It waits for the `busy_uart` signal to de-assert before loading the next character[cite: 30].

### 2. Low-Level UART FSM (`uart_fsm_1.sv`)
This module acts as the "Physical Layer."
* **States:** `IDLE` $\to$ `START` $\to$ `DATA` (Shift LSB) $\to$ `STOP` $\to$ `WAIT`.
* **Wait State:** Unlike standard UARTs, this FSM enters a `WAIT` state after `STOP`. [cite_start]It remains there until `count_delay` matches the user-selected delay value[cite: 650, 656].

---

## 📊 Verification & Results

### Simulation
The design was verified using a full-chip testbench (`Chip_Top_TX`). The waveform below demonstrates a $3\times3$ matrix transmission. Note the `SPECIAL_CHAR` states where spaces and newlines are inserted automatically.

### Synthesis (Vivado)
* **Target Device:** Artix-7 (xc7a100tcsg324-1)
* [cite_start]**LUT Utilization:** ~203 LUTs (<1%) [cite: 590-593].
* [cite_start]**Timing:** 100MHz constraint met with 0 errors/warnings[cite: 530, 560].

---

### 📂 Directory Structure
```text
/design
  ├── Chip_Top_TX.sv         # Top Level Wrapper
  ├── Top_Transmitter.sv     # Controller Subsystem
  ├── transmitter.sv         # Application Layer FSM (Matrix Logic)
  ├── uart_fsm_1.sv          # Physical Layer FSM (UART Protocol)
  ├── button_counter.sv      # Debounce & Latch Logic
  ├── anode_decoder.sv       # 7-Segment Driver
  └── clock_divider.sv       # Baud Rate Generator
/constraints
  └── Nexys_TX_Controller.xdc
/docs
  └── lab4_meitar_shimoni.pdf
