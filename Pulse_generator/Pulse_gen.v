module pulse_gen (
input	wire	in_pulse_gen ,
input	wire	clk,rst,

output	wire	out_pulse_gen
);
//define internal flop
reg 	rcv_flop ;
reg		flop;

assign out_pulse_gen =(in_pulse_gen & !flop ) ;
  
always @(posedge clk or negedge rst)
begin

if(!rst)
	begin
		flop 	 <= 'd0;
		rcv_flop <= 'd0;
	end
else
	begin
		rcv_flop <= in_pulse_gen ;
		flop	 <= rcv_flop ;
	end

end


endmodule
