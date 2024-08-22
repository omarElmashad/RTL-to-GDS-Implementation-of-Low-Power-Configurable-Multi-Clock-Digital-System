module G_to_B #(parameter data_width = 4) (
input 	wire	[data_width-1 : 0] 		in_data_gray ,

output	reg		[data_width-1 : 0]		out_data_binary  
);

integer i ;

always @(*)
begin
	out_data_binary[data_width-1] = in_data_gray[data_width-1] ;
	
	for(i=data_width-2 ; i >=0 ; i=i-1 )
	begin
		out_data_binary[i] = out_data_binary[i+1] ^ in_data_gray[i] ;
	end


end



endmodule