module data_sampling (

input 	wire 	[5:0]	edge_cnt,
input	wire			sample_data_en ,clk,rst,rx_in ,
input   wire	[5:0]	prescale ,

output	reg		sampled_bit

);

reg  	[2:0]			over_sampling_bits ;
wire	[4:0]			first_bit , middle_bit , last_bit ;
wire 			is_4_prescale ;
reg				end_of_sampling ;	

//sampling bit 
assign		 first_bit  =	(prescale >> 1 ) - 'd2 ;
assign		middle_bit	=	(prescale >> 1 )  - 'd1   ;
assign  	last_bit	=	(prescale >> 1 )  ;

assign		is_4_prescale = (prescale == 'd 4 ) ;

always @(posedge clk or negedge rst)
begin
	if(!rst)
	begin
		sampled_bit <= 1'b1;
		over_sampling_bits <= 3'b111;
		end_of_sampling <= 1'b0;
	end
	
	else
	begin
	//if prescale = 4 over_sampling = 1
		if ( sample_data_en && is_4_prescale && edge_cnt == middle_bit )
		begin
			over_sampling_bits[1] <= rx_in ;
			end_of_sampling <= 1'b1;
		end
			
	//	if prescale > 4 over_sampling = 3
	
		else if (sample_data_en && !is_4_prescale && edge_cnt == first_bit)
		begin
			over_sampling_bits[0] <= rx_in ;		//sampling first_bit
		end
		
		else if (sample_data_en && !is_4_prescale && edge_cnt == middle_bit)
		begin
			over_sampling_bits[1] <= rx_in ;		//sampling second_bit
		end
		
		else if (sample_data_en && !is_4_prescale && edge_cnt == last_bit)
		begin
			over_sampling_bits[2] <= rx_in ;
			end_of_sampling <= 1'b1;			//sampling third_bit
		end
		
		else if (end_of_sampling && is_4_prescale )
		begin
			sampled_bit = over_sampling_bits[1];
			end_of_sampling <= 1'b0;
		end
		
		else if (end_of_sampling && !is_4_prescale )
		begin
			case(over_sampling_bits)
			3'b000 :	sampled_bit= 0'b0 ;
			3'b001 :	sampled_bit= 0'b0 ;
			3'b010 :	sampled_bit= 0'b0 ;
			3'b011 :	sampled_bit= 0'b1 ;
			3'b100 :	sampled_bit= 0'b0 ;
			3'b101 :	sampled_bit= 0'b1 ;
			3'b110 :	sampled_bit= 0'b1 ;
			3'b111 :	sampled_bit= 0'b1 ;
			endcase
			end_of_sampling <= 1'b0;
		end
	
	end



end

endmodule