`timescale 1ns / 1ps

module traffic_light (
    input wire clk,            // Clock input
    input wire rst_n,          // Active low reset
    input wire [5:0] red_time, // Time in seconds for red light
    input wire [5:6] green_time, // Time in seconds for green light
    output reg red,            // Red light output
    output reg yellow,         // Yellow light output
    output reg green,          // Green light output
    output reg [5:0] counter   // Counter output for testbench
);

reg [1:0] state;             // State of the traffic light: 00 = Red, 01 = Green, 10 = Yellow

// States
localparam RED = 2'b00;
localparam GREEN = 2'b01;
localparam RED_TO_YELLOW = 2'b10;
localparam GREEN_TO_YELLOW = 2'b11;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        // Reset state and outputs
        counter <= 6'd0;
        state <= RED;
        red <= 1;
        yellow <= 0;
        green <= 0;
    end else begin
        case (state)
            RED: begin
                if (counter < red_time - 6'd5) begin
                    counter <= counter + 1;
                end else begin
                    counter <= 6'd0;
                    state <= RED_TO_YELLOW;
                end
                // Red light is on
                red <= 1;
                // Yellow light is off
                yellow <= 0;
                // Green light is off
                green <= 0;
            end
            RED_TO_YELLOW: begin
                if (counter < 6'd5) begin
                    counter <= counter + 1;
                end else begin
                    counter <= 6'd0;
                    state <= GREEN;
                end
                // Red light is on
                red <= 0;
                // Yellow light is on
                yellow <= 1;
                // Green light is off
                green <= 0;
            end
            GREEN: begin
                if (counter < green_time - 6'd5) begin
                    counter <= counter + 1;
                end else begin
                    counter <= 6'd0;
                    state <= GREEN_TO_YELLOW;
                end
                // Red light is off
                red <= 0;
                // Yellow light is off
                yellow <= 0;
                // Green light is on
                green <= 1;
            end
            GREEN_TO_YELLOW: begin
                if (counter < 6'd5) begin
                    counter <= counter + 1;
                end else begin
                    counter <= 6'd0;
                    state <= RED;
                end
                // Red light is off
                red <= 0;
                // Yellow light is on
                yellow <= 1;
                // Green light is off
                green <= 0;
            end
        endcase
    end
end

endmodule 


module testbench;
    reg clk;               // Clock input for testbench
    reg rst_n;             // Reset input for testbench
    reg [5:0] red_time;    // Red light duration for testbench
    reg [5:0] green_time;  // Green light duration for testbench
    wire red;              // Red light output for testbench
    wire yellow;           // Yellow light output for testbench
    wire green;            // Green light output for testbench
    wire [5:0] counter;    // Counter output for testbench

    // Instantiate the traffic_light module
    traffic_light uut (
        .clk(clk),
        .rst_n(rst_n),
        .red_time(red_time),
        .green_time(green_time),
        .red(red),
        .yellow(yellow),
        .green(green),
        .counter(counter)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Toggle clock every 5 time units
    end

    // Test sequence
    initial begin
        // Initialize inputs
        rst_n = 0;             // Set reset to active (low)
        red_time = 6'd20;      // Set red light duration to 20 seconds
        green_time = 6'd15;    // Set green light duration to 15 seconds

        // Apply reset
        #10 rst_n = 1;         // After 10 time units, deactivate reset (set high)

        // Run for a certain amount of time to observe behavior
        #1000 $stop;           // Stop simulation after 1000 time units
    end

    // Monitor the outputs
    initial begin
        $monitor("At time %t: red = %b, yellow = %b, green = %b, counter = %d", $time, red, yellow, green, counter);
        // Display output values at different times during simulation
    end
endmodule
