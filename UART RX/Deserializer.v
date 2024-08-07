module serializer (
input	wire		 	sampled_bit , serializer_en , clk , rst ,
input 	wire	[3:0]	bit_cnt ,

output	reg		[7:0]	P_Data

);

always @(posedge clk or negedge rst )
begin
	if(!rst)
	begin
		P_Data <= 8'b 1111_1111 ;
	end
	
	else if ( serializer_en )
	begin
		P_Data [bit_cnt-1] <= sampled_bit ;
	end

end


endmodule