//time scale and time presecion
`timescale 1ns/1ps

//module 
module 	UART_TX_tb ();

//stimulus and monitor signal decleration
reg		[7:0] 	P_data_tb ;
reg				Data_Valid_tb , Par_EN_tb , Par_TYP_tb;
reg				clk_tb , rst_tb;

wire 			Tx_out,busy_tb ;

//parametar

parameter CLK_period = 10;

//generate CLK
always #(CLK_period/2)	clk_tb = !clk_tb; 

//DUT instantiation

top_TX DUT_UART_TX (
.P_DATA			(P_data_tb) ,
.Data_Valid		(Data_Valid_tb),
.Par_EN			(Par_EN_tb),
.Par_TYP		(Par_TYP_tb),
.clk			(clk_tb),
.rst			(rst_tb),
.Tx_out			(Tx_out),
.busy			(busy_tb)	
);


//initial block
initial
begin
	$dumpfile("UART_TX.vcd");
	$dumpvars;
	
	initialization();//can remove
	#CLK_period
	reset();
	#CLK_period
	enter_input		( 8'b1101_1010 , 1'b1 , 1'b1 , 1'b1  ); //case of odd parity (data , valid , enable , parity )
	check_operation ( 11'b 1_1_1101_1010_0 , 1'b1, 1'b1 );		//(expected , parity enable)
	
	enter_input		( 8'b1101_1010 , 1'b1 , 1'b1 , 1'b0  ); //case of even parity 
	check_operation ( 11'b 1_0_1101_1010_0 , 1'b1 , 1'b0);
	
	#CLK_period
	enter_input		( 8'b1101_1010 , 1'b1 , 1'b0 , 1'b0  ); //case of no parity 
	check_operation ( 11'b 1_1101_1010_0 , 1'b0 , 1'b1 );
	
	#CLK_period
	enter_input		( 8'b1101_1010 , 1'b1 , 1'b0 , 1'b1  ); //case of no parity 
	check_operation ( 11'b 1_1101_1010_0 , 1'b0 , 1'b0);
	
	#(10*CLK_period)
	$stop;
	
	


end

task initialization ();
begin
	clk_tb 		  = 1'b0;
	rst_tb 		  = 1'b1;
	P_data_tb 	  = 8'd0;
	Data_Valid_tb = 1'b0;
	Par_EN_tb	  = 1'b0;
	Par_TYP_tb	  = 1'b0;

end
endtask




task reset ();
begin
	#CLK_period
	rst_tb = 1'b0;
	#CLK_period
	rst_tb = 1'b1;
end
endtask


task enter_input ;
input 	[7:0]	in_data ;
input 			in_valid , in_par_en , in_par_type ;

begin
	Data_Valid_tb 	= in_valid    ;
	P_data_tb 		= in_data     ;
	Par_EN_tb  		= in_par_en   ;
	Par_TYP_tb 		= in_par_type ;	
	#CLK_period
	Data_Valid_tb = 1'b0;
	
end
endtask


task check_operation ;
input	[10:0]	  expected_out;
input 			      parity_enable,parity_type;
reg   [10:0]   actual_out;
integer i ;

 begin
		if (parity_enable == 1'b1)
			begin
				actual_out[0] = Tx_out;
				#CLK_period
				actual_out[1] = Tx_out;
				#CLK_period
				actual_out[2] = Tx_out;
				#CLK_period
				actual_out[3] = Tx_out;
				#CLK_period
				actual_out[4] = Tx_out;
				#CLK_period
				actual_out[5] = Tx_out;
				#CLK_period
				actual_out[6] = Tx_out;
				#CLK_period
				actual_out[7] = Tx_out;
				#CLK_period
				actual_out[8] = Tx_out;
				#CLK_period
				actual_out[9] = Tx_out;
				#CLK_period
				actual_out[10] = Tx_out;
			end
			
		else
			begin
				actual_out[0] = Tx_out;
				#CLK_period
				actual_out[1] = Tx_out;
				#CLK_period
				actual_out[2] = Tx_out;
				#CLK_period
				actual_out[3] = Tx_out;
				#CLK_period
				actual_out[4] = Tx_out;
				#CLK_period
				actual_out[5] = Tx_out;
				#CLK_period
				actual_out[6] = Tx_out;
				#CLK_period
				actual_out[7] = Tx_out;
				#CLK_period
				actual_out[8] = Tx_out;
				#CLK_period
				actual_out[9] = Tx_out;
				
			end	
	if(actual_out == expected_out)
	$display("test case passed input data = %0b , parity_EN = %0b , Parity_TYP = %0b actual_value = %0b " , expected_out[8:1] , parity_enable , parity_type, actual_out );
	else
	$display("test case passed input data = %0b , parity_EN = %0b , Parity_TYP = %0b actual_value = %0b " , expected_out[8:1] , parity_enable,  parity_type, actual_out );
	
	actual_out = 11'd0;
 end
endtask


endmodule

