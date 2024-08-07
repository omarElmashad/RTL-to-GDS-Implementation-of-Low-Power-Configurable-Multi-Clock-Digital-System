module UART_TX_FSM (
input 	wire 	valid , ser_done,clk,rst,par_en ,

output 	reg 			 free, ser_en, busy,
output  reg 	[1:0]    mux_selection
);	

reg 	[2:0]	current_state , next_state ;

localparam	idle 			= 3'b000 ,
			start_state 	= 3'b001 ,
			data_state		= 3'b010 ,
			parity_state	= 3'b011 ,
			stop_state		= 3'b100 ;


always @(posedge clk or negedge rst )
begin
	if(!rst)
		begin
			current_state <= idle ;
		end
	else
		begin
			current_state <= next_state ;	
		end

end

always @(*)
begin
	mux_selection=2'b01; //default
	free   = 1'b0;
	busy   = 1'b1;
	ser_en = 1'b0;
	case(current_state)
	
		idle:
		begin
			//output
				busy =1'b0;
				free =1'b1 ;
				ser_en=1'b0;
			//next state
				if(valid)
					begin
						next_state=start_state;
					end
				else
					begin
						next_state=idle;
					end
		end
	
		start_state:
		begin
			//output
				mux_selection =2'b00;
				busy =1'b1 ;
				free =1'b0 ;
				ser_en=1'b1;
				next_state=data_state;
		end	

		data_state:
		begin
			//output
				mux_selection =2'b10;
				busy =1'b1;
				free =1'b0 ;
				ser_en=1'b1;
			//next state
				case( {ser_done,par_en} )
					2'b00:
						next_state=data_state;
					2'b01:	
						next_state=data_state;
					2'b10:
						next_state=stop_state;
					2'b11:
						next_state=parity_state;
				endcase
					
		end
	
		parity_state:
		begin
			//output
				mux_selection =2'b11;
				busy =1'b1 ;
				free =1'b0 ;
				ser_en=1'b0;
				//next state
				next_state = stop_state;
		end
		
		stop_state:
		begin
			//output
				mux_selection =2'b01;
				busy =1'b1 ;
				free =1'b1 ;
				ser_en=1'b0;
			//next state
				if(valid)
					begin
						next_state=start_state;
					end
				else
					begin
						next_state=idle;
					end
		end
	
	
	endcase
	

end


endmodule