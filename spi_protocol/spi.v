`timescale 1ns/1ps

module spi_protocol (
    input  wire       clk,
    input  wire       reset,
    input  wire       start,
    input  wire [7:0] tx_data,
    input  wire       miso,

    output wire       sclk,
    output reg        mosi,
    output reg        cs_n,
    output reg [7:0]  rx_data,
    output reg        busy,
    output reg        done
);

    localparam ST_IDLE     = 2'd0;
    localparam ST_TRANSFER = 2'd1;
    localparam ST_DONE     = 2'd2;

    reg [1:0] state;

    reg [7:0] tx_shift;
    reg [7:0] rx_shift;

    reg [2:0] bit_cnt;

    //================================================
    // SCLK is EXACTLY the same as CLK
    //================================================

    assign sclk = clk;


    //================================================
    // Start transaction and prepare MOSI
    //================================================

    always @(posedge clk or posedge reset) begin

        if (reset) begin

            state    <= ST_IDLE;

            tx_shift <= 8'h00;
            rx_shift <= 8'h00;

            bit_cnt  <= 3'd7;

            mosi     <= 1'b0;
            cs_n     <= 1'b1;

            rx_data  <= 8'h00;

            busy     <= 1'b0;
            done     <= 1'b0;

        end

        else begin

            done <= 1'b0;

            case (state)

                //====================================
                // IDLE
                //====================================

                ST_IDLE: begin

                    cs_n <= 1'b1;
                    busy <= 1'b0;
                    mosi <= 1'b0;

                    if (start) begin

                        tx_shift <= tx_data;
                        rx_shift <= 8'h00;

                        bit_cnt <= 3'd7;

                        // First MOSI bit
                        mosi <= tx_data[7];

                        cs_n <= 1'b0;
                        busy <= 1'b1;

                        state <= ST_TRANSFER;

                    end

                end


                //====================================
                // TRANSFER
                //====================================

                ST_TRANSFER: begin

                    cs_n <= 1'b0;
                    busy <= 1'b1;

                    // TX is shifted after each rising edge.
                    // RX is sampled on falling edge below.

                end


                //====================================
                // DONE
                //====================================

                ST_DONE: begin

                    cs_n <= 1'b1;
                    busy <= 1'b0;
                    mosi <= 1'b0;

                    state <= ST_IDLE;

                end


                default: begin

                    state <= ST_IDLE;

                    cs_n <= 1'b1;
                    busy <= 1'b0;
                    mosi <= 1'b0;

                end

            endcase

        end

    end


    //================================================
    // SPI RECEIVE
    //
    // SCLK = CLK
    //
    // Sample MISO on falling edge
    //================================================

    always @(negedge clk or posedge reset) begin

        if (reset) begin

            rx_shift <= 8'h00;
            rx_data  <= 8'h00;
            bit_cnt  <= 3'd7;

        end

        else if (state == ST_TRANSFER) begin

            // Sample MISO
            rx_shift <= {
                rx_shift[6:0],
                miso
            };


            if (bit_cnt == 3'd0) begin

                // Last bit
                rx_data <= {
                    rx_shift[6:0],
                    miso
                };

                cs_n <= 1'b1;
                busy <= 1'b0;
                done <= 1'b1;

                mosi <= 1'b0;

                state <= ST_DONE;

            end

            else begin

                // Next bit
                bit_cnt <= bit_cnt - 3'd1;

                tx_shift <= {
                    tx_shift[6:0],
                    1'b0
                };

                mosi <= tx_shift[6];

            end

        end

    end

endmodule
