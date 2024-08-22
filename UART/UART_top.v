module uart_top (
//tx
input wire [7:0] P_DATA_tx_in,
input wire 		 Data_Valid_tx_in,
input wire 		 clk_tx ,
output wire 	 Tx_out , busy	,

//rx
input	wire			rx_in  , clk_rx  ,
input   wire	[5:0]	prescale ,

output	wire	[7:0]	p_data_rx_out	,
output  wire			parity_error , stop_error , data_valid_rx_out ,

//commen
input wire 		 Par_EN , Par_TYP , rst
);

top_TX top_TX (
.P_DATA		(P_DATA_tx_in),
.Data_Valid	(Data_Valid_tx_in),
.Par_EN		(Par_EN),
.Par_TYP	(Par_TYP),
.clk		(clk_tx),
.rst		(rst),
.Tx_out		(Tx_out),
.busy		(busy)

);

top_rx top_rx (
.rx_in			(rx_in),
.PAR_en			(Par_EN) , 
.PAR_typ		(Par_TYP) , 
.clk			(clk_rx) , 
.rst			(rst) ,
.prescale		(prescale) ,
.p_data			(p_data_rx_out) ,
.parity_error 	(parity_error), 
.stop_error 	(stop_error), 
.data_valid		(data_valid_rx_out) 

);



endmodule