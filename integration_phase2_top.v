module phase2_top	#(parameter PMA_SIZE=16, PMD_SIZE=32, DMA_SIZE=16, DMD_SIZE=16, RF_DATASIZE=16, ADDRESS_WIDTH=4, SIGNAL_WIDTH=3)
			(
				input wire clk,
				input wire reset
			);

		
		//Multiplier control signals input from PS
		wire ps_mul_en, ps_mul_otreg;
		wire[3:0] ps_mul_dtsts;
		wire[1:0] ps_mul_cls;

		//Multiplier flags output back to PS
		wire mul_ps_ov, mul_ps_mn;

		//Crossbar and RF signals
		wire[(SIGNAL_WIDTH-1):0]ps_xb_cuEn;
		wire ps_xb_dmEn;
		wire[(ADDRESS_WIDTH-1):0] ps_rf_xA, ps_rf_yA, ps_rf_wrtA;
		wire [RF_DATASIZE-1:0] bc_dt;
		wire [RF_DATASIZE-1:0] rf_bc_dt;

		//Shifter signals from PS
		wire ps_shf_en;
		wire [1:0] ps_shf_cls;

		//Shifter to PS flags
		wire shf_ovflag, shf_zeroflag;

		//ALU signals from PS
		wire ps_alu_en, ps_alu_log;
		wire[1:0] ps_alu_hc;
		wire[2:0] ps_alu_sc;

		//ALU to PS flags
		wire alu_zero, alu_neg, alu_carry, alu_of;


		cu_top #(.RF_DATASIZE(RF_DATASIZE), .ADDRESS_WIDTH(ADDRESS_WIDTH), .SIGNAL_WIDTH(SIGNAL_WIDTH))
			cu_obj	(
					clk,
				
					//Multiplier control signals input from PS
					ps_mul_en, ps_mul_otreg,
					ps_mul_dtsts,
					ps_mul_cls,

					//Multiplier flags output back to PS
					mul_ps_ov,
					mul_ps_mn,

					//Crossbar and RF signals
					ps_xb_cuEn,
					ps_xb_dmEn,
					ps_rf_xA, ps_rf_yA, ps_rf_wrtA,
					bc_dt,

					rf_bc_dt, 

					//Shifter signals from PS
					ps_shf_en,
					ps_shf_cls,
					
					//Shifter to ps flags
					shf_ovflag, shf_zeroflag,

					//Alu signals from ps
					ps_alu_en, ps_alu_log,
					ps_alu_hc,
					ps_alu_sc,
					alu_sat,
			
					//ALU flags
					alu_zero, alu_neg, alu_carry, alu_of
				);

		
		//Memory control signals and data buses
		wire ps_pm_cslt, ps_dm_cslt;
		wire[PMA_SIZE-1:0] ps_pm_add;
		//wire[PMD_SIZE-1:0] pmDataIn; (future scope)
		wire ps_pm_wrb, ps_dm_wrb;
		wire[DMA_SIZE-1:0] dg_dm_add;
		wire[PMD_SIZE-1:0] pm_ps_op;
		wire[DMD_SIZE-1:0] dm_bc_dt;

		memory #(.PMA_SIZE(PMA_SIZE), .PMD_SIZE(PMD_SIZE), .DMA_SIZE(DMA_SIZE), .DMD_SIZE(DMD_SIZE))
			mem_obj	(
					clk,
					ps_pm_cslt, ps_dm_cslt,
					ps_pm_add,
					//pmDataIn,
					ps_pm_wrb, ps_dm_wrb,
					dg_dm_add,
					bc_dt,
					pm_ps_op,
					dm_bc_dt
				);


		wire[1:0] ps_bc_drr_slct, ps_bc_di_slct;
		wire[15:0] dg_bc_dt, ps_bc_dt, ps_bc_immdt;
		wire[15:0] ps_bc_drr_dt;
				
		BC_top  bc_obj
			(
				clk,
				ps_bc_drr_slct, ps_bc_di_slct,
				dm_bc_dt, dg_bc_dt, ps_bc_dt, 
				rf_bc_dt, ps_bc_immdt,
				bc_dt	// dm bus
			);

		
		//DAG
		wire ps_dg_en, ps_dg_dgsclt, ps_dg_mdfy, ps_dg_wrt_en;
		wire [2:0] ps_dg_iadd,ps_dg_madd;
		wire [4:0] ps_dg_wrt_add,ps_dg_rd_add;
		wire [PMA_SIZE-1:0] dg_pm_add;
		
		DAG_top dag_obj
			(
				clk, ps_dg_en, ps_dg_dgsclt, ps_dg_mdfy, 
				dg_dm_add, dg_pm_add, ps_dg_iadd, ps_dg_madd, bc_dt, ps_dg_wrt_en, 
				dg_bc_dt, ps_dg_wrt_add, ps_dg_rd_add
			);
		
		
		PS_top ps_obj
				(
					clk, reset,
					
					//flags
					//shf_ss,shf_sz,shf_sv,
					1'b0,     1'b0, 1'b0,
					mul_ps_ov, mul_ps_mn,
					//alu_as,alu_ac,alu_an,alu_av,alu_az,
					1'b0,     1'b0,   1'b0, 1'b0, 1'b0,


					//pm_ps
					pm_ps_op, 
					
					//bc_ps	
					bc_dt,

					//ps_pm	
					ps_pm_cslt, ps_pm_wrb, ps_pm_add, 

					//ps_cu	
					ps_alu_en, ps_mul_en, ps_shf_en, ps_alu_log, ps_mul_otreg, ps_alu_hc, ps_mul_cls, ps_shf_cls, ps_alu_sc, ps_mul_dtsts, 


					ps_rf_yA, 
					ps_xb_cuEn, //ps_rf_wrt_en, 
					ps_rf_wrtA,  ////ps_rf_mx_wrt_add
					ps_rf_xA, 
					ps_xb_dmEn, //ps_rf_dm_wrt_en, 

					//ps_dg
					ps_dg_wrt_en, ps_dg_rd_add, ps_dg_wrt_add, 
					
					//ps_bc	
					ps_bc_immdt,
					
					//ps_dm
					ps_dm_cslt, ps_dm_wrb, 
					
					//ps_dg
					ps_dg_en, ps_dg_dgsclt, ps_dg_mdfy, ps_dg_iadd, ps_dg_madd, 
					
					//ps_bc
					ps_bc_drr_slct,	ps_bc_di_slct, ps_bc_dt
				);

endmodule