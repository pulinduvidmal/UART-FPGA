// This is a testbench module for UART transmitter and receiver.
// The Tx and Rx pins are connected together to create a serial loopback.
// It checks if the received data matches the transmitted data by sending incrementing data bytes.

module uart_TB()
// Declare variables and wires for testbench
reg [7:0] data = 0;         // 8-bit register to hold data
reg clk = 0;                // Clock signal
reg enable = 0;             // Enable signal for transmitter
wire Tx_busy;               // Output wire indicating transmitter busy status
wire rdy;                   // Output wire indicating readiness for data transmission
wire [7:0] Rx_data;         // Output wire for received data
wire loopback;              // Wire for serial loopback
reg ready_clr = 0;          // Register to clear the ready signal

// Instantiate UART module for testing
uart test_uart(
	.data_in(data),         // Connect data_in to data register
	.wr_en(enable),         // Connect wr_en to enable signal
	.clk_50m(clk),          // Connect clk_50m to clock signal
	.Tx(loopback),          // Connect Tx to loopback wire
	.Tx_busy(Tx_busy),      // Connect Tx_busy to Tx_busy wire
	.Rx(loopback),          // Connect Rx to loopback wire
	.ready(rdy),            // Connect ready to rdy wire
	.ready_clr(ready_clr), // Connect ready_clr to ready_clr register
	.data_out(Rx_data)     // Connect data_out to Rx_data wire
);

// Initial block for simulation setup
initial begin
	$dumpfile("uart.vcd");     // Dump waveform into uart.vcd file
	$dumpvars(0, uart_TB);     // Dump all variables at time 0
	enable <= 1'b1;             // Set enable signal to 1
	#2 enable <= 1'b0;          // Disable enable signal after 2 time units
end

// Clock generation
always begin
	#1 clk = ~clk;              // Toggle clock signal every time unit
end

// Data transmission and reception verification
always @(posedge rdy) begin
	#2 ready_clr <= 1;          // Set ready_clr signal to 1
	#2 ready_clr <= 0;          // Reset ready_clr signal to 0
	if (Rx_data != data) begin // Check if received data matches transmitted data
		$display("FAIL: rx data %x does not match tx %x", Rx_data, data); // Display failure message if data mismatch
		$finish;                 // Finish simulation
	end 
	else begin
		if (Rx_data == 8'h2) begin // Check if received data is 11111111
			$display("SUCCESS: all bytes verified"); // Display success message if all bytes are verified
			$finish;                                 // Finish simulation
		end
		data <= data + 1'b1;      // Increment data for next transmission
		enable <= 1'b1;           // Enable transmitter
		#2 enable <= 1'b0;        // Disable transmitter after 2 time units
	end
end

endmodule
