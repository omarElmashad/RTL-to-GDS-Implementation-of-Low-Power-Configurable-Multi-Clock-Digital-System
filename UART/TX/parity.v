
module parity_bit (
input 	wire	[7:0] 	p_data_par ,
input 	wire 			valid_par,free_par,parity_type,rst,clk,
//input 	wire			clk_par,reset_par,

output  wire 			par_pit 

);

reg [7:0] 	store_data;

always @(posedge clk or negedge rst)
	begin
		if(!rst)
			begin
				store_data <= 0  ;
			end
		else if(valid_par && free_par)
			begin
				store_data = p_data_par ;
			end
		
	end
	
assign par_pit = ( parity_type ?  (^store_data) : (~^store_data) ) ;


endmodule