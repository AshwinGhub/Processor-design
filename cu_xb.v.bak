module crossbar #(parameter DATA_WIDTH, ADDRESS_WIDTH, SIGNAL_WIDTH)
		( 
		
		input wire[(SIGNAL_WIDTH-1):0] ps_xb_w_cuEn,

		input wire ps_xb_w_bcEn,

		input wire[(ADDRESS_WIDTH-1):0] ps_xb_wadd,  ps_xb_raddx,  ps_xb_raddy,

		input wire [(DATA_WIDTH-1):0] bc_dt, alu_xb_dt, shf_xb_dt, mul_xb_dt, rf_xb_dtx, rf_xb_dty,

		output reg [(DATA_WIDTH-1):0] xb_dtx, xb_dty, 
		
		output reg xb_rf_w_En, 
		
		output reg [(DATA_WIDTH-1):0]xb_rf_dt
		
		);
	
	wire x,y;

	wire cuEn=ps_xb_w_cuEn[0]|ps_xb_w_cuEn[1]|ps_xb_w_cuEn[2];

	assign x=(ps_xb_raddx==ps_xb_wadd);
	assign y=(ps_xb_raddy==ps_xb_wadd);


always@(*)
begin
	if(cuEn|ps_xb_w_bcEn)

	 xb_rf_w_En<=1;
		else
			xb_rf_w_En<=0;
end


always@(*)
begin
  case ({ps_xb_w_cuEn[2],ps_xb_w_cuEn[1],ps_xb_w_cuEn[0],ps_xb_w_bcEn})
  {1'b0,1'b0,1'b0,1'b1}:xb_rf_dt<=bc_dt;
  {1'b0,1'b0,1'b1,1'b0}:xb_rf_dt<=alu_xb_dt;
  {1'b0,1'b1,1'b0,1'b0}:xb_rf_dt<=mul_xb_dt;
  {1'b1,1'b0,1'b0,1'b0}:xb_rf_dt<=shf_xb_dt;
  default: xb_rf_dt<=0;
  endcase
end



always@(*)
begin
	begin
		case(x)
			0:xb_dtx<=rf_xb_dtx;
			1:begin
				case(xb_rf_w_En)
					0:xb_dtx<=rf_xb_dtx;
					1:xb_dtx<=xb_rf_dt;
					default:xb_dtx<=0;
				endcase
			end
			default:xb_dtx<=0;
		endcase
	end
	begin
		case(y)
			0:xb_dty<=rf_xb_dty;
			1:begin
				case(xb_rf_w_En)
					0:xb_dty<=rf_xb_dty;
					1:xb_dty<=xb_rf_dt;
					default:xb_dty<=0;
				endcase
			end
			default:xb_dty<=0;
		endcase
	end
end

endmodule 



/*
module test_crossbar_cu#(parameter DATA_WIDTH=16,ADDRESS_WIDTH=4,SIGNAL_WIDTH=3)();


reg [(SIGNAL_WIDTH-1):0]ps_xb_w_cuEn;

reg ps_xb_w_bcEn;

reg [(ADDRESS_WIDTH-1):0]ps_xb_wadd,  ps_xb_raddx,  ps_xb_raddy;

reg [(DATA_WIDTH-1):0]bc_dt,alu_xb_dt,shf_xb_dt,mul_xb_dt,rf_xb_dtx,rf_xb_dty;

wire [(DATA_WIDTH-1):0]xb_dtx,xb_dty;
		
wire xb_rf_w_En; 
		

wire [(DATA_WIDTH-1):0]xb_rf_dt;


crossbar_cu d_obj(ps_xb_w_cuEn,

		ps_xb_w_bcEn,

		ps_xb_wadd,  ps_xb_raddx,  ps_xb_raddy,

		bc_dt,alu_xb_dt,shf_xb_dt,mul_xb_dt,rf_xb_dtx,rf_xb_dty,

		xb_dtx,xb_dty,
		
		xb_rf_w_En, 
		
		xb_rf_dt);

initial
begin
	ps_xb_w_cuEn=3'b000;
	#2 ps_xb_w_cuEn=3'b001;
	#3 ps_xb_w_cuEn=3'b000;
	#4 ps_xb_w_cuEn=3'b010;
	#5 ps_xb_w_cuEn=3'b000;
	#6 ps_xb_w_cuEn=3'b100;
	#3 ps_xb_w_cuEn=3'b000;
	#4 ps_xb_w_cuEn=3'b010;
	#5 ps_xb_w_cuEn=3'b000;
	#6 ps_xb_w_cuEn=3'b100;
end

initial
begin
	ps_xb_w_bcEn=1;
	#2 ps_xb_w_bcEn=0;
	#3 ps_xb_w_bcEn=0;
	#4 ps_xb_w_bcEn=0;
	#5 ps_xb_w_bcEn=1;
	#6 ps_xb_w_bcEn=0;
	#3 ps_xb_w_bcEn=1;
	#4 ps_xb_w_bcEn=0;
	#5 ps_xb_w_bcEn=1;
	#6 ps_xb_w_bcEn=0;
end




initial
begin
	alu_xb_dt=16'h0000;
	forever
	begin
		#6 alu_xb_dt=$urandom_range(16'h0000,16'hffff);
	end
end

initial
begin
	mul_xb_dt=16'h0000;
	forever
	begin
		#8 mul_xb_dt=$urandom_range(16'h0000,16'hffff);
	end
end

initial
begin
	shf_xb_dt=16'h0000;
	forever
	begin
		#9 shf_xb_dt=$urandom_range(16'h0000,16'hffff);
	end
end


initial
begin
	bc_dt=16'h0000;
	forever
	begin
		#9 bc_dt=$urandom_range(16'h0000,16'hffff);
	end
end


initial
begin
	rf_xb_dtx=16'h0000;
	forever
	begin
		#5 rf_xb_dtx=$urandom_range(16'h0000,16'hffff);
	end
end

initial
begin
	ps_xb_raddx=4'h0;
	forever
	begin
		#2 ps_xb_raddx=$urandom_range(4'h0,4'hf);
	end
end

initial
begin
	rf_xb_dty=16'h0001;
	forever
	begin
		#7 rf_xb_dty=$urandom_range(16'h0000,16'hffff);
	end
end

initial
begin
	ps_xb_raddy=4'h2;
	forever
	begin
		#3.5 ps_xb_raddy=$urandom_range(4'h0,4'hf);
	end
end

initial
begin
	ps_xb_wadd=4'h3;
	forever
	begin
		#3 ps_xb_wadd=$urandom_range(4'h0,4'hf);
	end
end

endmodule 
*/
