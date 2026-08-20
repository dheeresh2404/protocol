`timescale 1ns/1ps

module spi_protocol_tb;

    reg        clk;
    reg        reset;
    reg        start;
    reg [7:0]  tx_data;
    reg        miso;

    wire       sclk;
    wire       mosi;
    wire       cs_n;
    wire [7:0] rx_data;
    wire       busy;
    wire       done;


    //================================================
    // DUT
    //================================================

    spi_protocol uut (
        .clk     (clk),
        .reset   (reset),
        .start   (start),
        .tx_data (tx_data),
        .miso    (miso),
        .sclk    (sclk),
        .mosi    (mosi),
        .cs_n    (cs_n),
        .rx_data (rx_data),
        .busy    (busy),
        .done    (done)
    );


    //================================================
    // 100 MHz CLK
    //================================================

    always #5 clk = ~clk;


    //================================================
    // SLAVE
    //
    // F3 = 11110011
    //================================================

    reg [7:0] slave_data;
    reg [2:0] slave_bit;


    initial begin

        slave_data = 8'hF3;
        slave_bit  = 3'd7;

        // First bit is available BEFORE
        // the master samples it.
        miso = 1'b1;

    end


    //================================================
    // Slave changes MISO on rising edge
    //
    // Master samples on falling edge
    //================================================

    always @(posedge clk) begin

        if (!reset && !cs_n) begin

            if (slave_bit != 3'd0) begin

                slave_bit = slave_bit - 3'd1;

                miso = slave_data[slave_bit];

                $display(
                    "Time=%0t  Slave sends bit %0d = %b",
                    $time,
                    slave_bit,
                    miso
                );

            end

        end

    end


    //================================================
    // Reset / Test
    //================================================

    initial begin

        clk     = 1'b0;
        reset   = 1'b1;
        start   = 1'b0;
        tx_data = 8'h00;

        #20;

        reset = 1'b0;

        // Reset slave bit counter
        slave_data = 8'hF3;
        slave_bit  = 3'd7;
        miso       = 1'b1;

        #20;

        //============================================
        // MASTER SENDS A5
        //============================================

        tx_data = 8'hA5;

        start = 1'b1;

        #10;

        start = 1'b0;


        //============================================
        // WAIT FOR DONE
        //============================================

        wait(done == 1'b1);

        #1;

        $display("");
        $display("================================");
        $display("      SPI TRANSFER COMPLETE");
        $display("================================");
        $display("TX DATA = %h", tx_data);
        $display("RX DATA = %h", rx_data);
        $display("DONE    = %b", done);
        $display("================================");
        $display("");


        #20;

        $finish;

    end


    //================================================
    // VCD
    //================================================

    initial begin

        $dumpfile("spi_protocol.vcd");
        $dumpvars(0, spi_protocol_tb);

    end

endmodule
