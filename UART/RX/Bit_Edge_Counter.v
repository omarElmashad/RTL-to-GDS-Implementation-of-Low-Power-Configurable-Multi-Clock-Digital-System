module bit_edge_counter ( 

input 	wire			 edge_en  , clk , rst ,end_frame ,
input	wire	[5:0]	 prescale_edge  ,

output 	reg		[5:0] 	 edge_cnt ,
output 	reg		[3:0]	 bit_cnt

);

reg inc_bit ;

always @(posedge clk or negedge rst)
begin
	if(! rst)
	begin
		edge_cnt <= 'd0;
		bit_cnt  <= 'd0;
	
	end

	else if (end_frame)
	begin
		edge_cnt <= 'd0;
		bit_cnt  <= 'd0;
	
	end
	
	else if ( edge_en && edge_cnt != prescale_edge -2 && edge_cnt != prescale_edge -1 )
	begin
		edge_cnt <= edge_cnt + 1;
	end
	
	else if ( edge_en && edge_cnt != prescale_edge -1 )
	begin
		edge_cnt <= edge_cnt + 1 ;
		bit_cnt  <= bit_cnt  + 1 ;
	end
	
	//case enable is on and count all edge for one bit 
	else if (edge_en )
	begin
		edge_cnt <= 'd0;
		
	end
	// case enable is off 
	else 
	begin
		edge_cnt <= 'd0;
		bit_cnt  <= 'd0;
	end

end
	




endmodule