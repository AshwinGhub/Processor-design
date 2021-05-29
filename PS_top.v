//2nd may
module PS_top (clk,rst,interrupt,shf_ps_sz,shf_ps_sv,mul_ps_mv,mul_ps_mn,alu_ps_ac,alu_ps_an,alu_ps_av,alu_ps_az,pm_ps_op,bc_dt,ps_pm_cslt,ps_pm_wrb,ps_pm_add,ps_alu_en,ps_mul_en,ps_shf_en,ps_alu_log,ps_mul_otreg,ps_alu_hc,ps_mul_cls,ps_mul_sc,ps_shf_cls,ps_alu_sc,ps_mul_dtsts,ps_xb_raddy,ps_xb_w_cuEn,ps_xb_wadd,ps_xb_raddx,ps_xb_w_bcEn,ps_dg_wrt_en,ps_dg_rd_add,ps_dg_wrt_add,ps_bc_immdt,ps_dm_cslt,ps_dm_wrb,ps_dg_en,ps_dg_dgsclt,ps_dg_mdfy,ps_dg_iadd,ps_dg_madd,ps_bc_drr_slct,ps_bc_di_slct,ps_bc_dt,dg_ps_add);


input clk,rst,interrupt;
input shf_ps_sz,shf_ps_sv,mul_ps_mv,mul_ps_mn,alu_ps_ac,alu_ps_an,alu_ps_av,alu_ps_az; 
input[31:0] pm_ps_op;
input[15:0] bc_dt;
input[15:0] dg_ps_add;
output ps_pm_cslt,ps_pm_wrb;
output [15:0] ps_pm_add;
output ps_alu_en, ps_mul_en, ps_shf_en, ps_alu_log, ps_mul_otreg;
output[1:0] ps_alu_hc, ps_mul_cls, ps_mul_sc, ps_shf_cls;
output[2:0] ps_alu_sc;
output[3:0] ps_mul_dtsts, ps_xb_raddy;                       
output[2:0] ps_xb_w_cuEn;
output[3:0] ps_xb_wadd;
output[3:0] ps_xb_raddx;
output ps_xb_w_bcEn,ps_dg_wrt_en;
output[4:0] ps_dg_rd_add,ps_dg_wrt_add;
output[15:0] ps_bc_immdt;
output ps_dm_cslt,ps_dm_wrb;
output ps_dg_en,ps_dg_dgsclt,ps_dg_mdfy;
output[2:0] ps_dg_iadd,ps_dg_madd;
output[1:0] ps_bc_drr_slct,ps_bc_di_slct;
output[15:0] ps_bc_dt;


integer i;


//Internal Sginals
reg cnd_tru, ps_idle,ps_pcstck_pntr,ps_mode1;
reg[15:0] ps_faddr,ps_daddr,ps_pc;
reg[15:0] dg_ps_add_dly;
reg[15:0] ps_astat;						//ASTAT work left -> compare
reg[15:0] ps_pcstck[1:0];
reg[2:0] ps_stcky;
reg ps_pshstck_dly,ps_popstck_dly;
reg[15:0] ps_rd_dt;
reg ps_cmpt_dly;
reg ps_jmp,ps_jmp_dly;
reg ps_call,ps_rtrn,ps_rtrn_dly;

//Used for compute decoding
reg cpt_en;
reg [20:0] bt_5t25;

wire ps_alu_en, ps_mul_en, ps_shf_en, ps_alu_log, ps_mul_otreg;
wire[1:0] ps_alu_hc, ps_mul_cls, ps_mul_sc, ps_shf_cls;
wire[2:0] ps_alu_sc;
wire[3:0] ps_mul_dtsts, ps_xb_rd_a0, ps_xb_raddy;
wire[2:0] ps_xb_w_cuEn;
wire[3:0] ps_xb_wrt_a;

//Used for condition decoding
reg cnd_en;
reg[4:0] opc_cnd;
reg[7:0] astat_bts;

wire cnd_stat;

//Used for Ureg address decoding
reg ps_pshstck,ps_popstck,ps_imminst,ps_dminst,ps_urgtrnsinst;
reg[7:0] ps_ureg1_add,ps_ureg2_add;

