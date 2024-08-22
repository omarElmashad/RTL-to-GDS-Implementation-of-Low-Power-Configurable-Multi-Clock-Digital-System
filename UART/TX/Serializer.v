module serializer (
input 	wire	 [7:0]		P_data ,
input 	wire 	 			ser_done,ser_en,valid,free,	
input   wire 				clk,reset, 

output reg					ser_data

);

reg [3:0] 	counter;	
reg [7:0] 	store_data;

assign ser_done = (counter == 4'd8) ;

always @(posedge clk or negedge reset)
	begin
		if(!reset)
			begin
				counter  	    <= 4'd8 ;
				ser_data 		<= 1'b0 ;
				store_data		<= 4'd0 ;
			end
			
		else
			begin
			
				if( valid && free )
				begin
					store_data 		<= P_data ;	
					counter 		<= 4'd0 ;
				end
				
				else if(ser_en && !ser_done)
				begin
					ser_data <= store_data[ counter ] ;
					counter  <= counter + 1 ;
				end
				
					
				
				
			end
	
	end
	
	
	
	
endmodule	