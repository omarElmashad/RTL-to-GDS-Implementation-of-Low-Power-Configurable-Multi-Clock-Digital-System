module	rx_div_clk_mux (

input	wire	[5:0]	prescale ,

output	reg		[7:0]	rx_div_ratio
);

always @(*)
begin
	case(prescale)
		'd32 : rx_div_ratio = 'd1;
		'd16 : rx_div_ratio = 'd2;
		'd8 : rx_div_ratio = 'd4;
		default : rx_div_ratio = 'd1 ;
	
	


	endcase
end

endmodule