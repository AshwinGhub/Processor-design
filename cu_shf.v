

module shifter #(parameter DATASIZE)
		(
			clk, 
			ps_shf_en, ps_shf_cls, 
			xb_dtx, xb_dty, 
			shf_xb_dt, shf_ps_sv, shf_ps_sz
		);



input wire clk;
input wire ps_shf_en;
input wire [1:0]ps_shf_cls;
input wire [DATASIZE-1:0]xb_dtx;
input wire [DATASIZE-1:0]xb_dty;
output reg [DATASIZE-1:0]shf_xb_dt;
output reg shf_ps_sv, shf_ps_sz;

reg [DATASIZE-1:0]ip1, ip2; 
reg [1:0]shf_classif;
reg shf_en;

wire [DATASIZE-1:0]ip2_2c;
wire [DATASIZE-1:0]rot;
wire [DATASIZE-1:0]rot_inv;
assign ip2_2c = (ip2^{DATASIZE{ip2[DATASIZE-1]}})+ip2[DATASIZE-1];
assign rot = ip2_2c%16'd16;
assign rot_inv = 16'd16-rot;

reg [7:0]zval8, oval8;
reg [4:0]zval4, oval4;
reg [4:0]leftz, lefto;

reg [DATASIZE-1:0]rot1, rot2;

always@*
begin

	case(shf_classif)
		2'b00:	begin
			
			if(ip2[DATASIZE-1])				//Rn = ip2_2c Rx BY Ry	//negative ry will right shift; positive Ry will left shift.
			begin
				shf_xb_dt=$signed(ip1)>>>ip2_2c;
				shf_ps_sv=1'b0;	//overflow flag
			end
			else	
			begin		
				shf_xb_dt=ip1<<<ip2;
				
			//overflow flag
			if(ip1[DATASIZE-1]!=shf_xb_dt[DATASIZE-1])
				shf_ps_sv=1'b1;
			else 
				shf_ps_sv=1'b0;

			end

			//zero flag					
			if(shf_xb_dt==16'h0000)
				shf_ps_sz=1'b1;
			else 
				shf_ps_sz=1'b0;

			
				
			end
		2'b01:	begin

			if(ip2[DATASIZE-1])			//Rn = ROT Rx BY Ry	//negative ry will rotate right; positive Ry will rotate left.
			begin
				rot1=rot;
				rot2=rot_inv;
			end
			else
			begin
				rot1=rot_inv;
				rot2=rot;
			end

			shf_xb_dt = (ip1>>rot1) | (ip1<<rot2);

			
			//zero flag
			if(shf_xb_dt==16'h0000)
				shf_ps_sz=1'b1;
			else 
				shf_ps_sz=1'b0;
					
			//overflow flag
			shf_ps_sv=1'b0;

			end	
			
	2'b10:	begin
				if(ip1 == 16'h0000) 	leftz=5'b10000;		//for all-zero value
				else
				begin
					leftz[4]=1'b0;
					leftz[3] = (ip1[15:8] == 8'h00);	
					zval8      = (leftz[3] ? ip1[7:0] : ip1[15:8]);
					leftz[2] = (zval8[7:4] == 4'h0);
					zval4      = (leftz[2] ? zval8[3:0] : zval8[7:4]);
					leftz[1] = (zval4[3:2] ==2'b00);
					leftz[0] = leftz[1] ? ~zval4[1] : ~zval4[3];
				end
				
				shf_xb_dt=leftz;	

					//zero flag
				if(ip1[DATASIZE-1])
					shf_ps_sz=1'b1;
				else 
					shf_ps_sz=1'b0;
				
				//overflow flag
				if(shf_xb_dt==16'h0010)
					shf_ps_sv=1'b1;
				else 
					shf_ps_sv=1'b0;
			
		end

	2'b11:	begin
				if(ip1 == 16'hffff) 	lefto=5'b10000;		//for all-one value
				else
				begin
					lefto[4]=1'b0;
					lefto[3] = (ip1[15:8] == 8'hff);
					oval8    = (lefto[3] ? ip1[7:0] : ip1[15:8]);
					lefto[2] = (oval8[7:4] == 4'hf);
					oval4   = (lefto[2] ? oval8[3:0] : oval8[7:4]);
					lefto[1] = (oval4[3:2] == 2'b11);
					lefto[0] = lefto[1] ? oval4[1] : oval4[3];
				end
				
				shf_xb_dt=lefto;

					//zero flag
				if(!ip1[DATASIZE-1])
					shf_ps_sz=1'b1;
				else 
					shf_ps_sz=1'b0;
					
				//overflow flag
				if(shf_xb_dt==16'h0010)
					shf_ps_sv=1'b1;
				else 
					shf_ps_sv=1'b0;
				
		end
	endcase
end

always@(posedge clk)
begin

	if(ps_shf_en) 
	begin
		shf_classif<=ps_shf_cls;
		shf_en<=ps_shf_en;
	
		ip1<=xb_dtx;
		if(!ps_shf_cls[1])	ip2<=xb_dty;
	end
	
end

endmodule


/*
module test_shifter_b#(parameter DATASIZE = 16)();


reg clk, ps_shf_en;
reg [1:0]ps_shf_cls;
reg [DATASIZE-1:0]xb_dtx, xb_dty;
wire[DATASIZE-1:0]shf_xb_dt;
wire shf_ps_sv, shf_ps_sz;

shifter_b b_obj(clk, ps_shf_en, ps_shf_cls, xb_dtx, xb_dty, shf_xb_dt, shf_ps_sv, shf_ps_sz);

initial
begin
	clk=1;
	forever
	begin
		#5 clk=~clk;
	end
end
initial
begin
	ps_shf_en=0;
	#11 ps_shf_en=1;
//	#40 ps_shf_en=0;
	end

initial
begin
	#11 ps_shf_cls=2'b00;
	#10 ps_shf_cls=2'b01;
	#10 ps_shf_cls=2'b10;
	#10 ps_shf_cls=2'b11;
	#10 ps_shf_cls=2'b00;
	#10 ps_shf_cls=2'b01;

end

initial
begin
	#11 xb_dtx=16'hf000;
	#10 xb_dtx=16'hc000;
	#10 xb_dtx=16'h0000;
	#10 xb_dtx=16'hffa0;
	#10 xb_dtx=16'ha690;
	#10 xb_dtx=16'h8888;

end

initial
begin
	#11 xb_dty=16'hfffc;
	#10 xb_dty=16'h0002;
	#10 xb_dty=16'h00ab;
	#10 xb_dty=16'h0034;
	#10 xb_dty=16'h0006;
	#10 xb_dty=16'hfffe;

end

endmodule
*/
