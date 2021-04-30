module DAG_top (clk,ps_dg_en,ps_dg_dgsclt,ps_dg_mdfy,dg_dm_add,dg_pm_add,ps_dg_iadd,ps_dg_madd,bc_dt_out,ps_dg_wrt_en,dg_bc_dt,ps_dg_wrt_add,ps_dg_rd_add);

input clk,ps_dg_en,ps_dg_dgsclt,ps_dg_mdfy,ps_dg_wrt_en;
input[2:0] ps_dg_iadd,ps_dg_madd;
input[4:0] ps_dg_wrt_add,ps_dg_rd_add;
input [15:0] bc_dt_out;
output [15:0] dg_dm_add,dg_pm_add;
output [15:0] dg_bc_dt;

reg[15:0] i[15:0];
reg[15:0] m[15:0];
reg [15:0] dg_dm_add,dg_pm_add;
reg[15:0] dg_bc_dt,dg_rd_dt;


always@(posedge clk)
begin
	if (ps_dg_wrt_en) begin
		if(ps_dg_wrt_add=={1'b1,ps_dg_dgsclt,ps_dg_iadd}) begin 
			if(ps_dg_en & ~ps_dg_mdfy) begin
				if(ps_dg_dgsclt) begin
					i[ps_dg_iadd+4'b1000]<=bc_dt_out+m[ps_dg_madd+4'b1000];
				end
				else begin
					i[ps_dg_iadd]<=bc_dt_out+m[ps_dg_madd];
				end
			end else begin
				if(ps_dg_wrt_add[4]) begin
					i[ps_dg_wrt_add[3:0]]<=bc_dt_out;
				end
			end
		end else if(ps_dg_wrt_add=={1'b0,ps_dg_dgsclt,ps_dg_madd}) begin
			if(ps_dg_en & ~ps_dg_mdfy) begin
				if(ps_dg_dgsclt) begin
					i[ps_dg_iadd+4'b1000]<=i[ps_dg_iadd+4'b1000]+bc_dt_out;
				end
				else begin
					i[ps_dg_iadd]<=i[ps_dg_iadd]+bc_dt_out;
				end
			end else begin
				if(ps_dg_wrt_add[4]) begin
					i[ps_dg_wrt_add[3:0]]<=bc_dt_out;
				end
			end
		end else begin
			if(ps_dg_wrt_add[4]) begin
				i[ps_dg_wrt_add[3:0]]<=bc_dt_out;
			end	
			if(ps_dg_en & ~ps_dg_mdfy) begin
				if(ps_dg_dgsclt) begin
					i[ps_dg_iadd+4'b1000]<=i[ps_dg_iadd+4'b1000]+m[ps_dg_madd+4'b1000];
				end else begin
					i[ps_dg_iadd]<=i[ps_dg_iadd]+m[ps_dg_madd];
				end
			end
		end
	end 
	else if(ps_dg_en & ~ps_dg_mdfy) 
	begin
		if(ps_dg_dgsclt)
		begin
			i[ps_dg_iadd+4'b1000]<=i[ps_dg_iadd+4'b1000]+m[ps_dg_madd+4'b1000];
		end 
		else 
		begin
			i[ps_dg_iadd]<=i[ps_dg_iadd]+m[ps_dg_madd];
		end
	end

	if(ps_dg_wrt_en) 
	begin
		if(~ps_dg_wrt_add[4]) 
		begin
	      		m[ps_dg_wrt_add[3:0]]<=bc_dt_out;  
  		end
	end
end

always@(*) begin 
	if(ps_dg_en) begin
		if(ps_dg_dgsclt) begin 
			if(ps_dg_mdfy) begin
				dg_pm_add=i[ps_dg_iadd+4'b1000]+m[ps_dg_madd+4'b1000];
			end else begin
				dg_pm_add=i[ps_dg_iadd+4'b1000];
			end
		end else begin
			if(ps_dg_mdfy) begin
				dg_dm_add=i[ps_dg_iadd]+m[ps_dg_madd];
			end
			else begin
				dg_dm_add=i[ps_dg_iadd];
			end
		end
	end else begin
		dg_pm_add=16'b0;
		dg_dm_add=16'b0;
	end
end

always@(*) begin

	if(ps_dg_rd_add[4]) begin
		dg_rd_dt=i[ps_dg_rd_add[3:0]];
	end else begin
		dg_rd_dt=m[ps_dg_rd_add[3:0]];    
	end

	if(ps_dg_wrt_add==ps_dg_rd_add) begin  
		dg_bc_dt=bc_dt_out;
	end else begin
		dg_bc_dt=dg_rd_dt;
	end

end

endmodule

