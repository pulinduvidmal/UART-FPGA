module uart_data_transmitter (
    input wire clk_50m,          // Input clock signal with frequency of 50 MHz
    output wire Tx,               // Output wire for UART transmitter signal
    output wire Tx_busy,          // Output wire indicating UART transmitter status
    input wire Rx,                // Input wire for UART receiver signal
    output wire ready,            // Output wire indicating readiness for data transmission
    input wire ready_clr,         // Input wire to clear ready signal
    output wire [7:0] data_out,   // Output wire for transmitted data
    output [7:0] LEDR,            // Output wire for controlling LEDR
    output wire Tx2               // Output wire for secondary UART transmitter signal
);

    reg [7:0] data_to_send = 8'b00000000;   // Register to store data to be transmitted
    reg [31:0] counter = 0;                  // Register to count clock cycles for timing control

    // Declare internal wires for UART signals
    wire uart_Tx;        // Internal wire for UART transmitter signal
    wire uart_Tx_busy;   // Internal wire indicating UART transmitter status
    wire uart_ready;     // Internal wire indicating readiness for data transmission

    // Instantiate existing uart module
    uart uart_inst (
        .data_in(data_to_send),    // Connect data_to_send to data_in input of UART module
        .wr_en(1'b0),              // Write enable signal set to 0
        .clear(1'b0),              // Clear signal set to 0
        .clk_50m(clk_50m),        // Connect clk_50m input to clock signal of UART module
        .Tx(uart_Tx),              // Connect uart_Tx internal wire to Tx output of UART module
        .Tx_busy(uart_Tx_busy),    // Connect uart_Tx_busy internal wire to Tx_busy output of UART module
        .Rx(Rx),                   // Connect Rx input to Rx input of UART module
        .ready(uart_ready),        // Connect uart_ready internal wire to ready output of UART module
        .ready_clr(ready_clr),     // Connect ready_clr input to ready_clr input of UART module
        .data_out(data_out),       // Connect data_out output to internal register
        .LEDR(LEDR),               // Connect LEDR output to LEDR output of UART module
        .Tx2(Tx2)                  // Connect Tx2 output to Tx2 output of UART module
    );

    // Connect UART outputs to internal signals
    assign Tx = uart_Tx;          // Connect uart_Tx internal wire to Tx output of module
    assign Tx_busy = uart_Tx_busy; // Connect uart_Tx_busy internal wire to Tx_busy output of module
    assign ready = uart_ready;     // Connect uart_ready internal wire to ready output of module

    // Counter to control data transmission delay
    always @(posedge clk_50m) begin  // Execute on positive edge of clk_50m
        if (counter < 50000000) begin  // If counter is less than 50 million
            counter <= counter + 1;      // Increment counter
        end else begin                  // Else
            counter <= 0;                // Reset counter
            if (data_to_send == 8'hFF) begin  // If data_to_send is equal to 255
                data_to_send <= 8'b00000000;  // Reset data_to_send to 0
            end else begin                // Else
                data_to_send <= data_to_send + 1;  // Increment data_to_send
            end
        end
    end

endmodule
