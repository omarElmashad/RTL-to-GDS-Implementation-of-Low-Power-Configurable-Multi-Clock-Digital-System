module clk_divider (

input	wire			i_ref_clk , i_rst_clk , i_clk_en ,
input 	wire	[7:0]	i_div_ratio ,

output	wire				o_div_clk

);

reg	 [6:0]	counter ;
wire		is_odd ;
wire 		toggle;
reg			odd_flag_toggle;
wire		odd_toggle;
wire		enable;
reg			div_clk;


assign is_odd				= i_div_ratio[0] ;
assign toggle				= (counter == i_div_ratio >> 1 ) ;	
assign odd_toggle			= (counter == (i_div_ratio >> 1) +1 ) ;
assign enable				= (i_clk_en & (i_div_ratio != 'd0 ) & (i_div_ratio != 'd1 ) ) ;
assign o_div_clk			= (enable ? div_clk : i_ref_clk ) ;
 
always @(posedge i_ref_clk or negedge i_rst_clk)
begin
	if(! i_rst_clk)
	begin
		div_clk	 		<= 1'b1 ;
		counter  	 		<= 7'd0 ;
		odd_flag_toggle		<= 1'b1 ;
	end
	else 
	begin
		
		 if ( enable 	)
			begin
		
				if( !is_odd && toggle ) // if even 
				begin
					div_clk <= !div_clk ;
					counter <= 1'b1 ;
					
				end
				
				else if (is_odd && ( ( toggle && odd_flag_toggle ) || (odd_toggle && !odd_flag_toggle)	 )	 ) // if odd
				begin
					div_clk 		<= !div_clk ;
					counter 		<= 1'b1 ;
					odd_flag_toggle <= !odd_flag_toggle ;
				end	
				else 
				begin
					counter = counter +1;
				end	
			
			end

		
		else
			begin
			div_clk		 		<= 1'b1 ;
			counter  	 		<= 7'd0 ;
			odd_flag_toggle		<= 1'b1 ;
			end
		
	end
	
	
	
end

endmodule