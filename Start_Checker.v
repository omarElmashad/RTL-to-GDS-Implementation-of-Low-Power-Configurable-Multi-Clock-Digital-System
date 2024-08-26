module start_checker (

input 	wire 	start_en , sampled_bit,
output  reg		glitch  

);


always @(*)
begin
	if(start_en && sampled_bit == 1'b1 )
	begin
		glitch = 1'b1;
	end
	
	else
	begin
		glitch = 1'b0;
	end
	
end

endmodule