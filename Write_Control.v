module fifo_write_control #(parameter address_width = 4) (
input	wire								w_inc ,
input	wire	[address_width : 0   ]		r_ptr ,
input	wire								w_clk , w_rst,

output	wire								is_full ,
output	reg		[address_width - 1 : 0 ]	w_addre ,					
output	reg		[address_width : 0	 ]		w_ptr 

);

//full condition
assign is_full = ( r_ptr[address_width] != w_ptr[address_width] ) && ( r_ptr [ address_width-1:0 ] == w_ptr [ address_width-1:0 ] )  ;

//seq block for incr address and ptr
always @(posedge w_clk or negedge w_rst)
begin
	if(! w_rst)
	begin
		w_addre <= 'd0 ;
		w_ptr	<= 'd0 ;
	
	end
	
	else if( w_inc && !is_full )
	begin
		w_addre <= w_addre + 'd1 ;
		w_ptr	<= w_ptr   + 'd1 ;
	end

end


endmodule