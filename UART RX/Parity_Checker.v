module parity_check (
input 	wire			parity_en , sampled_bit , par_typ , new_frame , clk , rst ,
input 	wire	[7:0]	p_data ,

output 	reg				parity_error	
);

reg 	actual_parity ;

always @(*)
begin
	if(par_typ)
	begin
		actual_parity = ^p_data;
	end
	else
	begin
		actual_parity = !(^p_data);
	end
end

always @(posedge clk or negedge rst)
begin
	if(!rst)
	begin
	parity_error <= 1'b0;
	end
	
	else if(parity_en && sampled_bit != actual_parity )
	begin
	parity_error <= 1'b1;
	end
	
	else if(new_frame )
	begin
	parity_error <= 1'b0;
	end

end



endmodule