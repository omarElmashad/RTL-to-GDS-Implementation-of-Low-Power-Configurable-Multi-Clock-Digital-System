module	data_sync_top #(parameter N_flop = 2 , parameter data_width = 8) (
input	wire	[data_width-1 : 0]		unsync_bus ,
input	wire							bus_enable ,
input	wire							clk , rst  ,		 //destination domain clock and reset

output	wire	[data_width-1 : 0]		sync_bus ,
output	wire							enable_pulse		//output from pusle generator 
);

//define internal signals
wire	flop_sync_out ,pulse_gen_out ;

n_flop_sync #( .data_width(1) , .N_flop (N_flop)  )	flop_sync (
.in_data	(bus_enable),
.clk		(clk),
.rst		(rst) ,
.out_data	(flop_sync_out)
);

pulse_gen u0_pulse_gen (
.in_pulse_gen   (flop_sync_out),
.clk			(clk),
.rst			(rst),
.out_pulse_gen	(pulse_gen_out)

);

mux_sele #( .data_width(data_width) ) mux_sele_bus (
.in_unsync_data	(unsync_bus) ,
.in_enable		(pulse_gen_out) ,
.clk			(clk),
.rst			(rst) ,
.out_sync_data 	(sync_bus) ,
.out_enable 	(enable_pulse)
);

endmodule