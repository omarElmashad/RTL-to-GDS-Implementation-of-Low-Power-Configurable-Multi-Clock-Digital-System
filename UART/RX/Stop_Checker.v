module stop_check (
input 	wire			stop_en , sampled_bit, new_frame  , clk , rst ,

output 	reg				stop_error	

);


always @(posedge clk or negedge rst)
begin
	if(!rst)
	begin
		stop_error <= 1'b0;
	end
	
	else if (stop_en && sampled_bit != 1'b1)
	begin
		stop_error <= 1'b1;
	end
	
	else if (new_frame)
	begin
		stop_error <= 1'b0;
	end
	
end


endmodule