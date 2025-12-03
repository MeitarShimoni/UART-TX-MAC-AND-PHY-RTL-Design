// FILE : Top Transmitter
// Author : MEITAR SHIMONI
// DESCRIPTION : Top Level Module that unit MAC & PHY
module top_transmitter(
    input system_clock,
    input clock_enable,
    input rst_n,
    input start,
    
    input [7:0] data_to_send,
    input [14:0] num_bytes_to_send,
    input [1:0] delay,
    
    output logic [16:0] data_counter, // also updated
    output logic[7:0] line_counter,
    output tx,
    output busy
    );

    wire busy_uart;
    wire start_uart;
    wire [7:0] urt_tx_data;

    // instance uart PHY
    uart_tx_phy_fsm UART_TX_PHY_FSM(.system_clock(system_clock), .clock_enable(clock_enable), .rst_n(rst_n), 
    .center_push(start_uart), .data_in(urt_tx_data), .tx_busy(busy_uart), .delay(delay), .Tx(tx) );

    // instance MAC FSM Transmitter
    mac_tx_fsm mac_fsm(.system_clock(system_clock), .clock_enable(clock_enable),.rst_n(rst_n),
        .start(start),.data_in(data_to_send),.num_bytes(num_bytes_to_send),
        .busy_uart(busy_uart),.start_uart(start_uart), .urt_tx_data(urt_tx_data),
        .busy(busy), .data_counter(data_counter), .line_counter(line_counter)

    );

endmodule
