// FILE : SEVEN SEGMENT DECODER 
// Author : MEITAR SHIMONI
// DESCRIPTION : DECODING COMMON ANODE

module decoder_bin2hex(
    input [3:0] bin_in_hex,
    output reg [6:0] decoded
);


always @(*) begin
    case (bin_in_hex)
        4'b0000: decoded = ~(7'b111_1110); // 0
        4'b0001: decoded = ~(7'b011_0000); // 1
        4'b0010: decoded = ~(7'b110_1101); // 2
        4'b0011: decoded = ~(7'b111_1001); // 3
        4'b0100: decoded = ~(7'b011_0011); // 4
        4'b0101: decoded = ~(7'b101_1011); // 5
        4'b0110: decoded = ~(7'b101_1111); // 6
        4'b0111: decoded = ~(7'b111_0000); // 7
        4'b1000: decoded = ~(7'b111_1111); // 8
        4'b1001: decoded = ~(7'b111_1011); // 9
        4'b1010: decoded = ~(7'b111_0111); // A
        4'b1011: decoded = ~(7'b001_1111); // B
        4'b1100: decoded = ~(7'b100_1110); // C
        4'b1101: decoded = ~(7'b011_1101); // D
        4'b1110: decoded = ~(7'b100_1111); // E
        4'b1111: decoded = ~(7'b100_0111); // F
        default: decoded = ~(7'b111_1110); // Default case
    endcase
end 

endmodule