wire ps_xb_w_bcEn,ps_dg_wrt_en,ps_wrt_en;
wire[3:0] ps_xb_dm_rd_add, ps_xb_dm_wrt_add;
wire[4:0] ps_dg_rd_add,ps_rd_add,ps_dg_wrt_add,ps_wrt_add;

//Used for memory
reg ps_pm_cslt,ps_pm_wrb;
reg ps_dm_cslt,ps_dm_wrb;
reg [15:0] ps_pm_add;

//Used for RF specifically
reg[3:0] ps_xb_raddx;
reg[3:0] ps_xb_wadd;

//Used for bus connect
reg[15:0] ps_bc_immdt,ps_bc_dt;

wire[1:0] ps_bc_drr_slct,ps_bc_di_slct;

//Used for DAG
reg ps_dg_en,ps_dg_dgsclt,ps_dg_mdfy;
reg[2:0] ps_dg_iadd,ps_dg_madd;


//Compute Decoing hardware
cmpt_inst_dcdr cpt(clk,rst,cpt_en,bt_5t25, ps_alu_en,ps_mul_en, ps_shf_en, ps_alu_log, ps_mul_otreg, ps_alu_hc, ps_mul_cls, ps_mul_sc, ps_shf_cls, ps_alu_sc, ps_xb_w_cuEn,ps_mul_dtsts, ps_xb_rd_a0, ps_xb_raddy, ps_xb_wrt_a);

//Condition decoding hardware
cnd_dcdr cnd(cnd_en,opc_cnd,cnd_stat,astat_bts);

//Ureg related decoding hardware
ureg_add_dcdr urdcd(clk,ps_pshstck,ps_popstck,ps_imminst,ps_dminst,ps_urgtrnsinst,ps_dm_wrb,ps_ureg1_add,ps_ureg2_add,ps_xb_w_bcEn,ps_dg_wrt_en,ps_wrt_en,ps_xb_dm_rd_add,ps_xb_dm_wrt_add,ps_dg_rd_add,ps_rd_add,ps_dg_wrt_add,ps_wrt_add);

//Bus connect selection logic
bc_slct_cntrl bsc(clk,ps_pshstck,ps_popstck,ps_imminst,ps_dminst,ps_urgtrnsinst,ps_dm_wrb,ps_ureg1_add[7:4],ps_ureg2_add[7:4],ps_bc_drr_slct,ps_bc_di_slct);


