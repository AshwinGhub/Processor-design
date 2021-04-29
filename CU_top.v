module cu_top 	#(parameter RF_DATASIZE, ADDRESS_WIDTH, SIGNAL_WIDTH)
		(
			input wire clk,
				
			//Multiplier control signals input from PS
			input wire ps_mul_en, ps_mul_otreg,
			input wire[3:0] ps_mul_dtsts,
			input wire[1:0] ps_mul_cls,

			//Multiplier flags output back to PS
			output wire mul_ps_ov, 
			output wire mul_ps_mn,

			//Crossbar and RF signals
			input wire[(SIGNAL_WIDTH-1):0]ps_xb_cuEn,
			input wire ps_xb_dmEn,
			input wire[(ADDRESS_WIDTH-1):0] ps_rf_xA, ps_rf_yA, ps_rf_wrtA,
			input wire [RF_DATASIZE-1:0] dm_xb_dmD,

			output wire [RF_DATASIZE-1:0] xb_cu_rx,	

			//Shifter signals from ps
			input wire ps_shf_en,
			input wire [1:0] ps_shf_cls,

			//Shifter to ps flag signals
			output wire shf_ovflag, shf_zeroflag
		);

			

	//Crossbar
	wire [RF_DATASIZE-1:0] xb_cu_ry;
	wire xb_rf_En;
	wire [RF_DATASIZE-1:0] xb_rf_d, alu_xb_rn, shf_xb_rn, mul_xb_rn, rf_xb_rx, rf_xb_ry;
	
	crossbar #(.DATA_WIDTH(RF_DATASIZE), .ADDRESS_WIDTH(ADDRESS_WIDTH), .SIGNAL_WIDTH(SIGNAL_WIDTH)) xb_obj
		(
			ps_xb_cuEn, ps_xb_dmEn,
			ps_rf_xA, ps_rf_yA, ps_rf_wrtA,
			dm_xb_dmD, alu_xb_rn, shf_xb_rn, mul_xb_rn, rf_xb_rx, rf_xb_ry,
			xb_cu_rx, xb_cu_ry, 
			xb_rf_En, 
			xb_rf_d
		);
	

	regfile #(.DATA_WIDTH(RF_DATASIZE), .ADDRESS_WIDTH(ADDRESS_WIDTH), .SIGNAL_WIDTH(SIGNAL_WIDTH)) rf_obj
			( 
				clk, xb_rf_En, 
				ps_rf_wrtA,  ps_rf_xA,  ps_rf_yA,
				xb_rf_d,
				rf_xb_rx, rf_xb_ry
			);		

	
	multiplier #(.RF_DATASIZE(RF_DATASIZE)) mul_obj 
			(
				xb_cu_rx, xb_cu_ry, mul_xb_rn,
				ps_mul_en, ps_mul_otreg,
				ps_mul_dtsts,
				ps_mul_cls,
				clk,
				mul_ps_ov,
				mul_ps_mn
			);	
	
			
	shifter #(.DATASIZE(RF_DATASIZE)) shf_obj
			(
				clk, 
				ps_shf_en, ps_shf_cls, 
				xb_cu_rx, xb_cu_ry, 
				shf_xb_rn, shf_ovflag, shf_zeroflag
			);

endmodule

