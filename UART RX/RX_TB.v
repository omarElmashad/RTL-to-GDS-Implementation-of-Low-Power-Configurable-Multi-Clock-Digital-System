`timescale 1us/10ns 

module uart_RX_tb ();

//stimuils and monitor signals
reg 			rx_in_tb , PAR_en_tb , PAR_typ_tb , rx_clk_tb , rst_tb ;
reg		[5:0]	prescale_tb ;
wire	[7:0]	p_data_tb ;
wire			parity_error_tb , stop_error_tb , data_valid_tb ;

reg			tx_clk ;

parameter prescale = 'd8 ;

parameter	tx_period = 8.68 ;
parameter	rx_period = (tx_period / prescale ) ;

always #(tx_period/2)  tx_clk = !tx_clk ;	
always #(rx_period/2)  rx_clk_tb =  !rx_clk_tb ;


top_rx	DUT_RX_TB (
.rx_in 			(rx_in_tb),
.PAR_en 		(PAR_en_tb), 
.PAR_typ		(PAR_typ_tb) , 
.clk 			(rx_clk_tb), 
.rst 			(rst_tb),
.prescale		(prescale_tb) ,
.p_data			(p_data_tb) ,
.parity_error 	(parity_error_tb)	, 
.stop_error		(stop_error_tb) 	, 
.data_valid		(data_valid_tb) 

);	

initial
begin
	$dumpfile("RX_tb.vcd");
	$dumpvars;
	
	initialization();
	#rx_period
	reset () ;
	#rx_period
	#( 8.68/2 - (rx_period * 4) )
	//case odd parity with no error
	enter_data 		( 'b 1_0_0110_1010_0 , 1'b1 , 1'b1   );				//(input , parity enable , parity type)
	check_operation ( 'b 1_0_0110_1010_0 , 1'b0 , 1'b0   );				//(input , parity_error , stop error , )
	
	//case even parity with no error
	enter_data 		( 'b 1_0_0100_1100_0 , 1'b1 , 1'b0   );				//(input , parity enable , parity type)
	check_operation ( 'b 1_0_0100_1100_0 , 1'b0 , 1'b0   );				//(input , parity_error , stop error , )
	
	//case error in parity
	enter_data 		( 'b 1_0_0100_1100_0 , 1'b1 , 1'b1   );				//(input , parity enable , parity type)
	check_operation ( 'b 1_0_0100_1100_0 , 1'b1 , 1'b0   );				//(input , parity_error , stop error , )
	
	//case error in stop	
	enter_data 		( 'b 0_1_0100_1100_0 , 1'b1 , 1'b1   );				//(input , parity enable , parity type)
	check_operation ( 'b 0_1_0100_1100_0 , 1'b0 , 1'b1   );				//(input , parity_error , stop error , )
	
	//case no parity
	enter_data 		( 'b 1_0111_1000_0 , 1'b0 , 1'b1   );				//(input , parity enable , parity type)
	check_operation ( 'b 1_0111_1000_0 , 1'b0 , 1'b0   );				//(input , parity_error , stop error , )
	
	
	
	#(10*rx_period)
	$stop;
	
end

task initialization ();
begin
tx_clk		= 1'b1 ;
rx_in_tb 	= 1'b1 ;
PAR_en_tb	= 1'b0 ;
PAR_typ_tb  = 1'b0 ;	
rx_clk_tb	= 1'b0 ;
prescale_tb = prescale ;
rst_tb		= 1'b1 ;
end
endtask

task reset () ;
begin
#rx_period
rst_tb		= 1'b0 ;
#rx_period
rst_tb		= 1'b1 ;
end
endtask

task enter_data  ;
	input	[10:0]	in_data ;
	input			parity_en , parity_typ ;
	begin
		PAR_en_tb  = parity_en  ;
		PAR_typ_tb = parity_typ ;
	
	if (parity_en)
	begin
		rx_in_tb = in_data[0];
		#tx_period
		rx_in_tb = in_data[1];
		#tx_period
		rx_in_tb = in_data[2];
		#tx_period
		rx_in_tb = in_data[3];
		#tx_period
		rx_in_tb = in_data[4];
		#tx_period
		rx_in_tb = in_data[5];
		#tx_period
		rx_in_tb = in_data[6];
		#tx_period
		rx_in_tb = in_data[7];
		#tx_period
		rx_in_tb = in_data[8];
		#tx_period
		rx_in_tb = in_data[9];
		#tx_period
		rx_in_tb = in_data[10];
		#tx_period
		rx_in_tb = 1'b1;
	end
	else
	begin
		rx_in_tb = in_data[0];
		#tx_period
		rx_in_tb = in_data[1];
		#tx_period
		rx_in_tb = in_data[2];
		#tx_period
		rx_in_tb = in_data[3];
		#tx_period
		rx_in_tb = in_data[4];
		#tx_period
		rx_in_tb = in_data[5];
		#tx_period
		rx_in_tb = in_data[6];
		#tx_period
		rx_in_tb = in_data[7];
		#tx_period
		rx_in_tb = in_data[8];
		#tx_period
		rx_in_tb = in_data[9];
		#tx_period
		rx_in_tb = 1'b1;
	end
		
	end
endtask

task check_operation ;
	input	[10:0]	in_data ;
	input			parity_error , stop_error ;
begin
	
	if ( p_data_tb == in_data [8:1] && parity_error == parity_error_tb && stop_error == stop_error_tb )
	begin
	$display("test case is passed input_data = %0b , output_data = %b , stop error = %b , parity error= %b" , in_data , p_data_tb ,  stop_error_tb , parity_error_tb   );
	end
	
	else
	begin
	$display("test case is faild input_data = %0b , output_data = %b , stop error = %b , parity error= %b" , in_data , p_data_tb , stop_error_tb , parity_error_tb   );
	end
	in_data = 'd0;
end
endtask

endmodule