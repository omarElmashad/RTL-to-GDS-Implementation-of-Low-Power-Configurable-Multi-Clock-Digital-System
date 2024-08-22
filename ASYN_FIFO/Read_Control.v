module fifo_read_control #(parameter address_width = 4) (
input	wire								r_inc ,
input	wire	[address_width : 0   ]		w_ptr ,
input	wire								r_clk , r_rst,

output	wire								is_empty ,
output	reg		[address_width - 1 : 0 ]	r_addre ,					
output	reg		[address_width : 0	 ]		r_ptr 

);

//empty condition
assign is_empty = (w_ptr == r_ptr ) ;

//seq block for incr address and ptr
always @(posedge r_clk or negedge r_rst) 
begin
	if(!r_rst)
	begin
		r_addre <= 'd0 ;
		r_ptr 	<= 'd0 ;
	end
	
	else if( r_inc && !is_empty )
	begin
		r_addre <= r_addre + 'd1 ;
		r_ptr	<= r_ptr   + 'd1 ;	
	end

end

endmodule