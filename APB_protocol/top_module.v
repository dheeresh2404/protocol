module top_module(input clk,rst,
input transfer,
input write,
input [8:0]addr,
input [7:0]wdata,
output [7:0]rdata);

wire psel;
wire penable;
wire pwrite;
wire [8:0]paddr;
wire [7:0]pwdata;
wire pready;
wire [7:0]prdata;

wire psel1,psel2;
wire pready1,pready2;
wire [7:0]prdata1,prdata2;


assign psel1=psel && (paddr[8]==1'b0);
assign psel2=psel && (paddr[8]==1'b1);
assign pready=psel1?pready1:(psel2?pready2:1'b0);
assign prdata=psel1?prdata1:(psel2?prdata2:8'b0);
master mst(.clk(clk),
	.rst(rst),
	.pready(pready),
	.transfer(transfer),
	.addr(addr),
	.wdata(wdata),
	.write(write),
	.psel(psel),
	.paddr(paddr),
	.pwdata(pwdata),
	.prdata(prdata),
	.pwrite(pwrite),
	.rdata(rdata),
	.penable(penable));

slave1 s1(.clk(clk),
	.rst(rst),
	.psel1(psel1),
	.paddr(paddr),
	.pwdata(pwdata),
	.penable(penable),
	.pwrite(pwrite),
	.pready1(pready1),
	.prdata1(prdata1));

slave2 s2(.clk(clk),
        .rst(rst),
        .psel2(psel2),
        .paddr(paddr),
        .pwdata(pwdata),
        .penable(penable),
        .pwrite(pwrite),
        .pready2(pready2),
        .prdata2(prdata2));

endmodule
