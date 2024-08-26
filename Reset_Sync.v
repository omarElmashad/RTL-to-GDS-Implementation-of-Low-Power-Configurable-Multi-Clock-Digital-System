module rst_sync #(parameter N_flops = 2) (
input	wire	clk,rst,

output	wire	sync_rst

);

//internal flops
reg		[N_flops-1:0] flops ;

always @(posedge clk or negedge rst)
begin
	if(!rst)
	begin
		flops <= 0;
	end
	
	else
	begin
	flops <= {   flops[ N_flops-2:0] , 1'b1  } ;
	end

end

assign sync_rst = flops[N_flops-1] ;

endmodule