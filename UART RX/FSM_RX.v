module rx_fsm (
input	wire			rx_in , glitch , parity_error , stop_error , clk , rst , PAR_EN,
input	wire	[5:0]	edge_cnt , prescale ,
input	wire	[3:0]	bit_cnt , 


output		reg		edge_en , sample_data_en , start_checker_en , deserializer_en , parity_checker_en , 
output		reg		stop_checker_en , data_valid , new_frame , end_frame


);

wire 	open_enable ;
reg	data_valid_comb ;
reg		[2:0]	current__state , next_state ;
reg 	[1:0]	end_condition	;
assign open_enable = ( edge_cnt == (prescale>>1)+2 ) ;

localparam	idle 			= 3'b000 ,
			start_state 	= 3'b001 ,
			data_state		= 3'b010 ,
			parity_state	= 3'b011 ,
			stop_state		= 3'b100 ;

always @(posedge clk or negedge rst )
begin
	if(!rst)
	begin
		current__state <= idle ;
	end
	
	else
	begin
		current__state <= next_state ;
		data_valid <= data_valid_comb ;
	end
end		


always @(*)
begin
	data_valid_comb			 = 1'b0 ;
	edge_en				 = 1'b1 ;
	parity_checker_en 	 = 1'b0 ;
	sample_data_en 		 = 1'b1 ;
	start_checker_en	 = 1'b0	;
	stop_checker_en		 = 1'b0 ;
	deserializer_en		 = 1'b0 ;
	new_frame			 = 1'b0 ;
	end_frame            = 1'b0 ;
	data_valid_comb		 = 1'b0 ;
	case(current__state)
		idle : 
		begin
			//output
			edge_en				 = 1'b0 ;
			sample_data_en 		 = 1'b0 ;
			start_checker_en  	 = 1'b0	;
			parity_checker_en 	 = 1'b0 ;
			stop_checker_en		 = 1'b0 ;
			deserializer_en		 = 1'b0 ;
			end_frame   		 = 1'b0 ;
			new_frame			 = 1'b1 ;
			if(!rx_in)
			begin
				next_state = start_state ;
			end
			else
			begin
				next_state = idle ;
			end
			
		end
		
		start_state:
		begin
			edge_en 		= 1'b1 ;
			sample_data_en	= 1'b1 ;
			new_frame		= 1'b1 ;
			end_frame   	= 1'b0 ;
			if ( open_enable)
			begin
				start_checker_en = 1'b1;
			end
			else
			begin
				start_checker_en = 1'b0;
			end
			
			if(glitch)
			begin
				next_state = idle ;				
			end
			else if(bit_cnt == 'd1)
			begin
				next_state = data_state ;				
			end
			else
			begin
				next_state = start_state ;				
			end
		end
	
		data_state:
		begin
			edge_en = 1'b1;
			sample_data_en	= 1'b1;	
			
			if ( open_enable )
			begin
				deserializer_en = 1'b1;
			end
			else
			begin
				start_checker_en = 1'b0;
			end
					
			case ( { bit_cnt == 'd9 , PAR_EN } )
				2'b00:
				next_state = data_state;
				2'b01:
				next_state = data_state;
				2'b10:
				next_state = stop_state;
				2'b11:
				next_state = parity_state ;
			endcase
		end
		
		parity_state:
		begin
			edge_en = 1'b1;
			sample_data_en	= 1'b1;
			if ( open_enable )
			begin
				parity_checker_en = 1'b1;
			end
			else
			begin
				parity_checker_en = 1'b0;
			end
			
			if(bit_cnt == 'd10)
			begin
				next_state = stop_state ;				
			end
			else
			begin
				next_state = parity_state ;				
			end	
		end
		
		stop_state:
		begin
			edge_en = 1'b1;
			sample_data_en	= 1'b1;
			
			if ( open_enable )
			begin
				stop_checker_en = 1'b1;
			end
			else
			begin
				stop_checker_en = 1'b0;
			end
			end_condition =	{ /*bit_cnt == 'd10 | bit_cnt == 'd11 ,*/ rx_in , edge_cnt == (prescale - 1) }   ;
			case(  end_condition  )
				2'b10:
				next_state = stop_state;				
				2'b10:
				next_state = stop_state;
				2'b11:
				begin
				next_state = idle ;
				data_valid_comb =  !(stop_error | parity_error) ;
				end_frame = 1'b1;
				end
				2'b01:
				begin
				next_state = start_state ;
				data_valid_comb =  !(stop_error | parity_error) ;
				end_frame = 1'b1;
				end
			endcase
			
			 
		
		end
	endcase


end
	
	
	endmodule