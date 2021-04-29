module crossbar #(parameter DATA_WIDTH, ADDRESS_WIDTH, SIGNAL_WIDTH)
		( 
		
			input wire[(SIGNAL_WIDTH-1):0]ps_xb_cuEn,
	
			input wire ps_xb_dmEn,

			input wire[(ADDRESS_WIDTH-1):0]ps_rf_xA,ps_rf_yA,ps_rf_wrtA,

			input wire [(DATA_WIDTH-1):0]dm_xb_dmD,alu_xb_rn,shf_xb_rn,mul_xb_rn,rf_xb_rx,rf_xb_ry,

			output reg [(DATA_WIDTH-1):0]xb_cu_rx,xb_cu_ry, 
		
			output reg xb_rf_En, 
			
			output reg [(DATA_WIDTH-1):0]xb_rf_d
		
		);

	wire x,y;

	wire cuEn=ps_xb_cuEn[0]|ps_xb_cuEn[1]|ps_xb_cuEn[2];

	assign x=(ps_rf_xA==ps_rf_wrtA);
	assign y=(ps_rf_yA==ps_rf_wrtA);


always@(*)
begin
	if(cuEn|ps_xb_dmEn)

	 xb_rf_En<=1;
		else
			xb_rf_En<=0;
end


always@(*)
begin
  case ({ps_xb_cuEn[2],ps_xb_cuEn[1],ps_xb_cuEn[0],ps_xb_dmEn})
  {1'b0,1'b0,1'b0,1'b1}:xb_rf_d<=dm_xb_dmD;
  {1'b0,1'b0,1'b1,1'b0}:xb_rf_d<=alu_xb_rn;
  {1'b0,1'b1,1'b0,1'b0}:xb_rf_d<=mul_xb_rn;
  {1'b1,1'b0,1'b0,1'b0}:xb_rf_d<=shf_xb_rn;
  default: xb_rf_d<=0;
  endcase
end



always@(*)
begin
	begin
		case(x)
			0:xb_cu_rx<=rf_xb_rx;
			1:begin
				case(xb_rf_En)
					0:xb_cu_rx<=rf_xb_rx;
					1:xb_cu_rx<=xb_rf_d;
					default:xb_cu_rx<=0;
				endcase
			end
			default:xb_cu_rx<=0;
		endcase
	end
	begin
		case(y)
			0:xb_cu_ry<=rf_xb_ry;
			1:begin
				case(xb_rf_En)
					0:xb_cu_ry<=rf_xb_ry;
					1:xb_cu_ry<=xb_rf_d;
					default:xb_cu_rx<=0;
				endcase
			end
			default:xb_cu_ry<=0;
		endcase
	end
end

endmodule 




/*module test_crossbar_O#(parameter DATA_WIDTH=16,ADDRESS_WIDTH=4,SIGNAL_WIDTH=3)();


reg [(SIGNAL_WIDTH-1):0]ps_xb_cuEn;

reg ps_xb_dmEn;

reg [(ADDRESS_WIDTH-1):0]ps_rf_xA,ps_rf_yA,ps_rf_wrtA;

reg [(DATA_WIDTH-1):0]dm_xb_dmD,alu_xb_rn,shf_xb_rn,mul_xb_rn,rf_xb_rx,rf_xb_ry;

wire [(DATA_WIDTH-1):0]xb_cu_rx,xb_cu_ry;
		
wire xb_rf_En; 
		

wire [(DATA_WIDTH-1):0]xb_rf_d;


crossbar_0 d_obj(ps_xb_cuEn,

		ps_xb_dmEn,

		ps_rf_xA,ps_rf_yA,ps_rf_wrtA,

		dm_xb_dmD,alu_xb_rn,shf_xb_rn,mul_xb_rn,rf_xb_rx,rf_xb_ry,

		xb_cu_rx,xb_cu_ry, 
		
		xb_rf_En, 
		
		xb_rf_d);

initial
begin
	ps_xb_cuEn=3'b000;
	#2 ps_xb_cuEn=3'b001;
	#3 ps_xb_cuEn=3'b000;
	#4 ps_xb_cuEn=3'b010;
	#5 ps_xb_cuEn=3'b000;
	#6 ps_xb_cuEn=3'b100;
	#3 ps_xb_cuEn=3'b000;
	#4 ps_xb_cuEn=3'b010;
	#5 ps_xb_cuEn=3'b000;
	#6 ps_xb_cuEn=3'b100;
end

initial
begin
	ps_xb_dmEn=1;
	#2 ps_xb_dmEn=0;
	#3 ps_xb_dmEn=0;
	#4 ps_xb_dmEn=0;
	#5 ps_xb_dmEn=1;
	#6 ps_xb_dmEn=0;
	#3 ps_xb_dmEn=1;
	#4 ps_xb_dmEn=0;
	#5 ps_xb_dmEn=1;
	#6 ps_xb_dmEn=0;
end




initial
begin
	alu_xb_rn=16'h0000;
	forever
	begin
		#6 alu_xb_rn=$urandom_range(16'h0000,16'hffff);
	end
end

initial
begin
	mul_xb_rn=16'h0000;
	forever
	begin
		#8 mul_xb_rn=$urandom_range(16'h0000,16'hffff);
	end
end

initial
begin
	shf_xb_rn=16'h0000;
	forever
	begin
		#9 shf_xb_rn=$urandom_range(16'h0000,16'hffff);
	end
end


initial
begin
	dm_xb_dmD=16'h0000;
	forever
	begin
		#9 dm_xb_dmD=$urandom_range(16'h0000,16'hffff);
	end
end


initial
begin
	rf_xb_rx=16'h0000;
	forever
	begin
		#5 rf_xb_rx=$urandom_range(16'h0000,16'hffff);
	end
end

initial
begin
	ps_rf_xA=4'h0;
	forever
	begin
		#2 ps_rf_xA=$urandom_range(4'h0,4'hf);
	end
end

initial
begin
	rf_xb_ry=16'h0001;
	forever
	begin
		#7 rf_xb_ry=$urandom_range(16'h0000,16'hffff);
	end
end

initial
begin
	ps_rf_yA=4'h2;
	forever
	begin
		#3.5 ps_rf_yA=$urandom_range(4'h0,4'hf);
	end
end

initial
begin
	ps_rf_wrtA=4'h3;
	forever
	begin
		#3 ps_rf_wrtA=$urandom_range(4'h0,4'hf);
	end
end

endmodule 
*/
