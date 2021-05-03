//@nd May
module BC_top(clk,ps_bc_drr_sclt, ps_bc_di_sclt,dm_bc_dt, dg_bc_dt, ps_bc_dt, xb_dtx, ps_bc_immdt,bc_dt);

input clk;
input[1:0] ps_bc_drr_sclt, ps_bc_di_sclt;
input[15:0] dm_bc_dt, dg_bc_dt, ps_bc_dt, xb_dtx, ps_bc_immdt;
output[15:0] bc_dt;

  
reg[15:0] bc_dt,ps_bc_drr_dt,bc_pdrdt;
  

always @(*) begin

	if(ps_bc_drr_sclt== 2'b0)
		ps_bc_drr_dt= dg_bc_dt;
	else if(ps_bc_drr_sclt== 2'b01)
		ps_bc_drr_dt= ps_bc_dt;
	else if(ps_bc_drr_sclt== 2'b10)
		ps_bc_drr_dt= xb_dtx;
	else
		ps_bc_drr_dt= 16'b0;

end

always @ (posedge clk) begin

	bc_pdrdt<= ps_bc_drr_dt;

end

always @(*) begin
	
	if(ps_bc_di_sclt== 2'b0)
		bc_dt= dm_bc_dt;
	else if(ps_bc_di_sclt== 2'b01)
		bc_dt= bc_pdrdt;
	else if(ps_bc_di_sclt== 2'b10)
		bc_dt= ps_bc_immdt;
	else
		bc_dt= 16'b0;

end

endmodule