always @ (posedge clk or negedge rst) begin 
	
	if(!rst) begin
		ps_faddr <=16'b0;
		ps_call <= 1'b0;
		ps_rtrn <= 1'b0;
		ps_rtrn_dly <= 1'b0;
		ps_jmp <= 1'b0;
		ps_jmp_dly <= 1'b0;
	end else begin

		ps_call<=pm_ps_op[28] & pm_ps_op[26] & cnd_tru;
		ps_rtrn<=(pm_ps_op[31:24]==8'b1) & cnd_tru;
		ps_rtrn_dly<= ps_rtrn;
		ps_jmp<=pm_ps_op[28] & cnd_tru;
		ps_jmp_dly<=ps_jmp;

		if(ps_jmp) begin
			ps_faddr<=dg_ps_add_dly;
		end else if(ps_rtrn) begin
			if(ps_pcstck_pntr)
				ps_faddr<= ps_pcstck[ps_pcstck_pntr-1'b1];
			else
				ps_faddr<= ps_pcstck[ps_pcstck_pntr];
		end else if(!ps_idle) begin
			ps_faddr <= ps_faddr + 16'b1;
		end

	end

end

always@(posedge clk) begin

	dg_ps_add_dly<=dg_ps_add;

	if(!ps_idle) begin
		ps_daddr <= ps_faddr;
		ps_pc <= ps_daddr;
	end

	//RF write address muxing
	if(cpt_en) begin
		ps_xb_wadd<= ps_xb_wrt_a;
	end else begin
		ps_xb_wadd<= ps_xb_dm_wrt_add;
	end

	//Immediate data
	if(ps_imminst) begin
		ps_bc_immdt<=pm_ps_op[15:0];
	end

end		

always @(*) begin

	//Conditional decoding
	opc_cnd= pm_ps_op[4:0];
	cnd_en= pm_ps_op[31];
	astat_bts= { shf_ps_sz, shf_ps_sv, mul_ps_mv, mul_ps_mn, alu_ps_ac, alu_ps_an, alu_ps_av, alu_ps_az };   		//ASTAT bits given to condition checking module
	cnd_tru= ( cnd_stat | !pm_ps_op[31] ) & !ps_idle & !ps_jmp & !ps_jmp_dly & !ps_rtrn & !ps_rtrn_dly;

	//Instruction Identification
	if(!pm_ps_op[30] & !ps_idle & !ps_jmp & !ps_jmp_dly & !ps_rtrn & !ps_rtrn_dly) begin
		ps_pshstck= (pm_ps_op[29:24]==6'b000010);                       //Push PCstck inst
		ps_popstck= (pm_ps_op[29:24]==6'b000011);			//Pop PCstack inst
		ps_imminst= (pm_ps_op[29:26]==4'b0011);				//Immediate Inst
		ps_dminst= (pm_ps_op[29:26]==4'b1001) & cnd_tru;		//DM<->ureg inst
		ps_urgtrnsinst= (pm_ps_op[29:26]==4'b0001) & cnd_tru;		//Between Ureg inst
	end else begin
		ps_pshstck= 1'b0;
		ps_popstck= 1'b0;
		ps_imminst= 1'b0;
		ps_dminst= 1'b0;
		ps_urgtrnsinst= 1'b0;
	end

	//Compute decoding
	cpt_en= pm_ps_op[30] & cnd_tru;
	bt_5t25= pm_ps_op[25:5];

	//DM
	ps_dm_cslt= ps_dminst;
	ps_dm_wrb= pm_ps_op[6];

	//PM
	ps_pm_add= ps_faddr;
	ps_pm_cslt= !ps_idle;
	ps_pm_wrb=1'b0;

	//DAG decoding
	ps_dg_en= pm_ps_op[29] & cnd_tru;
	ps_dg_dgsclt= pm_ps_op[28];
	ps_dg_mdfy= pm_ps_op[28];
	ps_dg_iadd= pm_ps_op[12:10];
	ps_dg_madd= pm_ps_op[9:7];

	//Ureg Addresses
	ps_ureg1_add= pm_ps_op[23:16];
	ps_ureg2_add= pm_ps_op[15:8];

	//RF read address muxing
	if(cpt_en) begin
		ps_xb_raddx= ps_xb_rd_a0;	
	end else begin
		ps_xb_raddx= ps_xb_dm_rd_add;
	end

	//Read from ps registers to bus connect
	if(ps_rd_add== 5'b00000)
		ps_rd_dt= ps_faddr;
	else if(ps_rd_add== 5'b00001)
		ps_rd_dt= ps_daddr;	
	else if(ps_rd_add== 5'b00011)
		ps_rd_dt= ps_pc;
	else if(ps_rd_add== 5'b00100) begin					//PCSTCK 
		if(ps_pcstck_pntr)
			ps_rd_dt= ps_pcstck[ps_pcstck_pntr-1'b1];
		else
			ps_rd_dt= ps_pcstck[ps_pcstck_pntr];
	end else if(ps_rd_add== 5'b00101)
		ps_rd_dt= {15'b0,ps_pcstck_pntr};
	else if(ps_rd_add== 5'b11011)
		ps_rd_dt= {15'b0,ps_mode1};
	else if(ps_rd_add== 5'b11100)
		ps_rd_dt= ps_astat;
	else if(ps_rd_add== 5'b11110)
		ps_rd_dt= {13'b0,ps_stcky};
	else 
		ps_rd_dt= 16'b0;

	//Bypass (Consider if there are changes in pcstkp and stcky bypass after including jump instructions)
	if(ps_wrt_add==ps_rd_add) begin
		if(ps_rd_add== 5'b11011)
			ps_bc_dt= {15'b0,bc_dt[0]};
		else
			ps_bc_dt= bc_dt;
	end else if( (ps_rd_add==5'b00101) & (ps_pshstck_dly | ps_popstck_dly) )
		ps_bc_dt= {15'b0,ps_pshstck_dly};
	else if( (ps_rd_add==5'b11110) & (ps_pshstck_dly | ps_popstck_dly) )
		ps_bc_dt= {13'b0, (ps_stcky[1] & ps_pshstck_dly) ,ps_pshstck_dly, ps_popstck_dly};
	else if( (ps_rd_add== 5'b11100) & ps_cmpt_dly )
		ps_bc_dt=  { /*ps_astat[15:8] */ 8'b0 , shf_ps_sz, shf_ps_sv, mul_ps_mv, mul_ps_mn, alu_ps_ac, alu_ps_an, alu_ps_av, alu_ps_az };
	else
		ps_bc_dt= ps_rd_dt;

end

//PC stackpntr and sticky registers
always@(posedge clk or negedge rst) begin					//For the time being, a write using ureg to either pcstck pntr or sticky reg is not promoted and is invalid due to accompanied possible complications

	if(!rst) begin

		ps_stcky<=3'b001;						//ps_stcky[0] -> empty flag, ps_stcky[1] -> full flag, ps_stcky[2] -> pc sctack overflow
		ps_pcstck_pntr<= 1'b0;
		ps_pshstck_dly<= 1'b0;
		ps_popstck_dly<= 1'b0;

	end else begin

		ps_pshstck_dly<= ps_pshstck;
		ps_popstck_dly<= ps_popstck;

		if( (ps_popstck_dly | ps_rtrn) & !ps_stcky[0]) begin	
			ps_pcstck_pntr<=ps_pcstck_pntr-1'b1;
		end else if( (ps_pshstck_dly | ps_call) & !ps_stcky[1]) begin
			ps_pcstck_pntr<=ps_pcstck_pntr+1'b1;
		end

		ps_stcky[0]<= (ps_stcky[1] & (ps_popstck_dly | ps_rtrn)) | (ps_stcky[0] & !(ps_pshstck_dly | ps_call));
		ps_stcky[1]<= (ps_stcky[0] & (ps_pshstck_dly | ps_call)) | (ps_stcky[1] & !(ps_popstck_dly | ps_rtrn));
		ps_stcky[2]<= ps_stcky[1] & (ps_pshstck_dly | ps_call);

	end

end

always@(posedge clk or negedge rst) begin

	if(!rst) begin

		ps_cmpt_dly<=1'b0;
		ps_idle<=1'b0;

	end else begin

		ps_cmpt_dly<=cpt_en;
	
		//Idle
		ps_idle<= ( ( (pm_ps_op[31:23]==9'd1) & !ps_idle ) | ( !interrupt & ps_idle ) ) & !ps_jmp & !ps_jmp_dly & !ps_rtrn & !ps_rtrn_dly;

	end

end

//Internal Registers - ASTAT, MODE1, PCSTK
always@(posedge clk or negedge rst) begin

	if(!rst) begin

		ps_astat<=16'h0;
		ps_mode1<= 1'b0;
		for (i=0; i<=1; i=i+1) begin
			ps_pcstck[i]<= 16'b0;		
		end
     
	end else begin

		//ASTAT 
		if( (ps_wrt_add==5'b11100) & ps_wrt_en ) begin
	       		ps_astat<= bc_dt;
		end else begin
	       		ps_astat<= { 8'b0 , shf_ps_sz, shf_ps_sv, mul_ps_mv, mul_ps_mn, alu_ps_ac, alu_ps_an, alu_ps_av, alu_ps_az };     //Update 6'b0 with compare logic later on	 
		end

	       	//ps_mode1 writing
		if( (ps_wrt_add==5'b11011) & ps_wrt_en ) begin
	       		ps_mode1<= bc_dt[0];	
		end

		//PC stck writing
		if( ( (ps_wrt_add==5'b00100) & ps_wrt_en ) | ps_call) begin
			if(ps_call) begin
				ps_pcstck[ps_pcstck_pntr]<= ps_daddr;	
			end else if(ps_pshstck_dly) begin
				ps_pcstck[ps_pcstck_pntr]<= bc_dt;
			end else begin
				if(ps_pcstck_pntr) begin
					ps_pcstck[ps_pcstck_pntr-1'b1]<= bc_dt;
				end else begin
					ps_pcstck[ps_pcstck_pntr]<= bc_dt;
				end
			end
		end
	end

end

endmodule
