module top_TX (
input wire [7:0] P_DATA,
input wire 		 Data_Valid,Par_EN,Par_TYP,
input wire 		 clk,rst,

output wire 	Tx_out,busy			
);

wire ser_en ,ser_done,free,ser_data,par_bit;
wire [1:0] mux_sel;

serializer ser_top (
.P_data(P_DATA) ,
.ser_done(ser_done),
.ser_en(ser_en),
.valid(Data_Valid),
.free(free),
.clk(clk),
.reset(rst),
.ser_data(ser_data) 	
);

parity_bit parity_top (
.p_data_par(P_DATA),
.valid_par(Data_Valid),
.free_par(free),
.parity_type(Par_TYP),
.par_pit(par_bit)
);

mux mux_top(
.mux_sel(mux_sel),
.ser_data(ser_data),
.parity_bit(par_bit),
.mux_out(Tx_out)
);

 UART_TX_FSM fsm_top (
.valid(Data_Valid) ,
.ser_done(ser_done),
.clk(clk),
.rst(rst),
.par_en(Par_EN) ,
.free(free),
.ser_en(ser_en),
.busy(busy	),
.mux_selection(mux_sel)
 );
 endmodule
