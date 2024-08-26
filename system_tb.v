`timescale 1ns/1ps
module ctrl_system_tb ();

parameter ref_clk_period = 10 , uart_clk_period = 271 ;

//internal 
reg		rx_in_tb , ref_clk_tb , uart_clk_tb , rst_tb ;
wire	tx_out_tb ,parity_error_tb , stop_error_tb ;

//clk
always #(ref_clk_period/2)		ref_clk_tb  = ~ref_clk_tb;
always #(uart_clk_period/2)	uart_clk_tb = ~uart_clk_tb;

parameter data_width = 8 ; parameter addre_width = 4 ; parameter alu_func_width = 4 ; parameter num_sync_stage = 2 ;
					 parameter rg_addres_width	= 4 ;	parameter reg_file_depth = 16	;	
						parameter FIFO_DEPTH	= 8 ;	parameter FIFO_addres_width = 3	;				



//DUT
system_top #(.data_width(data_width) , .addre_width(addre_width) , .alu_func_width(alu_func_width) , .num_sync_stage(num_sync_stage) ,
				.rg_addres_width(rg_addres_width) , .reg_file_depth(reg_file_depth) , .FIFO_DEPTH(FIFO_DEPTH) , .FIFO_addres_width(FIFO_addres_width) )
																														DUT (
.rx_in			(rx_in_tb) ,
.ref_clk		(ref_clk_tb) , 
.uart_clk		(uart_clk_tb) , 
.rst			(rst_tb) ,
.tx_out			(tx_out_tb) ,
.parity_error	(parity_error_tb) , 
.stop_error	(stop_error_tb)

);

 
initial
begin

	//initilalization
	ref_clk_tb = 1'b0;
	uart_clk_tb = 1'b0;
	rst_tb = 1'b1;
	#ref_clk_period
	rst_tb = 1'b0;
	#ref_clk_period
	rst_tb = 1'b1;


 //////////////// Default Configuration //////////////////
 ////////////////   PRESCALE : 32       //////////////////
 ////////////////   Parity   : Enabled  //////////////////
 ////////////////   TYPE     : EVEN     //////////////////
 
//first command write in register file in specific address
$display ("checking first command ");

enter_frame ('b 1_1_1010_1010_0); //command frame 0xAA
enter_frame ('b 1_1_0000_1010_0); //address frame location 10
enter_frame ('b 1_1_1010_1010_0); // data frame data 170
checking_write_command ( 'b1010_1010 , 'b0000_1010 ); //checking command check if stored in address 10 data 170

//second command read from specific address from register file
$display ("checking second command ");
enter_frame ('b 1_1_1011_1011_0);//command frame 0xBB
enter_frame ('b 1_1_0000_1010_0);//address frame read from location 10
checking_read_command('b 1_1_1010_1010_0 ,'b0000_1010  ) ;//checking command check if the read data from location 10 is 170

 
//third command ALU operation with operand A and B
$display ("checking third command ");
enter_frame ('b 1_1_1100_1100_0);//command frame 0xCC
enter_frame ('b 1_0_1100_1000_0);//operand A data 200
enter_frame ('b 1_1_1111_1010_0);//operand B data 250
enter_frame ('b 1_0_0000_0010_0);//alu function multiplicataion
checking_alu_command('b 1_1_0101_0000_0, 'b 1_1_1100_0011_0  , 'd2   ); 


//fourth command ALU operation without operand
$display ("checking fourth command ");
enter_frame ('b 1_1_1101_1101_0);//command frame 0XDD
enter_frame ('b 1_1_0000_0000_0);//alu function addition
checking_alu_command('b 1_0_1100_0010_0, 'b 1_0_0000_0001_0  , 'd0   );


////////////////  Configuration //////////////////
 ////////////////   PRESCALE : 16       //////////////////
 ////////////////   Parity   : off  //////////////////
 ////////////////   TYPE     : EVEN     //////////////////
 
enter_frame ('b 1_1_1010_1010_0); //command frame 0xAA
enter_frame ('b 1_0_0000_0010_0); //address frame location 2
enter_frame ('b 1_0_0100_0000_0); // data frame 
checking_write_command ( 'b0100_0000 , 'b0000_0010 );

//first command write in register file in specific address
$display ("checking first command ");

enter_frame ('b 1_1010_1010_0); //command frame 0xAA
enter_frame ('b 1_0000_0110_0); //address frame location 10
enter_frame ('b 1_1010_1010_0); // data frame data 170
checking_write_command ( 'b1010_1010 , 'b0000_0110 ); //checking command check if stored in address 6 data 170

//second command read from specific address from register file
$display ("checking second command ");
enter_frame ('b 1_1011_1011_0);//command frame 0xBB
enter_frame ('b 1_0000_1010_0);//address frame read from location 10
checking_read_command('b 1_1010_1010_0 ,'b0000_1010  ) ;//checking command check if the read data from location 10 is 170

 
//third command ALU operation with operand A and B
$display ("checking third command ");
enter_frame ('b 1_1100_1100_0);//command frame 0xCC
enter_frame ('b 1_1100_1000_0);//operand A data 200
enter_frame ('b 1_1111_1010_0);//operand B data 250
enter_frame ('b 1_0000_0010_0);//alu function multiplicataion
checking_alu_command('b 1_0101_0000_0, 'b 1_1100_0011_0  , 'd2   ); 


//fourth command ALU operation without operand
$display ("checking fourth command ");
enter_frame ('b 1_1101_1101_0);//command frame 0XDD
enter_frame ('b 1_0000_0000_0);//alu function addition
checking_alu_command('b 1_1100_0010_0, 'b 1_0000_0001_0  , 'd0   );


////////////////  Configuration //////////////////
 ////////////////   PRESCALE : 8       //////////////////
 ////////////////   Parity   : on  //////////////////
 ////////////////   TYPE     : odd     //////////////////
 
enter_frame ('b 1_1010_1010_0); //command frame 0xAA
enter_frame ('b 1_0000_0010_0); //address frame location 2
enter_frame ('b 1_0010_0011_0); // data frame 
checking_write_command ( 'b00010_0011 , 'b0000_0010 );

//first command write in register file in specific address
$display ("checking first command ");

enter_frame ('b 1_0_1010_1010_0); //command frame 0xAA
enter_frame ('b 1_0_0000_1111_0); //address frame location 15
enter_frame ('b 1_0_1000_1110_0); // data frame data 142
checking_write_command ( 'b1000_1110 , 'b0000_1111 ); //checking command check if stored in address 6 data 170

//second command read from specific address from register file
$display ("checking second command ");
enter_frame ('b 1_0_1011_1011_0);//command frame 0xBB
enter_frame ('b 1_0_0000_1111_0);//address frame read from location 10
checking_read_command('b 1_0_1000_1110_0 ,'b0000_1111  ) ;//checking command check if the read data from location 10 is 170

 
//third command ALU operation with operand A and B
$display ("checking third command ");
enter_frame ('b 1_0_1100_1100_0);//command frame 0xCC
enter_frame ('b 1_1_1100_1000_0);//operand A data 200
enter_frame ('b 1_0_0000_0101_0);//operand B data 5
enter_frame ('b 1_0_0000_0011_0);//alu function division
checking_alu_command('b 1_0_0010_1000_0, 'b 1_0_0000_0000_0  , 'd3   ); 


//fourth command ALU operation without operand
$display ("checking fourth command ");
enter_frame ('b 1_0_1101_1101_0);//command frame 0XDD
enter_frame ('b 1_1_0000_0001_0);//alu function addition
checking_alu_command('b 1_0_1100_0011_0, 'b 1_0_0000_0000_0  , 'd1   );

#(uart_clk_period*15*32)
$stop;


end

task enter_frame ;
	input	[10:0]	frame ;
	integer i ;

	begin
		if(DUT.reg_file.rg2[0])
		begin
			for(i=0 ; i<=10 ; i=i+1)
			begin
				@(posedge DUT.UART.clk_tx)
				rx_in_tb = frame[i];
			end
		end
		else
		begin
			for(i=0 ; i<10 ; i=i+1)
			begin
				@(posedge DUT.UART.clk_tx)
				rx_in_tb = frame[i];
			end
		end
	end
endtask



task checking_write_command;
	input 	[data_width-1 : 0]	expected_data,address ;
	//reg 	[data_width-1 : 0]	 ;
	
	begin
		wait(DUT.reg_file.wr_en)
		#(2*ref_clk_period)
		$display("with configuration PARITY_ENABLE=%d PARITY_TYPE=%d  PRESCALE=%d",DUT.reg_file.rg2[0] , DUT.reg_file.rg2[1] , DUT.reg_file.rg2[data_width-1:2]);	
		if(expected_data == DUT.reg_file.reg_file[address] )
		begin		
		$display("test case for write in register passed , input data = %d in addres =  %d , data stored = %d ",expected_data , address ,DUT.reg_file.reg_file[address]);
		end
		else
		begin
		$display("test case for write in register faild , input data = %d in addres =  %d , data stored = %d ",expected_data , address ,DUT.reg_file.reg_file[address]);
		end
	end
endtask

task checking_read_command ;
	input	[10:0]				expected_data;
	input	[data_width-1:0]	address;
	integer 					i;
	reg		[10:0] 				actual_data;
	begin
		
		$display("with configuration PARITY_ENABLE=%d PARITY_TYPE=%d  PRESCALE=%d",DUT.reg_file.rg2[0] , DUT.reg_file.rg2[1] , DUT.reg_file.rg2[data_width-1:2]);
		if(DUT.reg_file.rg2[0]) //checking there is a parity bit or no
		begin
			@(posedge DUT.UART.busy)
			for(i=0 ; i<=10 ; i=i+1 )
			begin
				@(negedge DUT.UART.clk_tx )
				actual_data[i] = tx_out_tb ;
			end
			if(expected_data == actual_data[10:0] )
			begin		
				$display("test case for read from register file passed , in address = %d , data = %b , TX_out = %b  ",address , DUT.reg_file.reg_file[address] , actual_data );
				end
				else
				begin
				$display("test case for read from register file faild , in address = %d , data = %b , TX_out = %b  ",address , DUT.reg_file.reg_file[address] , actual_data );
			end			
		end
		
		else
		begin
			@(posedge DUT.UART.busy)
			for(i=0 ; i<10 ; i=i+1 )
			begin
				@(negedge DUT.UART.clk_tx )
				actual_data[i] = tx_out_tb ;
			end
			if(expected_data == actual_data[9:0] )
			begin		
				$display("test case for read from register file passed , in address = %d , data = %b , TX_out = %b  ",address , DUT.reg_file.reg_file[address] , actual_data[9:0] );
				end
				else
				begin
				$display("test case for read from register file faild , in address = %d , data = %b , TX_out = %b  ",address , DUT.reg_file.reg_file[address] , actual_data[9:0] );
			end		
			
			
		end
		
		
		
	end
endtask

task checking_alu_command;
	input	[10:0]		expected_data_LS,expected_data_MS;
	input	[alu_func_width-1:0]	alu_func ;
	integer 						i;
	reg		[10:0]					actual_data_LS,actual_data_MS;
	begin
	
	$display("with configuration PARITY_ENABLE=%d PARITY_TYPE=%d  PRESCALE=%d",DUT.reg_file.rg2[0] , DUT.reg_file.rg2[1] , DUT.reg_file.rg2[data_width-1:2]);
		if(DUT.reg_file.rg2[0]) //checking there is a parity bit or no
		begin
			//read LS part
			@(posedge DUT.UART.busy)
			for(i=0 ; i<=10 ; i=i+1 )
			begin
				@(negedge DUT.UART.clk_tx )
				actual_data_LS[i] = tx_out_tb ;
			end
			
			//read MS part
			@(posedge DUT.UART.busy)
			for(i=0 ; i<=10 ; i=i+1 )
			begin
				@(negedge DUT.UART.clk_tx )
				actual_data_MS[i] = tx_out_tb ;
			end
			
			if(expected_data_LS == actual_data_LS[10:0] && expected_data_MS == actual_data_MS[10:0] )
			begin		
				$display("test case for alu operation passed , A = %d , B = %d , ALU_FUNC = %d , alu_out = %d in binary = %b , actual first frame = %b , actual second frame = %b "
				 ,DUT.reg_file.rg0       , DUT.reg_file.rg1      , alu_func      , {expected_data_MS[8:1] , expected_data_LS[8:1] } , {expected_data_MS[8:1] , expected_data_LS[8:1] } , actual_data_LS , actual_data_MS );
				end
				else
				begin
				$display("test case for alu operation faild , A = %d , B = %d , ALU_FUNC = %d , alu_out = %d in binary = %b ,  actual first frame = %b , actual second frame = %b "
				 ,DUT.reg_file.rg0       , DUT.reg_file.rg1      , alu_func      , {expected_data_MS[8:1] , expected_data_LS[8:1] } , {expected_data_MS[8:1] , expected_data_LS[8:1] } , actual_data_LS , actual_data_MS );
			
			end	
			actual_data_LS  = 'd0 ;
			actual_data_MS	= 'd0 ;	
		end
		
		else
		begin		
			//read LS part
			@(posedge DUT.UART.busy)
			for(i=0 ; i<10 ; i=i+1 )
			begin
				@(negedge DUT.UART.clk_tx )
				actual_data_LS[i] = tx_out_tb ;
			end
			
			//read MS part
			@(posedge DUT.UART.busy)
			for(i=0 ; i<10 ; i=i+1 )
			begin
				@(negedge DUT.UART.clk_tx )
				actual_data_MS[i] = tx_out_tb ;
			end
			
			if(expected_data_LS == actual_data_LS[9:0] && expected_data_MS == actual_data_MS[9:0] )
			begin		
				$display("test case for alu operation passed , A = %d , B = %d , ALU_FUNC = %d , alu_out = %d in binary = %b , actual first frame = %b , actual second frame = %b "
				 ,DUT.reg_file.rg0       , DUT.reg_file.rg1      , alu_func      , {expected_data_MS[8:1] , expected_data_LS[8:1] } , {expected_data_MS[8:1] , expected_data_LS[8:1] } , actual_data_LS[9:0] , actual_data_MS[9:0] );
				end
				else
				begin
				$display("test case for alu operation faild , A = %d , B = %d , ALU_FUNC = %d , alu_out = %d in binary = %b , actual first frame = %b , actual second frame = %b "
				 ,DUT.reg_file.rg0       , DUT.reg_file.rg1      , alu_func      , {expected_data_MS[8:1] , expected_data_LS[8:1] } , {expected_data_MS[8:1] , expected_data_LS[8:1] } , actual_data_LS[9:0] , actual_data_MS[9:0] );
			
			end			
		
			actual_data_LS  = 'd0 ;
			actual_data_MS	= 'd0 ;		
			
		end
	
	
	
	end
endtask
/*
task checking_alu_command_without_operand;
	input	[10:0]		expected_data_LS,expected_data_MS;
	input	[alu_func_width-1:0]	alu_func ;
	integer i ;
	reg		[10:0]					actual_data_LS,actual_data_MS;
	begin
	$display("with configuration PARITY_ENABLE=%d PARITY_TYPE=%d  PRESCALE=%d",DUT.reg_file.rg2[0] , DUT.reg_file.rg2[1] , DUT.reg_file.rg2[data_width-1:2]);
	
	if(DUT.reg_file.rg2[0]) //checking there is a parity bit or no
		begin
			//read LS part
			@(posedge DUT.UART.busy)
			for(i=0 ; i<=10 ; i=i+1 )
			begin
				@(negedge DUT.UART.clk_tx )
				actual_data_LS[i] = tx_out_tb ;
			end
			
			//read MS part
			@(posedge DUT.UART.busy)
			for(i=0 ; i<=10 ; i=i+1 )
			begin
				@(negedge DUT.UART.clk_tx )
				actual_data_MS[i] = tx_out_tb ;
			end
			
			if(expected_data_LS == actual_data_LS[10:0] && expected_data_MS == actual_data_MS[10:0] )
			begin		
				$display("test case for alu operation without operand passed , reg0(A) = %d , reg1(B) = %d , ALU_FUNC = %d , alu_out = %d in binary = %b , actual first frame = %b , actual second frame = %b "
				 ,A       , B      , alu_func      , {expected_data_MS[8:1] , expected_data_LS[8:1] } , {expected_data_MS[8:1] , expected_data_LS[8:1] } , actual_data_LS , actual_data_MS );
				end
				else
				begin
				$display("test case for alu operation without operand faild , A = %d , B = %d , ALU_FUNC = %d , alu_out = %d in binary = %b ,  actual first frame = %b , actual second frame = %b "
				 ,A       , B      , alu_func      , {expected_data_MS[8:1] , expected_data_LS[8:1] } , {expected_data_MS[8:1] , expected_data_LS[8:1] } , actual_data_LS , actual_data_MS );
			
			end			
		end
		
		else
		begin		
			//read LS part
			@(posedge DUT.UART.busy)
			for(i=0 ; i<10 ; i=i+1 )
			begin
				@(negedge DUT.UART.clk_tx )
				actual_data_LS[i] = tx_out_tb ;
			end
			
			//read MS part
			@(posedge DUT.UART.busy)
			for(i=0 ; i<10 ; i=i+1 )
			begin
				@(negedge DUT.UART.clk_tx )
				actual_data_MS[i] = tx_out_tb ;
			end
			
			if(expected_data_LS == actual_data_LS[9:0] && expected_data_MS == actual_data_MS[9:0] )
			begin		
				$display("test case for alu operation passed , A = %d , B = %d , ALU_FUNC = %d , alu_out = %d in binary = %b , actual first frame = %b , actual second frame = %b "
				 ,A       , B      , alu_func      , {expected_data_MS[8:1] , expected_data_LS[8:1] } , {expected_data_MS[8:1] , expected_data_LS[8:1] } , actual_data_LS , actual_data_MS );
				end
				else
				begin
				$display("test case for alu operation faild , A = %d , B = %d , ALU_FUNC = %d , alu_out = %d in binary = %b , actual first frame = %b , actual second frame = %b "
				 ,A       , B      , alu_func      , {expected_data_MS[8:1] , expected_data_LS[8:1] } , {expected_data_MS[8:1] , expected_data_LS[8:1] } , actual_data_LS , actual_data_MS );
			
			end			
			
			
		end
	
		
	end
endtask
*/
endmodule