module pulse_gen (
input	wire	in_pulse_gen ,
input	wire	clk,rst,

output	wire	out_pulse_gen
);
//define internal flop
reg		flop;

assign out_pulse_gen =(in_pulse_gen & !flop ) ;
  
always @(posedge clk or negedge rst)
begin

if(!rst)
	begin
		flop <= 'd0;
	end
else
	begin
		flop <= in_pulse_gen ;
	end

end


endmodule
