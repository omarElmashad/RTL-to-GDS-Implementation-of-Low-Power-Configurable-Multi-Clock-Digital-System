module ALU #(parameter data_width = 8 , parameter alu_func_width = 4 )(
  //input signals
  input wire [data_width-1:0] 		A,
  input wire [data_width-1:0] 		B,
  input wire [alu_func_width-1:0]   ALU_FUN,
  input wire        				enable,CLK,rst,
  //output sognals
  output reg [2*data_width-1:0] 	ALU_OUT,
  output reg					out_valid	
  );
  //internal signals
  reg [2*data_width-1:0] value ;
  reg					out_valid_comb ;
  //combintional always block
 always @(*)
 begin
	if(enable)
	begin
	out_valid_comb = 1'b1;
      case( ALU_FUN )
          'b0000 : value = A+B ;
          'b0001 : value = A-B ;
          'b0010 : value = A*B ;
          'b0011 : value = A/B ;
          'b0100 : value = A&B ;
          'b0101 : value = A|B ;
          'b0110 : value = ~(A&B) ;
          'b0111 : value = ~(A|B) ;
          'b1000 : value = A^B ;
          'b1001 : value = ~(A^B) ;
          'b1010 :
            begin 
              if(A == B)
                value = 'd1;
              else
                value = 'd0;   
            end  
          'b1011 :
            begin 
              if(A > B)
                value = 'd2;
              else
                value = 'd0;   
            end 
          'b1100 :
            begin 
              if(A < B)
                value = 'd3;
              else
                value = 'd0;   
            end  
          'b1101 : value = A>>1 ;
          'b1110 : value = A<<1 ;  
          default:  value = 'd0 ; 
  
        endcase 
	end
	
	else
	begin
		value = 'd0 ;
		out_valid_comb = 1'b0;
	end
		
 end  
  //seq always 
  always @(posedge CLK or negedge rst)
    begin
		if(!rst)
		begin
			ALU_OUT   <= 'd0;
			out_valid <= 'd0 ;
		end
		
		else
		begin
		ALU_OUT<=value;
		out_valid <= out_valid_comb;
		end
		
    end
    
   
 
  
endmodule