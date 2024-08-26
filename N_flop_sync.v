module n_flop_sync #(parameter data_width = 4 , parameter N_flop = 2 )(
input	wire	[data_width-1:0]	 in_data ,
input	wire						 clk,rst ,

output	wire	[data_width-1:0]	 out_data

); 

//internal flops
reg [data_width-1 : 0] flops [ 0 : N_flop-1 ] ;
integer i ;
//
always @(posedge clk or negedge rst) 
begin
	if(!rst)
	begin
	for (i=0 ; i<= N_flop-1 ; i=i+1)
		begin
			flops[i] <= 'd0 ;
		end
	end
	
	else
	begin
		flops[0]<=in_data ;
		for (i=0 ; i< N_flop-1 ; i=i+1)
		begin
			flops[i+1] <= flops[i] ;
		end
	end


end
assign	out_data = flops[N_flop-1] ;

endmodule