# UART TX Controller — FPGA RTL Design
A complete **SystemVerilog implementation** of a UART Transmit Controller supporting configurable inter-byte delays, matrix-formatted multi-byte transmissions, and a fully integrated **seven-segment display subsystem**.  
Validated through testbenches and hardware implementation on the **Nexys A7-100T (Artix-7)** board.


### **Chip_Top_TX.sv — Port Summary**

![Top TX UART Controller](design/images/Top_TX_UART_Controller.png)



| Signal | Direction | Width | Description |
|--------|-----------|-------|-------------|
| `system_clock` | Input | 1 | 100 MHz FPGA system clock |
| `cpu_rst_n` | Input | 1 | Active-low async reset |
| `SW[7:0]` | Input | 8 | Data byte to transmit |
| `SW[9:8]` | Input | 2 | Delay configuration |
| `SW[14:13]` | Input | 2 | Number of bytes to send |
| `center_button` | Input | 1 | Long-press latch input |
| `TX` | Output | 1 | UART serial line |
| `LED[0]` | Output | 1 | Toggles on every transmitted byte |
| `anode_out[7:0]` | Output | 8 | Seven-segment anodes |
| `cathodes_out[6:0]` | Output | 7 | Seven-segment cathodes |
| `dot` | Output | 1 | Colon/dot indicator |

---

# System Architecture
![TX UART Controller Micro Architecture](design/images/micro-architecture.png)
## Major Components

| Module | Description |
|--------|-------------|
| **UART FSM** | Bit-level UART engine (start → data → stop → wait) |
| **Transmitter FSM** | Controls multi-byte sequencing & formatting |
| **Button Counter** | Long-press detection & debouncing |
| **Clock Dividers** | 3.2 kHz for UART & 500 Hz for seven-segment |
| **Seven-Segment Controller** | Displays values T0–T3 |
| **Chip Top** | Integrates all modules together |

---
