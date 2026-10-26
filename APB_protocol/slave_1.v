module slave1(input clk,rst,
input psel1,
input [8:0]paddr,
input [7:0]pwdata,
input penable,
input pwrite,
output  pready1,
output  [7:0]prdata1);

reg [7:0]mem[0:255];
assign pready1=psel1 && penable;
assign prdata1 = (!pwrite && psel1 && penable) ?mem[paddr] : 8'h00;
always@(posedge clk or negedge rst)begin
	if(!rst)begin

	end
	else begin
		if(psel1 && penable&& pwrite)begin
				mem[paddr]<=pwdata;
		end
			
	end
end
endmodule
