module system_top #(parameter data_width = 8 , parameter addre_width = 4 , parameter alu_func_width = 4 , parameter num_sync_stage = 2 
					, parameter rg_addres_width	= 4 ,	parameter reg_file_depth = 16	,	
						parameter FIFO_DEPTH	= 8 ,	parameter FIFO_addres_width = 3					) 
						
						(

input	wire	rx_in ,
input	wire	ref_clk , uart_clk , rst ,

output	wire	tx_out ,
output 	wire	parity_error , stop_error

);




//internal signals
wire	 [data_width -1 :0 ]	fifo_read , RG2, RX_output , data_sync_out ;
wire							fifo_empty,  in_puls_gen ;
wire							rx_data_valid , rst_domain_2_sync , rst_domain_1_sync , frame_enable ;

//signal interface between sys_ctrl and REG_file
wire								wr_en , rd_en , rg_rd_valid ; 
wire	[rg_addres_width-1 : 0]		addres ;
wire	[data_width -1 :0 ]			rd_data, wr_data ;

//signal interface between sys_ctrl and ALU
wire								alu_en , alu_out_valid  ; 
wire	[alu_func_width-1 : 0]		alu_func ;
wire	[2*data_width -1 :0 ]			alu_output ;

//signal interface between sys_ctrl and clk_gating and clk_div
wire	clk_gating_en , clk_div_en;

//signal interface between sys_ctrl and ASYN_FIFO
wire	[data_width -1 :0 ]			fifo_write ;
wire								wr_inc  , fifo_full  ; 

//signal interface between alu and clk_gating
wire								out_clk_gating ;


//signal interface between reg_file and alu
wire	[data_width -1 :0 ]		ALU_A , ALU_B ;

//signal interface between reg_file and clk_div
wire	[data_width -1 :0 ]		clk_div_ratio ;

//signal interface between UART_clk and clk_div
wire							tx_clk , rx_clk ;

//signal interface between FIFO and pulse_gen
wire							pulse_gen_out;



//uart block
uart_top UART (
.P_DATA_tx_in	 	(fifo_read) ,
.Data_Valid_tx_in	(!fifo_empty) ,
.clk_tx				(tx_clk) ,
.Tx_out				(tx_out) , 
.busy				(in_puls_gen)	,
.rx_in 				(rx_in) , 
.clk_rx				(rx_clk)  ,
.prescale			( RG2[7:2] ) ,
.p_data_rx_out		(RX_output)	,
.parity_error		(parity_error) , 
.stop_error			(stop_error) , 
.data_valid_rx_out	(rx_data_valid) ,
.Par_EN				(RG2[0]) , 
.Par_TYP			(RG2[1]) , 
.rst				(rst_domain_2_sync)
);

//uart RX connected to data sync
data_sync_top #( .N_flop(num_sync_stage) , .data_width(data_width) ) Data_syncronizer (
.unsync_bus 		(RX_output),
.bus_enable			(rx_data_valid) ,
.clk				(ref_clk) , 
.rst				(rst_domain_1_sync)  ,	
.sync_bus			(data_sync_out) ,
.enable_pulse		(frame_enable) 

);

//System control unit
sys_ctrl #( .data_width(data_width) , .addre_width (rg_addres_width) , .alu_func_width (alu_func_width) ) sys_control_unit (
.rx_p_data 		(data_sync_out) ,
.rx_d_valid		(frame_enable) ,
.rd_data 		(rd_data) ,
.rd_d_valid		(rg_rd_valid) ,
.alu_out 		(alu_output) ,
.alu_out_valid 	(alu_out_valid) ,
.fifo_full 		(fifo_full) ,
.clk			(ref_clk), 
.rst			(rst_domain_1_sync) ,
.wr_en			(wr_en) , 
.rd_en			(rd_en) ,
.wr_data		(wr_data),
.addres			(addres) ,
.tx_d_valid		(wr_inc) ,
.tx_p_data		(fifo_write),
.alu_func		(alu_func) ,
.alu_en 		(alu_en) ,
.clk_div_en		(clk_div_en) ,
.clk_gating_en 	(clk_gating_en)

);

//register file
register_file #( .WIDTH(data_width) , .DEPTH(reg_file_depth) , .ADDRESS_SIZE(rg_addres_width) ) reg_file (
.wr_data		(wr_data) ,
.address		(addres) ,
.wr_en			(wr_en),
.rd_en			(rd_en),
.clk			(ref_clk),
.rst			(rst_domain_1_sync),
.rd_data		(rd_data) ,
.rd_data_valid	(rg_rd_valid),
.rg0			(ALU_A  ) , 
.rg1			(ALU_B) , 
.rg2			(RG2) , 
.rg3			(clk_div_ratio)
);
//ALU
ALU #( .data_width(data_width) , .alu_func_width(alu_func_width) ) alu_block (
.A			(ALU_A) ,
.B			(ALU_B) ,
.ALU_FUN	(alu_func) ,
.enable		(alu_en),
.CLK		(out_clk_gating),
.rst		(rst_domain_1_sync),
.ALU_OUT	(alu_output) ,
.out_valid 	(alu_out_valid) 
);

//Async FIFO
fifo_top #( .data_width(data_width) , .depth(FIFO_DEPTH) , .address_width(FIFO_addres_width) )	ASYNC_FIFO (
.wr_data	(fifo_write) ,
.r_clk		(tx_clk) ,
.w_clk		(ref_clk) ,
.r_rst		(rst_domain_2_sync) ,
.w_rst		(rst_domain_1_sync) ,
.r_inc		(pulse_gen_out) , 
.w_inc		(wr_inc) ,
.rd_data	(fifo_read) ,
.full		(fifo_full) , 
.empty		(fifo_empty) 

);
//pulse generator
pulse_gen	pulse_generator_tx (
.in_pulse_gen (in_puls_gen),
.clk(tx_clk),
.rst(rst_domain_2_sync),
.out_pulse_gen(pulse_gen_out)
);


//Domain 1 reset syncronizer
rst_sync #( .N_flops(num_sync_stage) ) U1_rst_sync (
.clk(ref_clk),
.rst(rst),
.sync_rst(rst_domain_1_sync)

);
//Domain 2 reset syncronizer

rst_sync #( .N_flops(num_sync_stage) ) U2_rst_sync (
.clk		(uart_clk),
.rst		(rst),
.sync_rst	(rst_domain_2_sync)

);

//clk gating on ALU
CLK_GATE alu_clk_gating (
.CLK_EN		(clk_gating_en) ,
.CLK		(ref_clk) ,
.GATED_CLK	(out_clk_gating)
);

// tx clk divider
clk_divider TX_clk_div (
.i_ref_clk(uart_clk) , 
.i_rst_clk(rst_domain_2_sync) , 
.i_clk_en(clk_div_en) ,
.i_div_ratio(clk_div_ratio) ,
.o_div_clk (tx_clk)

);

wire	[7:0]	mux_out ;

// rx clk divider
clk_divider RX_clk_div (
.i_ref_clk(uart_clk) , 
.i_rst_clk(rst_domain_2_sync) , 
.i_clk_en(clk_div_en) ,
.i_div_ratio(mux_out) ,
.o_div_clk (rx_clk)

);

//mux for rx clk ;
rx_div_clk_mux	rx_div_clk_mux (
.prescale (RG2[7:2]) ,
.rx_div_ratio(mux_out)
);


endmodule