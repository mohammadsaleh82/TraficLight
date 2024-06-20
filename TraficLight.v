`timescale 1ns / 1ps

module traffic_light (
    input wire clk,          // Clock input
    input wire rst_n,        // Active low reset
    input wire [5:0] red_time, // Time in seconds for red light
    input wire [5:0] green_time, // Time in seconds for green light
    output reg red,          // Red light output
    output reg yellow,       // Yellow light output
    output reg green         // Green light output
);

reg [5:0] counter;           // 6-bit counter to count seconds
reg [1:0] state;             // State of the traffic light: 00 = Red, 01 = Green, 10 = Yellow

// States
localparam RED = 2'b00;
localparam GREEN = 2'b01;
localparam YELLOW = 2'b10;

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
                if (counter < red_time) begin
                    counter <= counter + 1;
                end else begin
                    counter <= 6'd0;
                    state <= GREEN;
                end
                // Red light is on
                red <= 1;
                // Yellow light is on in the last 5 seconds of the red period
                yellow <= (counter >= red_time - 6'd5);
                // Green light is off
                green <= 0;
            end
            GREEN: begin
                if (counter < green_time) begin
                    counter <= counter + 1;
                end else begin
                    counter <= 6'd0;
                    state <= YELLOW;
                end
                // Red light is off
                red <= 0;
                // Yellow light is off
                yellow <= 0;
                // Green light is on
                green <= 1;
            end
            YELLOW: begin
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
    reg clk;             // ورودی کلاک برای تست بنچ
    reg rst_n;           // ورودی ریست برای تست بنچ
    reg [5:0] red_time;  // زمان قرمز بودن چراغ برای تست بنچ
    reg [5:0] green_time;  // زمان سبز بودن چراغ برای تست بنچ
    wire red;            // خروجی چراغ قرمز برای تست بنچ
    wire yellow;         // خروجی چراغ زرد برای تست بنچ
    wire green;          // خروجی چراغ سبز برای تست بنچ

    // Instantiate the traffic_light module
    traffic_light uut (
        .clk(clk),
        .rst_n(rst_n),
        .red_time(red_time),
        .green_time(green_time),
        .red(red),
        .yellow(yellow),
        .green(green)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Toggle clock every 5 time units
    end

    // Test sequence
    initial begin
        // Initialize inputs
        rst_n = 0;           // تنظیم ریست به حالت فعال (پایین)
        red_time = 6'd20;    // تنظیم زمان قرمز به 20 ثانیه
        green_time = 6'd15;  // تنظیم زمان سبز به 15 ثانیه

        // Apply reset
        #10 rst_n = 1;       // بعد از 10 واحد زمانی، ریست غیر فعال می‌شود (بالا می‌رود)

        // Run for a certain amount of time to observe behavior
        #1000 $stop;          // توقف شبیه‌سازی بعد از 1000 واحد زمانی
    end

    // Monitor the outputs
    initial begin
        $monitor("At time %t: red = %b, yellow = %b, green = %b", $time, red, yellow, green);
        // نمایش مقادیر خروجی‌ها در زمان‌های مختلف شبیه‌سازی
    end
endmodule
