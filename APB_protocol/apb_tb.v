module tb;
reg clk;
reg rst;
reg transfer;
reg write;
reg [8:0]addr;
reg [7:0]wdata;
wire [7:0]rdata;

top_module uut(.clk(clk),
	.rst(rst),
	.transfer(transfer),
	.write(write),
	.addr(addr),
	.wdata(wdata),
	.rdata(rdata));

always #5 clk=~clk;

initial begin
	clk=1;
	rst=0;
	transfer=0;
	write=0;
	addr=0;
	wdata=0;

	#10;
	rst=1;
	@(posedge clk) ;
	transfer<=1;
	write<=1;
	addr<=9'h010;
	wdata<=8'h55;

	 
	@(posedge clk);
	transfer<=0;
	wait(uut.pready);

	@(posedge clk);
	write <= 1'b1;
        transfer <= 1'b1;
        addr <= 9'h1A5;
        wdata<= 8'h45;
	
	@(posedge clk);
	transfer<=0;
	wait(uut.pready);

	@(posedge clk);
	transfer<=1;
	write<=0;
	addr <= 9'h010;
        
	@(posedge clk);
	transfer<=0;
	wait(uut.pready);
	#50;
	$finish;
end

initial begin
	$monitor("time=%0t  transfer=%b  write=%b  addr=%h  wdata=%h prdata=%h rdata=%h psel=%b penable=%b pready=%b",$time,transfer,write,addr,wdata,uut.prdata,rdata,uut.psel,uut.penable,uut.pready);
	$dumpfile("APB.vcd");
	$dumpvars;
end

endmodule
