module	sys_ctrl #(parameter data_width = 8 , parameter addre_width = 4 , parameter alu_func_width = 4) (
input	wire	[data_width-1:0]		rx_p_data ,			//new frame from rx
input	wire							rx_d_valid ,		//there is a new frame 
input	wire	[data_width-1:0]		rd_data ,
input	wire							rd_d_valid ,
input	wire	[2*data_width - 1 :0]	alu_out ,
input	wire							alu_out_valid ,
input	wire							fifo_full ,

input	wire							clk, rst ,

output	reg								wr_en , rd_en ,
output	reg		[data_width-1 : 0]		wr_data ,	
output	reg		[addre_width-1: 0]		addres ,	
output	reg								tx_d_valid,
output	reg		[data_width-1 : 0]		tx_p_data ,
output	reg		[alu_func_width-1 :0]	alu_func ,
output	reg								alu_en ,
output	wire							clk_div_en ,
output	reg								clk_gating_en 
  
);


parameter state_width = 4 ;
reg		[state_width-1 : 0]		current_state , next_state ;

//internal signal
reg		[data_width-1: 0]		store, store_rg_out ;
reg								store_flag; //save addres in some cases 
reg		store_from_alu_or_reg , ALU_operation , read_MS_part ; 

localparam	idle_state				= 'd0,
			command_decode_state 	= 'd1,
			rg_W_addres_state		= 'd2,
			rg_W_data_state			= 'd3,
			rg_r_addres_state		= 'd4,
			write_fifo_state		= 'd5,
			alu_operand_a			= 'd6,
			alu_operand_b			= 'd7,
			alu_func_state			= 'd8 ;
			

always @(posedge clk or negedge rst )
begin
	if(!rst)
	begin
		current_state <= idle_state ;
		store		<= 0;
	end
	else
	begin
		current_state <= next_state ;
		if(store_from_alu_or_reg)
		store_rg_out  <= rd_data ;
		else if (!read_MS_part)
		store_rg_out  <= alu_out[data_width-1:0];
		else
		store_rg_out  <= alu_out[2*data_width-1:data_width];
		
		if(store_flag /*&& rx_d_valid*/ )
		begin
			store <= rx_p_data ;
		end
	end

end				

//clk_div_en always on 
assign clk_div_en = 1'b1;


//seq always to store some values in ff


always @(*)
begin
//initial value
				read_MS_part = 0;
				clk_gating_en 	=0;
				wr_en 			=0;
				rd_en			=0;
				tx_d_valid		=0;
				alu_en			=0;
				wr_data			=0;
				//addres			=0;
				alu_func		=0;
				tx_d_valid		=0;
				store_flag		=0;
				store_from_alu_or_reg = 'd1;
//FSM
	case (current_state)
		idle_state:
			begin
				clk_gating_en 	=0;
				wr_en 			=0;
				rd_en			=0;
				tx_d_valid		=0;
				alu_en			=0;
				wr_data			=0;
				//addres		=0;
				alu_func		=0;
				tx_d_valid		=0;
				
				if(rx_d_valid)
				begin
					next_state = command_decode_state ;
				end
				else
				begin
					next_state = idle_state ;
				end
				
			end
	
		command_decode_state:
			begin
			store_flag=1'b1;
				if(store == 'hAA && rx_d_valid )
				begin
					next_state =rg_W_addres_state;
				end
				else if (store == 'hBB && rx_d_valid)
				begin
					next_state=rg_r_addres_state;
				end
				else if (store == 'hCC && rx_d_valid)
				begin
					next_state = alu_operand_a;
					clk_gating_en = 1'b1;
				end
				else if (store == 'hDD && rx_d_valid)
				begin
					next_state=alu_func_state;
					clk_gating_en = 1'b1;
				end
				else
				begin
					next_state = command_decode_state ;
				end
				
				
			/*	
			case (rx_p_data)
				'hAA: next_state  = rg_W_addres_state ;
				'hBB: next_state  = rg_r_addres_state ;
				'hCC: begin
						next_state    = alu_operand_a ;
					    clk_gating_en = 1'b1;
					  end
				'hDD: begin
						next_state    = alu_func_state ;
					    clk_gating_en = 1'b1;
					  end	
				default:begin
						next_state    = idle ;
					    clk_gating_en = 1'b0;
					  end		
			endcase
*/

			end
			
		rg_W_addres_state :	
			begin
				store_flag = 1; //store addres
				if(rx_d_valid)
				begin
					next_state= rg_W_data_state ;
					store_flag = 0;
				end
				else
				begin
					next_state = rg_W_addres_state ;
					store_flag = 1;
				end		
			end
	
		rg_W_data_state :
			begin
				//first command exctution 
				wr_en  = 1'b1 ;
				addres = store ;
				wr_data = rx_p_data;
				// 
				
				
					next_state = idle_state ;
					
				
			end
	
		rg_r_addres_state :
			begin
				//seconed command exctution 
				rd_en = 1'b1 ;
				addres = rx_p_data ;
				store_from_alu_or_reg = 'd1;
				if(rd_d_valid)
				begin
					next_state= write_fifo_state ;
				end
				else
				begin
					next_state = rg_r_addres_state ;
				end	
			
			end
		
		write_fifo_state :
			begin
				tx_p_data = store_rg_out ;
				if (!fifo_full)
				begin
					tx_d_valid = 1'b1;
					
					if(ALU_operation)
					begin
						store_from_alu_or_reg=0;
						read_MS_part = 1;
						ALU_operation =0;
						next_state= write_fifo_state ;
					end
					else
					begin
						store_from_alu_or_reg=1;
						read_MS_part = 0;
						ALU_operation =0;
						next_state = idle_state ;
						
					end	
		
				end
				else
				begin
					tx_d_valid = 1'b0;					
					next_state = write_fifo_state ;
				end	
			
			end
			
				//thired command exctution 
		alu_operand_a :
			begin
				clk_gating_en = 1'b1;
				wr_en   = 1'b1;
				addres  = 'd0;
				wr_data = rx_p_data ;
				if(rx_d_valid)	
				begin
				next_state = alu_operand_b ;
				wr_en   = 1'b0;
				end
				else
				begin
				next_state = alu_operand_a ;
				wr_en   = 1'b1;
				end
			end
		
		alu_operand_b :
			begin
				clk_gating_en = 1'b1;
				addres  = 'd1 ;
				wr_data = rx_p_data ;
				wr_en   = 1'b1;
				if(rx_d_valid)	
				begin
				next_state = alu_func_state ;
				wr_en   = 1'b0;

				end
				else
				begin
				next_state = alu_operand_b ;
				wr_en   = 1'b1;
				end				
			
			end
			
		alu_func_state:
			begin
				clk_gating_en = 1'b1;
				alu_func = rx_p_data ;
				ALU_operation= 1'b1;				
				alu_en = 1'b1;
				store_from_alu_or_reg = 'd0;

				if(alu_out_valid)	
				begin				
				next_state = write_fifo_state ;
				end
				else
				begin
				next_state = alu_func_state ;
				end			
			
			end
		
	endcase
end




endmodule