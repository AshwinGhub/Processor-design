module ureg_dcd (clk,ps_pshstck,ps_popstck,ps_imminst,ps_dminst,ps_urgtrnsinst,ps_dm_wrb,ps_ureg1_add,ps_ureg2_add,ps_rf_dm_wrt_en,ps_dg_wrt_en,ps_wrt_en,ps_rf_dm_rd_add,ps_rf_dm_wrt_add,ps_dg_rd_add,ps_rd_add,ps_dg_wrt_add,ps_wrt_add);

input clk;
input ps_pshstck,ps_popstck,ps_imminst,ps_dminst,ps_urgtrnsinst,ps_dm_wrb;
input[7:0] ps_ureg1_add,ps_ureg2_add;
output ps_rf_dm_wrt_en,ps_dg_wrt_en,ps_wrt_en;
output[3:0] ps_rf_dm_rd_add,ps_rf_dm_wrt_add;
output[4:0] ps_dg_rd_add,ps_rd_add,ps_dg_wrt_add,ps_wrt_add;

reg ps_rf_dm_wrt_en,ps_dg_wrt_en,ps_wrt_en;
reg[3:0] ps_rf_dm_rd_add,ps_rf_dm_wrt_add;
reg[4:0] ps_dg_rd_add,ps_rd_add,ps_dg_wrt_add,ps_wrt_add;

always@(*) begin
	
	if(ps_pshstck | (ps_dminst & ps_dm_wrb)) begin

		if(ps_ureg1_add[7:4]==4'h0) begin
			ps_rf_dm_rd_add= ps_ureg1_add[3:0];
		end else begin
			ps_rf_dm_rd_add= 4'h0;
		end

		if( (ps_ureg1_add[7:4]==4'b0010) | (ps_ureg1_add==4'b0001) ) begin
			ps_dg_rd_add= ps_ureg1_add[4:0];
		end else begin
			ps_dg_rd_add= 5'b00000;
		end

		if( (ps_ureg1_add[7:4]==4'b0110) | (ps_ureg1_add[7:4]==4'b0111) ) begin
			ps_rd_add= ps_ureg1_add[4:0];
		end else begin
			ps_rd_add= 5'b00000;
		end
	
	end else if(ps_urgtrnsinst) begin
	
		if(ps_ureg2_add[7:4]==4'h0) begin
			ps_rf_dm_rd_add= ps_ureg2_add[3:0];
		end else begin
			ps_rf_dm_rd_add= 4'h0;
		end

		if( (ps_ureg2_add[7:4]==4'b0010) | (ps_ureg2_add==4'b0001) ) begin
			ps_dg_rd_add= ps_ureg2_add[4:0];
		end else begin
			ps_dg_rd_add= 5'b00000;
		end

		if( (ps_ureg2_add[7:4]==4'b0110) | (ps_ureg2_add[7:4]==4'b0111) ) begin
			ps_rd_add= ps_ureg2_add[4:0];
		end else begin
			ps_rd_add= 5'b00000;
		end
		
	end else if(ps_popstck) begin

		ps_rd_add= 5'b00100;
		ps_rf_dm_rd_add= 4'h0;
		ps_dg_rd_add= 5'b00000;
		
	end else begin
		ps_rf_dm_rd_add= 4'h0;
		ps_dg_rd_add= 5'b00000;
		ps_rd_add= 5'b00000;
	end
	
	if( ps_popstck | ps_imminst | ps_urgtrnsinst | ( ps_dminst & !ps_dm_wrb ) ) begin
	
		if(ps_ureg1_add[7:4]==4'h0) begin
			ps_rf_dm_wrt_add= ps_ureg1_add[3:0];
		end else begin
			ps_rf_dm_wrt_add= 4'h0;
		end

	end else begin
		ps_rf_dm_wrt_add<= 4'h0;		
	end
	
end

always@(posedge clk) begin

	if( ps_popstck | ps_imminst | ps_urgtrnsinst | ( ps_dminst & !ps_dm_wrb ) ) begin

		if( (ps_ureg1_add[7:4]==4'b0010) | (ps_ureg1_add[7:4]==4'b0001) ) begin
			ps_dg_wrt_add<= ps_ureg1_add[4:0];
		end else begin
			ps_dg_wrt_add<= 5'b00000;
		end

		if( (ps_ureg1_add[7:4]==4'b0110) | (ps_ureg1_add[7:4]==4'b0111) ) begin
			ps_wrt_add<= ps_ureg1_add[4:0];
		end else begin
			ps_wrt_add<= 5'b00000;
		end

		ps_rf_dm_wrt_en<= (ps_ureg1_add[7:4]==4'h0);
		ps_dg_wrt_en<= ( (ps_ureg1_add[7:4]==4'b0010) | (ps_ureg1_add[7:4]==4'b0001) );
		ps_wrt_en<= (ps_ureg1_add[7:4]==4'b0110) | (ps_ureg1_add[7:4]==4'b0111);

	end else if(ps_pshstck) begin
		ps_wrt_add<= 5'b00100;
		ps_dg_wrt_add<= 5'b00000;
		ps_rf_dm_wrt_en<= 1'b0;
		ps_dg_wrt_en<= 1'b0;
		ps_wrt_en<= 1'b1;	
	end else begin
		ps_dg_wrt_add<= 5'b00000;
		ps_wrt_add<= 5'b00000;
		ps_rf_dm_wrt_en<= 1'b0;
		ps_dg_wrt_en<= 1'b0;
		ps_wrt_en<= 1'b0;	
	end
	
end 

endmodule

