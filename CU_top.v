//6th May 7:36 PM reset added
module cu_top 	#(parameter RF_DATASIZE, ADDRESS_WIDTH, SIGNAL_WIDTH)
		(
			input wire clk, reset,
				
			//Multiplier control signals input from PS
			input wire ps_mul_en, ps_mul_otreg,
			input wire[3:0] ps_mul_dtsts,
			input wire[1:0] ps_mul_cls, ps_mul_sc,

			//Multiplier flags output back to PS
			output wire mul_ps_mv, 
			output wire mul_ps_mn,

			//Crossbar and RF signals
			input wire[(SIGNAL_WIDTH-1):0]ps_xb_w_cuEn,
			input wire ps_xb_w_bcEn,
			input wire[(ADDRESS_WIDTH-1):0] ps_xb_raddx, ps_xb_raddy, ps_xb_wadd,
			input wire [RF_DATASIZE-1:0] bc_dt,
			
			//Crossbar data going to bus connect module
			output wire [RF_DATASIZE-1:0] xb_dtx,	

			//Shifter signals from ps
			input wire ps_shf_en,
			input wire [1:0] ps_shf_cls,

			//Shifter to ps flag signals
			output wire shf_ps_sv, shf_ps_sz,

			//Alu signals from ps
			input wire ps_alu_en, ps_alu_log,
			input wire [1:0]ps_alu_hc,
			input wire [2:0]ps_alu_sc,
			input wire ps_alu_sat,
			
			//ALU flags
			output wire alu_ps_az, alu_ps_an, alu_ps_ac, alu_ps_av
		);

			

	//Crossbar
	wire [RF_DATASIZE-1:0] xb_dty;
	wire xb_rf_w_En;
	wire [RF_DATASIZE-1:0] xb_rf_dt, alu_xb_dt, shf_xb_dt, mul_xb_dt, rf_xb_dtx, rf_xb_dty;
	
	crossbar #(.DATA_WIDTH(RF_DATASIZE), .ADDRESS_WIDTH(ADDRESS_WIDTH), .SIGNAL_WIDTH(SIGNAL_WIDTH)) xb_obj
		(
			ps_xb_w_cuEn, ps_xb_w_bcEn,
			ps_xb_wadd, ps_xb_raddx, ps_xb_raddy,
			bc_dt, alu_xb_dt, shf_xb_dt, mul_xb_dt, rf_xb_dtx, rf_xb_dty,
			xb_dtx, xb_dty, 
			xb_rf_w_En, 
			xb_rf_dt
		);
	

	regfile #(.DATA_WIDTH(RF_DATASIZE), .ADDRESS_WIDTH(ADDRESS_WIDTH), .SIGNAL_WIDTH(SIGNAL_WIDTH)) rf_obj
			( 
				clk, xb_rf_w_En, 
				ps_xb_wadd,  ps_xb_raddx,  ps_xb_raddy,
				xb_rf_dt,
				rf_xb_dtx, rf_xb_dty
			);		

	
	multiplier #(.RF_DATASIZE(RF_DATASIZE)) mul_obj 
			(
				xb_dtx, xb_dty, mul_xb_dt,
				ps_mul_en, ps_mul_otreg,
				ps_mul_dtsts,
				ps_mul_cls, ps_mul_sc,
				clk, reset,
				mul_ps_mv,
				mul_ps_mn
			);	
	
			
	shifter #(.DATASIZE(RF_DATASIZE)) shf_obj
			(
				clk, reset,
				ps_shf_en, ps_shf_cls, 
				xb_dtx, xb_dty, 
				shf_xb_dt, shf_ps_sv, shf_ps_sz
			);

	alu #(.DATA_WIDTH(RF_DATASIZE)) alu_obj
			(
				clk, reset,
				xb_dtx, xb_dty, 
				ps_alu_en, ps_alu_log, ps_alu_hc, ps_alu_sc, 
				alu_xb_dt, 
				ps_alu_sat, 
				alu_ps_az, alu_ps_an, alu_ps_ac, alu_ps_av
			);

endmodule

