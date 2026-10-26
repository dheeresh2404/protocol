module slave2(input clk,rst,
input psel2,
input [8:0]paddr,
input [7:0]pwdata,
input penable,
input pwrite,
output  pready2,
output  [7:0]prdata2);

reg [7:0]mem[0:255];
assign pready2=psel2 && penable;
assign prdata2= (!pwrite && psel2 && penable) ?mem[paddr] : 8'h00;
always@(posedge clk or negedge rst)begin
        if(!rst)begin

        end
        else begin
                if(psel2 && penable&& pwrite)begin
                                mem[paddr]<=pwdata;
                end

        end
end
endmodule
