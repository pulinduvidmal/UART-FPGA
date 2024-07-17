module uart(
	input wire [7:0] data_in,       // Input data to be transmitted
	input wire wr_en,               // Write enable signal
	input wire clear,               // Clear signal
	input wire clk_50m,             // Clock signal with frequency of 50 MHz
	output wire Tx,                 // Output wire for UART transmitter signal
	output wire Tx_busy,            // Output wire indicating UART transmitter status
	input wire Rx,                  // Input wire for UART receiver signal
	output wire ready,              // Output wire indicating readiness for data transmission
	input wire ready_clr,           // Input wire to clear ready signal
	output wire [7:0] data_out,     // Output wire for received data
	output [7:0] LEDR,              // Output wire for controlling LEDs
	output wire Tx2                // Output wire for secondary UART transmitter signal
);

//reg[7:0]data_in = 8'b01100010;   // Commented out, as this line is currently unused

assign LEDR = data_out;            // Connect data_out to LEDR output
assign Tx2 = Tx;                   // Connect Tx to Tx2 output

wire Txclk_en, Rxclk_en;           // Declare internal wires for clock enable signals

baudrate uart_baud(                 // Instantiate baud rate module
	.clk_50m(clk_50m),             // Connect clk_50m input to baud rate module
	.Rxclk_en(Rxclk_en),           // Connect Rxclk_en output to internal wire
	.Txclk_en(Txclk_en)            // Connect Txclk_en output to internal wire
);

transmitter uart_Tx(                // Instantiate UART transmitter module
	.data_in(data_in),             // Connect data_in input to transmitter module
	.wr_en(wr_en),                 // Connect wr_en input to transmitter module
	.clk_50m(clk_50m),             // Connect clk_50m input to transmitter module
	.clken(Txclk_en),              // Connect Txclk_en internal wire to transmitter module
	.Tx(Tx),                        // Connect Tx output to transmitter module
	.Tx_busy(Tx_busy)              // Connect Tx_busy output to transmitter module
);

receiver uart_Rx(                   // Instantiate UART receiver module
	.Rx(Rx),                        // Connect Rx input to receiver module
	.ready(ready),                  // Connect ready output to receiver module
	.ready_clr(ready_clr),         // Connect ready_clr input to receiver module
	.clk_50m(clk_50m),              // Connect clk_50m input to receiver module
	.clken(Rxclk_en),               // Connect Rxclk_en internal wire to receiver module
	.data(data_out)                 // Connect data_out output to receiver module
);

endmodule
