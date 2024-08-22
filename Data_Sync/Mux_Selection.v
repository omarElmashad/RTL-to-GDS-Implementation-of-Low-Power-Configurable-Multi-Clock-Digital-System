module mux_sele #(parameter data_width = 8 )(
input	wire	[data_width-1 : 0]		in_unsync_data ,
input	wire							in_enable ,
input	wire							clk , rst,

output	reg		[data_width-1 : 0]		out_sync_data ,
output	reg								out_enable 

);

//define parmeter
wire 	[data_width-1 : 0]	mux_out ;

assign	mux_out = (in_enable ? in_unsync_data : out_sync_data ) ;

always @(posedge clk or negedge rst)
begin
	if(!rst)
	begin
		out_sync_data <= 'd0 ;
		out_enable 	  <= 'd0;	
	end
	
	else
	begin
		out_sync_data <= mux_out ;
		out_enable 	  <= in_enable;	

	end


end

endmodule