module receiver (
	input wire Rx,                  // Input wire for received data
	output reg ready,              // Output register indicating readiness for data reception
	input wire ready_clr,          // Input wire to clear the ready signal
	input wire clk_50m,            // Clock signal with frequency of 50 MHz
	input wire clken,              // Clock signal for the receiver
	output reg [7:0] data          // Output register for received data (8 bits)
);

initial begin
	ready = 1'b0;                  // Initialize ready to 0
	data = 8'b0;                   // Initialize data to 00000000
end

// Define the 3 states using 00, 01, 10 signals
parameter RX_STATE_START = 2'b00;
parameter RX_STATE_DATA = 2'b01;
parameter RX_STATE_STOP = 2'b10;

reg [1:0] state = RX_STATE_START;  // 2-bit register/vector for state, initially set to 00
reg [3:0] sample = 0;               // 4-bit register/vector for sample count
reg [3:0] bit_pos = 0;              // 4-bit register/vector for bit position, initially set to 000
reg [7:0] scratch = 8'b0;           // 8-bit register/vector to hold received data, initially set to 00000000

always @(posedge clk_50m) begin
	if (!ready_clr)                  // Check if ready_clr signal is asserted
		ready <= 1'b0;               // Reset ready to 0 (active low)

	if (clken) begin                 // Check if clock enable signal is asserted
		case (state)                 // Case statement to handle different states of the receiver
		RX_STATE_START: begin       // Conditions for starting the receiver
			if (!Rx || sample != 0) // Start counting from the first low sample
				sample <= sample + 4'b1; // Increment sample count
			if (sample == 15) begin // Once a full bit has been sampled
				state <= RX_STATE_DATA; // Transition to data collection state
				bit_pos <= 0;         // Reset bit position
				sample <= 0;          // Reset sample count
				scratch <= 0;         // Reset scratch register
			end
		end
		RX_STATE_DATA: begin        // Conditions for data collection state
			sample <= sample + 4'b1; // Increment sample count
			if (sample == 4'h8) begin // Sample each bit of data
				scratch[bit_pos[2:0]] <= Rx; // Store received bit in scratch register
				bit_pos <= bit_pos + 4'b1;  // Increment bit position
			end
			if (bit_pos == 8 && sample == 15) // Check if all bits have been received
				state <= RX_STATE_STOP;      // Transition to stop state
		end
		RX_STATE_STOP: begin        // Conditions for stop state
			// If we're at least halfway into the stop bit or Rx is low, transition to start state
			if (sample == 15 || (sample >= 8 && !Rx)) begin
				state <= RX_STATE_START; // Transition to start state
				data <= scratch;          // Store received data
				ready <= 1'b1;            // Set ready to 1 (data reception complete)
				sample <= 0;              // Reset sample count
			end 
			else begin
				sample <= sample + 4'b1; // Increment sample count
			end
		end
		default: begin               // Default condition
			state <= RX_STATE_START; // Start with state assigned to START
		end
		endcase
	end
end

endmodule
