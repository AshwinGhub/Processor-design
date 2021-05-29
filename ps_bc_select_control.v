module bc_slct_cntrl(clk,ps_pshstck,ps_popstck,ps_imminst,ps_dminst,ps_urgtrnsinst,ps_dm_wrb,ps_ureg1_add,ps_ureg2_add,ps_bc_drr_slct,ps_bc_di_slct);

input clk,ps_pshstck,ps_popstck,ps_imminst,ps_dminst,ps_urgtrnsinst,ps_dm_wrb;
input[3:0] ps_ureg1_add,ps_ureg2_add;
output[1:0] ps_bc_drr_slct,ps_bc_di_slct;

reg[1:0] ps_di_slct,ps_bc_drr_slct,ps_bc_di_slct;

always @(*) begin

	if(ps_imminst) begin

		ps_di_slct= 2'b10;
		ps_bc_drr_slct= 2'b11;

	end else if(ps_popstck) begin

		ps_di_slct= 2'b01;
		ps_bc_drr_slct= 2'b01;

	end else if(ps_dminst & !ps_dm_wrb) begin

		ps_bc_drr_slct= 2'b11;   
		ps_di_slct= 2'b00;

	end else if((ps_dminst & ps_dm_wrb) | ps_pshstck) begin

		if(ps_ureg1_add==4'h0) begin
			ps_bc_drr_slct= 2'b10;	
		end else if((ps_ureg1_add==4'b0110) | (ps_ureg1_add==4'b0111)) begin
			ps_bc_drr_slct= 2'b01;	
		end else if((ps_ureg1_add==4'b0010) | (ps_ureg1_add==4'b0001)) begin
			ps_bc_drr_slct= 2'b0;
		end else begin
			ps_bc_drr_slct= 2'b11;
		end	
		ps_di_slct= 2'b01;

	end else if(ps_urgtrnsinst) begin
	
		if(ps_ureg2_add==4'h0) begin
			ps_bc_drr_slct= 2'b10;
		end else if((ps_ureg2_add==4'b0110) | (ps_ureg2_add==4'b0111)) begin
			ps_bc_drr_slct= 2'b01;	
		end else if((ps_ureg2_add==4'b0010) | (ps_ureg2_add==4'b0001)) begin
			ps_bc_drr_slct= 2'b0;	
		end else begin
			ps_bc_drr_slct= 2'b11;
		end
		ps_di_slct= 2'b01;

       	end else begin
	
		ps_di_slct= 2'b11;
		ps_bc_drr_slct= 2'b11;

	end

end

always @ (posedge clk) begin

	ps_bc_di_slct<= ps_di_slct;

end

endmodule
