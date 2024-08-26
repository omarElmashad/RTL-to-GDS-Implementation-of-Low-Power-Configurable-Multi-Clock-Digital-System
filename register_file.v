module register_file #(parameter WIDTH = 8,
                       parameter DEPTH = 16 , 
                       parameter ADDRESS_SIZE = 4  )
(
//inputs
input wire 		[WIDTH-1:0]         wr_data,
input wire		[ADDRESS_SIZE-1:0]  address,
input wire      	               wr_en,rd_en,clk,rst,
//outputs
output reg 		[WIDTH-1:0]         rd_data   ,
output reg							rd_data_valid ,
output wire	   	[WIDTH-1:0]			rg0 , rg1 , rg2 , rg3
);                       

reg [WIDTH-1:0] reg_file [0:DEPTH-1];
integer i ;

assign rg0 = reg_file[0];
assign rg1 = reg_file[1];
assign rg2 = reg_file[2];
assign rg3 = reg_file[3];


always @(posedge clk or negedge rst )
  begin
    if (!rst)
    begin
	rd_data_valid<= 'd0;
	rd_data <= 'd0;
	  for(i=0 ; i<= DEPTH-1 ; i=i+1 )
		begin
			if(i == 'd2 )
			begin
				reg_file[i] <= 'b 100000_0_1 ;
			end
			else if(i == 'd3)
			begin
				reg_file[i] <= 'd32 ;
			end
			else
			begin
			reg_file[i] <= 'b0 ;
			end
		end
		
    end
      
    else
      begin
          if(wr_en==1'b1 && rd_en==1'b0 )
              begin
                reg_file[address] <= wr_data ;
				rd_data_valid <= 1'b0;	

              end
          else if (wr_en==1'b0 && rd_en==1'b1 ) 
              begin
                rd_data <= reg_file[address] ;
				rd_data_valid <= 1'b1;
              end
		  else
				begin
				rd_data_valid <= 1'b0;	
				end
            
      end
 end 
 
 
 
 
 
 
  endmodule
    
    
    
  
                        