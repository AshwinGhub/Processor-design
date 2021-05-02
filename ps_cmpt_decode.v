module cmpt_inst_dcdr(clk,rst,cpt_en,bt_5t25, ps_alu_en,ps_mul_en, ps_shf_en, ps_alu_log, ps_mul_otreg, ps_alu_hc, ps_mul_cls, ps_shf_cls, ps_alu_sc, ps_xb_w_cuEn,ps_mul_dtsts, ps_xb_rd_a0, ps_xb_raddy, ps_xb_wrt_a);

parameter wrt=16;

input clk,rst,cpt_en;
input[20:0] bt_5t25;

output ps_alu_en, ps_mul_en, ps_shf_en, ps_alu_log, ps_mul_otreg;
output[1:0] ps_alu_hc, ps_mul_cls, ps_shf_cls;
output[2:0] ps_alu_sc, ps_xb_w_cuEn;
output[3:0] ps_mul_dtsts, ps_xb_rd_a0, ps_xb_raddy, ps_xb_wrt_a;

reg ps_alu_en, ps_mul_en, ps_shf_en, ps_alu_log, ps_mul_otreg;
reg[1:0] ps_alu_hc, ps_mul_cls, ps_shf_cls;
reg[2:0] ps_alu_sc,wrt_en;
reg[3:0] ps_mul_dtsts, ps_xb_rd_a0, ps_xb_raddy;

reg[2:0] ps_xb_w_cuEn;
reg[3:0] ps_xb_wrt_a;

//CU Enables
always @* begin

	ps_alu_en= !bt_5t25[20] & !bt_5t25[19] & cpt_en;           //ALU enable
	ps_mul_en= !bt_5t25[20] & bt_5t25[19] & cpt_en;		   //MUL enable
        ps_shf_en= bt_5t25[20] & !bt_5t25[19] & cpt_en;		   //Shifter enable

end

//ALU Control Signals
always @* begin

	if(ps_alu_en) begin

		ps_alu_log= bt_5t25[17];                          //High for logical, low for arithematic
		ps_alu_hc= bt_5t25[16:15];			  //Higher Classification bits
		ps_alu_sc= bt_5t25[14:12];			  //Sub Classification bits

	end else begin

		ps_alu_log= 1'b0;
		ps_alu_hc= 2'b0;
		ps_alu_sc= 3'b0;

	end

end

//Multiplier 
always @(*) begin

	if(ps_mul_en) begin

		ps_mul_cls= bt_5t25[18:17];			  //Classification bits
		ps_mul_otreg= bt_5t25[16];			  //Output reg selection bit - High for MRF, Low for Rn
		ps_mul_dtsts = bt_5t25[15:12];			  //Data status

	end else begin

		ps_mul_cls= 2'b0;
		ps_mul_otreg= 1'b0;
		ps_mul_dtsts = 4'b0;

	end

end

//Shifter
always @* begin

	if(ps_shf_en) begin

		ps_shf_cls= bt_5t25[16:15];			  //Classification bits

	end else begin

		ps_shf_cls= 2'b0;

	end

end

//Register File
always @(*) begin
			
	wrt_en[0]= ps_alu_en & !bt_5t25[14];
	wrt_en[1]= ps_mul_en & !bt_5t25[16];
	wrt_en[2]= ps_shf_en;
	
	if( ps_alu_en | (ps_mul_en & (|bt_5t25[18:17])) | ps_shf_en ) begin

		ps_xb_rd_a0= bt_5t25[7:4];          //Input 1 read Address 
		
	end else begin

		ps_xb_rd_a0= 4'h0;

	end

	if( (ps_alu_en & !bt_5t25[16]) | (ps_mul_en & (|bt_5t25[18:17])) | (ps_shf_en & !bt_5t25[16]) ) begin

		ps_xb_raddy= bt_5t25[3:0];           //Input 2 read Address

	end else begin

		ps_xb_raddy= 4'h0;

	end

	if(|wrt_en) begin
				
		ps_xb_wrt_a= bt_5t25[11:8];        //Write address
		
	end else begin
		
		ps_xb_wrt_a= 4'h0;
	
	end

end

//Regiter File Write
always @(posedge clk or negedge rst) begin

	if(!rst) begin

		ps_xb_w_cuEn<= 3'b0;

	end else begin
	
		ps_xb_w_cuEn[0]<= wrt_en[0];                //Write enable for ALU
		ps_xb_w_cuEn[1]<= wrt_en[1];		    //for MUL
		ps_xb_w_cuEn[2]<= wrt_en[2];		    //for Shifter


	end

end

endmodule










