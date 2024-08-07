module top_rx (
input	wire			rx_in ,PAR_en , PAR_typ , clk , rst ,
input   wire	[5:0]	prescale ,

output	wire		[7:0]	p_data	,
output  wire			parity_error , stop_error , data_valid 

);


wire	   		 edge_en , end_frame , sample_data_en , sampled_bit , start_en ,glitch , deserializer_en ;
wire			 parity_en , new_frame , stop_en ;
wire	[5:0] 	 edge_cnt ;
wire	[3:0]	 bit_cnt;


bit_edge_counter edge_counter (
.edge_en		(edge_en)  ,
.clk			(clk) , 
.rst			(rst) ,
.end_frame		(end_frame) ,
.prescale_edge	(prescale) ,
. edge_cnt 		(edge_cnt),
.bit_cnt		(bit_cnt)
);

data_sampling sampling_block (
.edge_cnt		(edge_cnt),
.sample_data_en	(sample_data_en),
.clk			(clk),
.rst			(rst),
.rx_in			(rx_in) ,
.prescale		(prescale) ,
.sampled_bit		(sampled_bit) 
);

start_checker start_ckeck_block (
.start_en		 (start_en), 
.sampled_bit	 (sampled_bit),
.glitch			 (glitch)
);

serializer deseializer (
.sampled_bit	(sampled_bit) , 
.serializer_en 	(deserializer_en), 
.clk 			(clk), 
.rst 			(rst),
.bit_cnt		(bit_cnt),
.P_Data			(p_data)
);

parity_check parity_check_block (
.parity_en		(parity_en) , 
.sampled_bit	(sampled_bit) , 
.par_typ 		(PAR_typ), 
.new_frame		(new_frame) , 
.clk 			(clk), 
.rst			(rst) ,
.p_data			(p_data) ,
.parity_error 	(parity_error)
);


stop_check stop_check_block (
.stop_en		(stop_en) , 
.sampled_bit	(sampled_bit), 
.new_frame		(new_frame)  , 
.clk 			(clk), 
.rst 			(rst),
.stop_error		(stop_error)
);

rx_fsm FSM_RX (
.rx_in				(rx_in), 
.glitch 			(glitch), 
.parity_error 		(parity_error), 
.stop_error 		(stop_error), 
.clk				(clk), 
.rst 				(rst), 
.PAR_EN				(PAR_en),
.edge_cnt			(edge_cnt) , 
.prescale 			(prescale),
.edge_en 			(edge_en), 
.sample_data_en 	(sample_data_en), 
.start_checker_en	(start_en) , 
.deserializer_en 	(deserializer_en), 
.parity_checker_en 	(parity_en),
.stop_checker_en 	(stop_en), 
.data_valid 		(data_valid), 
.new_frame 			(new_frame), 
.end_frame 			(end_frame),
.bit_cnt(bit_cnt)
);


endmodule