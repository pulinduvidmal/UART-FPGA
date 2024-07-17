module transmitter(
	input wire [7:0] data_in,   // Input data as an 8-bit register/vector
	input wire wr_en,           // Enable wire to start transmission
	input wire clk_50m,         // Clock signal with frequency of 50 MHz
	input wire clken,           // Clock signal for the transmitter
	output reg Tx,              // Single 1-bit register variable to hold transmitting bit
	output wire Tx_busy         // Transmitter busy signal
);

initial begin
	 Tx = 1'b1;                 // Initialize Tx to 1 to begin transmission
end

// Define the 4 states using 00, 01, 10, 11 signals
parameter TX_STATE_IDLE  = 2'b00;
parameter TX_STATE_START = 2'b01;
parameter TX_STATE_DATA  = 2'b10;
parameter TX_STATE_STOP  = 2'b11;

reg [7:0] data = 8'h00;        // 8-bit register/vector to hold data, initially set to 00000000
reg [2:0] bit_pos = 3'h0;      // 3-bit register/vector for bit position, initially set to 000
reg [1:0] state = TX_STATE_IDLE; // 2-bit register/vector for state, initially set to 00

always @(posedge clk_50m) begin
	case (state)                 // Case statement to handle different states of the transmitter
	TX_STATE_IDLE: begin        // Conditions for idle or not-busy state
		if (~wr_en) begin       // Check if write enable signal is not asserted
			state <= TX_STATE_START; // Transition to start state
			data <= data_in;    // Assign input data vector to current data
			bit_pos <= 3'h0;    // Reset bit position to zero
		end
	end
	TX_STATE_START: begin       // Conditions for transmission start state
		if (clken) begin        // Check if clock enable signal is asserted
			Tx <= 1'b0;         // Set Tx to 0 indicating transmission has started
			state <= TX_STATE_DATA; // Transition to data transmission state
		end
	end
	TX_STATE_DATA: begin        // Conditions for data transmission state
		if (clken) begin        // Check if clock enable signal is asserted
			if (bit_pos == 3'h7) // Check if all bits have been transmitted
				state <= TX_STATE_STOP; // Transition to stop state if all bits transmitted
			else
				bit_pos <= bit_pos + 3'h1; // Increment bit position
			Tx <= data[bit_pos]; // Set Tx to the data value at the current bit position
		end
	end
	TX_STATE_STOP: begin        // Conditions for stop state
		if (clken) begin        // Check if clock enable signal is asserted
			Tx <= 1'b1;         // Set Tx to 1 indicating transmission has ended
			state <= TX_STATE_IDLE; // Transition to idle state
		end
	end
	default: begin              // Default condition
		Tx <= 1'b1;             // Start with Tx = 1
		state <= TX_STATE_IDLE; // Set state to idle
	end
	endcase
end

assign Tx_busy = (state != TX_STATE_IDLE); // Assign busy signal when transmitter is not idle
endmodule
