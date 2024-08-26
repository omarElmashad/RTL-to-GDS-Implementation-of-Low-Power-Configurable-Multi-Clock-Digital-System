module fifo_top #(parameter data_width = 8 , parameter depth = 8 ,parameter address_width = 4)(
input 	wire	[data_width-1 : 0   ]		wr_data ,
input	wire								r_clk , w_clk ,
input	wire								r_rst , w_rst ,
input	wire								r_inc , w_inc ,

output 	wire	[data_width-1 : 0   ]		rd_data ,
output	wire								full , empty 


);

//internal signals
wire	[address_width-1 : 0]		w_addre , r_addre ;
wire	[address_width : 0   ]		r_ptr ,	w_ptr ;
wire	[address_width : 0   ]		in_r_ptr_gray ,		in_w_ptr_gray ;
wire	[address_width : 0   ]		out_r_ptr_gray ,	out_w_ptr_gray , w_ptr_in_to_readblock , r_ptr_in_to_writeblock;

//instantiations

fifo_memory #( .data_width(data_width)  ,  .depth(depth)   ,  .address_width(address_width)  )	memory_block (
.wr_data	(wr_data) 	,
.w_addre	(w_addre) 	,
.r_addre	(r_addre) 	,
.w_clk  	(w_clk) 	,
.r_clk  	(r_clk) 	,
.is_full	(full) 		,
.w_inc  	(w_inc) 	,
.r_data 	(rd_data)   

);

fifo_write_control #( .address_width(address_width)   ) fifo_write_block (
.w_inc  	(w_inc)		 ,
.r_ptr		(r_ptr_in_to_writeblock)		 ,
.w_clk  	(w_clk) 	 ,
.w_rst		(w_rst)		 ,
.is_full	(full)		 ,
.w_addre	(w_addre) 	 ,
.w_ptr		(w_ptr)
);

fifo_read_control #( .address_width(address_width)   ) fifo_read_block (
.r_inc  	(r_inc)		 ,
.w_ptr		(w_ptr_in_to_readblock)		 ,
.r_clk  	(r_clk) 	 ,
.r_rst		(r_rst)		 ,
.is_empty	(empty)		 ,
.r_addre	(r_addre) 	 ,
.r_ptr		(r_ptr)		 

);

//binary write pointer to gray 
B_to_G #( .data_width(address_width + 1) ) wptr_B_to_G (
.in_data_binary		(w_ptr)		 ,
.out_data_gray 		(in_w_ptr_gray)
);

//gray write pointer to double flop bus sync
n_flop_sync	#( .data_width(address_width + 1)  , .N_flop(2)  ) sync_w2r (
.in_data	(in_w_ptr_gray) 		,
.clk		(r_clk)				,
.rst		(r_rst) 			,
.out_data	(out_w_ptr_gray)
);

//output from double flop bus sync to binary write pointer
G_to_B #( .data_width(address_width + 1) ) wptr_G_to_B (
.in_data_gray(out_w_ptr_gray) 	,
.out_data_binary(w_ptr_in_to_readblock)

);




//binary read pointer from read control block to gray 
B_to_G #( .data_width(address_width + 1) ) rptr_B_to_G (
.in_data_binary		(r_ptr)		 ,
.out_data_gray 		(in_r_ptr_gray)
);

//gray read pointer to double flop bus sync
n_flop_sync	#( .data_width(address_width + 1)  , .N_flop(2)  ) sync_r2w (
.in_data	(in_r_ptr_gray) 		,
.clk		(w_clk)				,
.rst		(w_rst) 			,
.out_data	(out_r_ptr_gray)
);

//output from double flop bus sync to binary read pointer
G_to_B #( .data_width(address_width + 1) ) rptr_G_to_B (
.in_data_gray(out_r_ptr_gray) 	,
.out_data_binary(r_ptr_in_to_writeblock)

);


endmodule