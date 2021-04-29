module regfile #(parameter DATA_WIDTH, ADDRESS_WIDTH, SIGNAL_WIDTH)
			( 
			
			input wire clk,  xb_rf_En, 
			
			input wire [(ADDRESS_WIDTH-1):0]ps_rf_wrtA,  ps_rf_xA,  ps_rf_yA,
			
			input wire[(DATA_WIDTH-1):0] xb_rf_d,  
			
			output reg[(DATA_WIDTH-1):0] rf_xb_rx,  rf_xb_ry

			);

reg[(DATA_WIDTH-1):0]regfile[(2**ADDRESS_WIDTH-1):0];

always@(posedge clk)
begin
	if(xb_rf_En)
	begin
		case(ps_rf_wrtA)
	4'h0:regfile[0]<=xb_rf_d;
	4'h1:regfile[1]<=xb_rf_d;
	4'h2:regfile[2]<=xb_rf_d;
	4'h3:regfile[3]<=xb_rf_d;
	4'h4:regfile[4]<=xb_rf_d;
	4'h5:regfile[5]<=xb_rf_d;
	4'h6:regfile[6]<=xb_rf_d;
	4'h7:regfile[7]<=xb_rf_d;
	4'h8:regfile[8]<=xb_rf_d;
	4'h9:regfile[9]<=xb_rf_d;
	4'ha:regfile[10]<=xb_rf_d;
	4'hb:regfile[11]<=xb_rf_d;
	4'hc:regfile[12]<=xb_rf_d;
	4'hd:regfile[13]<=xb_rf_d;
	4'he:regfile[14]<=xb_rf_d;
	4'hf:regfile[15]<=xb_rf_d;
		endcase
	end
end

always@(*)
begin
	rf_xb_rx<=regfile[ps_rf_xA];
	rf_xb_ry<=regfile[ps_rf_yA];
end

endmodule 


/*module test_regfile_O#(parameter DATA_WIDTH=16,ADDRESS_WIDTH=4,SIGNAL_WIDTH=3,REG_WIDTH=16)();
			
			reg clk,  xb_rf_En; 
			
			reg [(ADDRESS_WIDTH-1):0]ps_rf_wrtA,  ps_rf_xA,  ps_rf_yA;
			
			reg[(DATA_WIDTH-1):0] xb_rf_d;
			
			wire [(DATA_WIDTH-1):0] rf_xb_rx,  rf_xb_ry;

			

regfile d_obj(clk,  xb_rf_En, ps_rf_wrtA,  ps_rf_xA,  ps_rf_yA, xb_rf_d, rf_xb_rx,  rf_xb_ry );

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
	xb_rf_En=0;
	forever
	begin
		#7 xb_rf_En=~xb_rf_En;
	end
end

initial
begin
	ps_rf_wrtA=4'h0;
	forever
	begin
		#5 ps_rf_wrtA=$urandom_range(4'h0,4'hf);
	end
end

initial
begin
	xb_rf_d=16'h0000;
	forever
	begin
		#6 xb_rf_d=$urandom_range(16'h0000,16'hffff);
	end
end

initial
begin
	ps_rf_xA=4'h0;
	forever
	begin
		#7 ps_rf_xA=$urandom_range(4'h0,4'hf);
	end
end

initial
begin
	ps_rf_yA=4'h0;
	forever
	begin
		#8 ps_rf_yA=$urandom_range(4'h0,4'hf);
	end
end
endmodule
*/
