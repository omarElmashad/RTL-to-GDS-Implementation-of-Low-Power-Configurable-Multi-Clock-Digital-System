module mux (
 input 	wire 	[1:0] 	mux_sel ,
 input 	wire			ser_data,parity_bit ,
 
 output	reg				mux_out

);


always @(*)
	begin
		case (mux_sel)
			2'b00:
				mux_out = 1'b0;		//start bit
			2'b01:
				mux_out = 1'b1 ;	//start and idel state
			2'b10:
				mux_out = ser_data ;		//data
			2'b11:
				mux_out = parity_bit ;		//parity bit
		
		
		endcase
		
		
	
	end
	
	endmodule
