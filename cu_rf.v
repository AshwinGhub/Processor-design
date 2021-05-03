module regfile #(parameter DATA_WIDTH, ADDRESS_WIDTH, SIGNAL_WIDTH)
			( 
			
			input wire clk,  xb_rf_w_En, 
			
			input wire [(ADDRESS_WIDTH-1):0]ps_xb_wadd,  ps_xb_raddx,  ps_xb_raddy,
			
			input wire[(DATA_WIDTH-1):0] xb_rf_dt,  
			
			output reg[(DATA_WIDTH-1):0] rf_xb_dtx,  rf_xb_dty

			);

reg[(DATA_WIDTH-1):0]regfile[(2**ADDRESS_WIDTH-1):0];



always@(posedge clk)
begin
	if(xb_rf_w_En)
	begin
		case(ps_xb_wadd)
	4'h0:regfile[0]<=xb_rf_dt;
	4'h1:regfile[1]<=xb_rf_dt;
	4'h2:regfile[2]<=xb_rf_dt;
	4'h3:regfile[3]<=xb_rf_dt;
	4'h4:regfile[4]<=xb_rf_dt;
	4'h5:regfile[5]<=xb_rf_dt;
	4'h6:regfile[6]<=xb_rf_dt;
	4'h7:regfile[7]<=xb_rf_dt;
	4'h8:regfile[8]<=xb_rf_dt;
	4'h9:regfile[9]<=xb_rf_dt;
	4'ha:regfile[10]<=xb_rf_dt;
	4'hb:regfile[11]<=xb_rf_dt;
	4'hc:regfile[12]<=xb_rf_dt;
	4'hd:regfile[13]<=xb_rf_dt;
	4'he:regfile[14]<=xb_rf_dt;
	4'hf:regfile[15]<=xb_rf_dt;
		endcase
	end
end

always@(*)
begin
	rf_xb_dtx<=regfile[ps_xb_raddx];
	rf_xb_dty<=regfile[ps_xb_raddy];
end

endmodule 

/*
module test_regfile_cu#(parameter DATA_WIDTH=16,ADDRESS_WIDTH=4,SIGNAL_WIDTH=3)();
			
			reg clk,  xb_rf_w_En; 
			
			reg [(ADDRESS_WIDTH-1):0]ps_xb_wadd,  ps_xb_raddx,  ps_xb_raddy;
			
			reg[(DATA_WIDTH-1):0] xb_rf_dt;
			
			wire [(DATA_WIDTH-1):0] rf_xb_dtx,  rf_xb_dty;

			

regfile_cu d_obj(clk,  xb_rf_w_En, ps_xb_wadd,  ps_xb_raddx,  ps_xb_raddy, xb_rf_dt, rf_xb_dtx,  rf_xb_dty );

initial
begin
	clk=0;
	forever
	begin
		#5 clk=~clk;
	end
end

initial
begin
	xb_rf_w_En=0;
	forever
	begin
		#7 xb_rf_w_En=~xb_rf_w_En;
	end
end

initial
begin
	ps_xb_wadd=4'h0;
	forever
	begin
		#5 ps_xb_wadd=$urandom_range(4'h0,4'hf);
	end
end

initial
begin
	xb_rf_dt=16'h0000;
	forever
	begin
		#6 xb_rf_dt=$urandom_range(16'h0000,16'hffff);
	end
end

initial
begin
	ps_xb_raddx=4'h0;
	forever
	begin
		#7 ps_xb_raddx=$urandom_range(4'h0,4'hf);
	end
end

initial
begin
	ps_xb_raddy=4'h0;
	forever
	begin
		#8 ps_xb_raddy=$urandom_range(4'h0,4'hf);
	end
end
endmodule 
*/
