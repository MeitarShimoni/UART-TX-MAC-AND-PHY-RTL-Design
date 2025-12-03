// FILE : ANODE DECODER
// Author : MEITAR SHIMONI
// DESCRIPTION : DECODING ANODE LOCATION INTO MUX SELECT

module anode_decoder(
    input [7:0] anode_in,
    output reg [2:0] anode_sel
);


always @(*) begin
    case (anode_in)
        ~(8'b0000_0001): anode_sel = 7;
        ~(8'b0000_0010): anode_sel = 6;
        ~(8'b0000_0100): anode_sel = 5; 
        ~(8'b0000_1000): anode_sel = 4;
        ~(8'b0001_0000): anode_sel = 3;
        ~(8'b0010_0000): anode_sel = 2;
        ~(8'b0100_0000): anode_sel = 1;
        ~(8'b1000_0000): anode_sel = 0; 
        default: anode_sel = 3'b100; // Default case
    endcase
end

endmodule
