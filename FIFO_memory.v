module fifo_memory #(parameter data_width = 8 , parameter depth = 10 ,parameter address_width = 4  ) (
input 	wire	[data_width-1 : 0   ]		wr_data ,
input 	wire	[address_width-1 : 0]		w_addre , r_addre ,
input 	wire								w_clk , r_clk ,
input 	wire								is_full , w_inc ,
//input 	wire								w_rst , r_rst , over write

output reg		[data_width-1 : 0   ]		r_data		

);

//declare 2D array as a memory
reg	[data_width-1 : 0] memory [0: depth -1 ] ;
//internal signal
wire	w_clken ;

//write enable condition
assign w_clken = (!is_full & w_inc );

//seq always for write data
always @(posedge w_clk)
begin
	if(w_clken)
	begin
		memory[w_addre] <= wr_data ;
	
	end

end

//seq always for read data
always @(posedge r_clk)
begin
		 r_data <= memory[r_addre] ;

end

endmodule