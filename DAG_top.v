//5th May

module iwrt #(parameter ILOC=0) (ps_dg_en,ps_dg_dgsclt,ps_dg_mdfy,ps_dg_wrt_en,ps_dg_iadd,ps_dg_madd,ps_dg_wrt_add,bc_dt,ireg,mreg,dg_wrt_en,dg_dtmxd);

input ps_dg_en,ps_dg_dgsclt,ps_dg_mdfy,ps_dg_wrt_en;
input[2:0] ps_dg_iadd,ps_dg_madd;
input[4:0] ps_dg_wrt_add;
input[15:0] bc_dt;
input[15:0] ireg;
input[15:0] mreg;

output dg_wrt_en;
output[15:0] dg_dtmxd;

reg dg_wrt_en;
reg[15:0] dg_dtmxd;

reg[1:0] cmp;

always@(*) begin

	cmp[0]= ( ({ps_dg_dgsclt,ps_dg_iadd}) == ILOC );
	cmp[1]= ps_dg_wrt_add[4] & ( ps_dg_wrt_add[3:0] == ILOC );

	dg_wrt_en= ( ( cmp[0] & ps_dg_en & ~ps_dg_mdfy ) | ( cmp[1] & ps_dg_wrt_en ) );

	if(ps_dg_wrt_en) begin
		if(cmp[1] & cmp[0]) begin 
			if(ps_dg_en & ~ps_dg_mdfy) begin	
				dg_dtmxd=bc_dt+mreg;
			end else begin
				dg_dtmxd=bc_dt;
			end
		end else if(ps_dg_wrt_add=={1'b0,ps_dg_dgsclt,ps_dg_madd}) begin
			if(ps_dg_en & ~ps_dg_mdfy) begin	
				dg_dtmxd=ireg+bc_dt;
			end else begin
				dg_dtmxd=ireg;
			end
		end else begin
			if(cmp[0] & ps_dg_en & ~ps_dg_mdfy) begin	
				dg_dtmxd=ireg+mreg;
			end else if(cmp[1]) begin
				dg_dtmxd=bc_dt;
			end else begin
				dg_dtmxd=ireg;
			end
		end
	end else if(cmp[0] & ps_dg_en & ~ps_dg_mdfy) begin
		dg_dtmxd=ireg+mreg;
	end else
		dg_dtmxd=ireg;
	
end
	

endmodule

module DAG_top(clk,ps_dg_en,ps_dg_dgsclt,ps_dg_mdfy,dg_dm_add,dg_ps_add,ps_dg_iadd,ps_dg_madd,bc_dt,ps_dg_wrt_en,dg_bc_dt,ps_dg_wrt_add,ps_dg_rd_add);

input clk,ps_dg_en,ps_dg_dgsclt,ps_dg_mdfy,ps_dg_wrt_en;
input[2:0] ps_dg_iadd,ps_dg_madd;
input[4:0] ps_dg_wrt_add,ps_dg_rd_add;
input [15:0] bc_dt;
output [15:0] dg_dm_add,dg_ps_add;
output [15:0] dg_bc_dt;

reg[15:0] i[15:0];
reg[15:0] m[15:0];
reg [15:0] dg_dm_add,dg_ps_add;
reg[15:0] dg_bc_dt,dg_rd_dt;

reg[15:0] iwrt_mreg;

wire[15:0] dg_wrt_en;
wire[15:0] dg_dtmxd[15:0];

integer y;
genvar x;

generate
	for(x=0;x<16;x=x+1) begin : generate_block_identifier
		iwrt #(.ILOC(x)) wrt_comb(ps_dg_en,ps_dg_dgsclt,ps_dg_mdfy,ps_dg_wrt_en,ps_dg_iadd,ps_dg_madd,ps_dg_wrt_add,bc_dt,i[x],iwrt_mreg,dg_wrt_en[x],dg_dtmxd[x]);
	end
endgenerate

always@(*) begin

	iwrt_mreg=m[{ps_dg_dgsclt,ps_dg_madd}];

end

always@(posedge clk) begin

	for(y=0;y<16;y=y+1) begin
		if(dg_wrt_en[y]) begin
			i[y]<=dg_dtmxd[y];
		end
	end
	
	if(ps_dg_wrt_en) begin
		if(~ps_dg_wrt_add[4]) begin
	      		m[ps_dg_wrt_add[3:0]]<=bc_dt;  
  		end
	end

end

always@(*) begin 
	if (ps_dg_wrt_en) begin
		if(ps_dg_wrt_add=={1'b1,ps_dg_dgsclt,ps_dg_iadd}) begin 
			if(ps_dg_en) begin
				if(ps_dg_dgsclt) begin
					if(ps_dg_mdfy) begin
						dg_ps_add=bc_dt+m[ps_dg_madd+4'b1000];
					end else begin
						dg_ps_add=bc_dt;
					end
					dg_dm_add=16'b0;
				end else begin
					if(ps_dg_mdfy) begin
						dg_dm_add=bc_dt+m[ps_dg_madd];
					end
					else begin
						dg_dm_add=bc_dt;
					end
					dg_ps_add=16'b0;
				end 
			end else begin
				dg_ps_add=16'b0;
				dg_dm_add=16'b0;
			end	
		end else if(ps_dg_wrt_add=={1'b0,ps_dg_dgsclt,ps_dg_madd}) begin 
			if(ps_dg_en) begin
				if(ps_dg_dgsclt) begin
					if(ps_dg_mdfy) begin
						dg_ps_add=i[ps_dg_iadd+4'b1000]+bc_dt;
					end else begin
						dg_ps_add=i[ps_dg_iadd+4'b1000];
					end
					dg_dm_add=16'b0;
				end else begin
					if(ps_dg_mdfy) begin
						dg_dm_add=i[ps_dg_iadd]+bc_dt;
					end else begin
						dg_dm_add=i[ps_dg_iadd];
					end
					dg_ps_add=16'b0;
				end 
			end else begin
				dg_ps_add=16'b0;
				dg_dm_add=16'b0;
			end	
		end else begin
			if(ps_dg_en) begin
				if(ps_dg_dgsclt) begin 
					if(ps_dg_mdfy) begin
						dg_ps_add=i[ps_dg_iadd+4'b1000]+m[ps_dg_madd+4'b1000];
					end else begin
						dg_ps_add=i[ps_dg_iadd+4'b1000];
					end
					dg_dm_add=16'b0;
				end else begin
					if(ps_dg_mdfy) begin
						dg_dm_add=i[ps_dg_iadd]+m[ps_dg_madd];
					end else begin
						dg_dm_add=i[ps_dg_iadd];
					end
					dg_ps_add=16'b0;
				end
			end else begin
				dg_ps_add=16'b0;
				dg_dm_add=16'b0;
			end
		end 
	end else begin
		if(ps_dg_en) begin
			if(ps_dg_dgsclt) begin 
				if(ps_dg_mdfy) begin
					dg_ps_add=i[ps_dg_iadd+4'b1000]+m[ps_dg_madd+4'b1000];
				end else begin
					dg_ps_add=i[ps_dg_iadd+4'b1000];
				end
				dg_dm_add=16'b0;
			end else begin
				if(ps_dg_mdfy) begin
					dg_dm_add=i[ps_dg_iadd]+m[ps_dg_madd];
				end else begin
					dg_dm_add=i[ps_dg_iadd];
				end
				dg_ps_add=16'b0;
			end
		end else begin
			dg_ps_add=16'b0;
			dg_dm_add=16'b0;
		end
	end
end

always@(*) begin

	if(ps_dg_rd_add[4]) begin
		dg_rd_dt=i[ps_dg_rd_add[3:0]];
	end else begin
		dg_rd_dt=m[ps_dg_rd_add[3:0]];    
	end

	if( (ps_dg_wrt_add==ps_dg_rd_add) & ps_dg_wrt_en) begin  
		dg_bc_dt=bc_dt;
	end else begin
		dg_bc_dt=dg_rd_dt;
	end

end

endmodule
//End
