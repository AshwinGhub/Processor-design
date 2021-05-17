// 7th may 12:46AM reset port added to mem_top
module   core_top	#(parameter PMA_SIZE, PMD_SIZE, DMA_SIZE, DMD_SIZE, RF_DATASIZE, ADDRESS_WIDTH, SIGNAL_WIDTH, PM_LOCATE, DM_LOCATE)
			(
				input wire clk,
				input wire reset,
				input wire interrupt
			);

		
		//Multiplier control signals input from PS
		wire ps_mul_en, ps_mul_otreg;
		wire[3:0] ps_mul_dtsts;
		wire[1:0] ps_mul_cls, ps_mul_sc;

		//Multiplier flags output back to PS
		wire mul_ps_mv, mul_ps_mn;

		//Crossbar and RF signals
		wire[(SIGNAL_WIDTH-1):0]ps_xb_w_cuEn;
		wire ps_xb_w_bcEn;
		wire[(ADDRESS_WIDTH-1):0] ps_xb_raddx, ps_xb_raddy, ps_xb_wadd;
		wire [RF_DATASIZE-1:0] bc_dt;
		wire [RF_DATASIZE-1:0] xb_dtx;

		//Shifter signals from PS
		wire ps_shf_en;
		wire [1:0] ps_shf_cls;

		//Shifter to PS flags
		wire shf_ps_sv, shf_ps_sz;

		//ALU signals from PS
		wire ps_alu_en, ps_alu_log;
		wire[1:0] ps_alu_hc;
		wire[2:0] ps_alu_sc;

		//ALU to PS flags
		wire alu_ps_az, alu_ps_an, alu_ps_ac, alu_ps_av;


		cu_top #(.RF_DATASIZE(RF_DATASIZE), .ADDRESS_WIDTH(ADDRESS_WIDTH), .SIGNAL_WIDTH(SIGNAL_WIDTH))
			cu_obj	(
					clk, reset,
				
					//Multiplier control signals input from PS
					ps_mul_en, ps_mul_otreg,
					ps_mul_dtsts,
					ps_mul_cls, 2'b11, //ps_mul_sc,

					//Multiplier flags output back to PS
					mul_ps_mv,
					mul_ps_mn,

					//Crossbar and RF signals
					ps_xb_w_cuEn,
					ps_xb_w_bcEn,
					ps_xb_raddx, ps_xb_raddy, ps_xb_wadd,
					bc_dt,

					xb_dtx, 

					//Shifter signals from PS
					ps_shf_en,
					ps_shf_cls,
					
					//Shifter to ps flags
					shf_ps_sv, shf_ps_sz,

					//Alu signals from ps
					ps_alu_en, ps_alu_log,
					ps_alu_hc,
					ps_alu_sc,
					ps_alu_sat,
			
					//ALU flags
					alu_ps_az, alu_ps_an, alu_ps_ac, alu_ps_av
				);

		
		//Memory control signals and data buses
		wire ps_pm_cslt, ps_dm_cslt;
		wire[PMA_SIZE-1:0] ps_pm_add;
		//wire[PMD_SIZE-1:0] pmDataIn; (future scope)
		wire ps_pm_wrb, ps_dm_wrb;
		wire[DMA_SIZE-1:0] dg_dm_add;
		wire[PMD_SIZE-1:0] pm_ps_op;
		wire[DMD_SIZE-1:0] dm_bc_dt;

		memory #(.PMA_SIZE(PMA_SIZE), .PMD_SIZE(PMD_SIZE), .DMA_SIZE(DMA_SIZE), .DMD_SIZE(DMD_SIZE), .PM_LOCATE(PM_LOCATE), .DM_LOCATE(DM_LOCATE))
			mem_obj	(
					clk, reset,
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
				xb_dtx, ps_bc_immdt,
				bc_dt	
			);

		
		//DAG
		wire ps_dg_en, ps_dg_dgsclt, ps_dg_mdfy, ps_dg_wrt_en;
		wire [2:0] ps_dg_iadd,ps_dg_madd;
		wire [4:0] ps_dg_wrt_add,ps_dg_rd_add;
		wire [PMA_SIZE-1:0] dg_ps_add;
		
		DAG_top dag_obj
			(
				clk, ps_dg_en, ps_dg_dgsclt, ps_dg_mdfy, 
				dg_dm_add, dg_ps_add, ps_dg_iadd, ps_dg_madd, bc_dt, ps_dg_wrt_en, 
				dg_bc_dt, ps_dg_wrt_add, ps_dg_rd_add
			);
		
		
		PS_top ps_obj
				(
					clk, reset,interrupt,
					
					//flags
					shf_ps_sz , shf_ps_sv,
					mul_ps_mv, mul_ps_mn,
					alu_ps_ac , alu_ps_an , alu_ps_av , alu_ps_az,


					//pm_ps
					pm_ps_op, 
					
					//bc_ps	
					bc_dt,

					//ps_pm	
					ps_pm_cslt, ps_pm_wrb, ps_pm_add, 

					//ps_cu	
					ps_alu_en, ps_mul_en, ps_shf_en, ps_alu_log, ps_mul_otreg, ps_alu_hc, ps_mul_cls, ps_mul_sc, ps_shf_cls, ps_alu_sc, ps_mul_dtsts, 


					ps_xb_raddy, 
					ps_xb_w_cuEn, //ps_rf_wrt_en, 
					ps_xb_wadd,  ////ps_rf_mx_wrt_add
					ps_xb_raddx, 
					ps_xb_w_bcEn, //ps_rf_dm_wrt_en, 

					//ps_dg
					ps_dg_wrt_en, ps_dg_rd_add, ps_dg_wrt_add, 
					
					//ps_bc	
					ps_bc_immdt,
					
					//ps_dm
					ps_dm_cslt, ps_dm_wrb, 
					
					//ps_dg
					ps_dg_en, ps_dg_dgsclt, ps_dg_mdfy, ps_dg_iadd, ps_dg_madd, 
					
					//ps_bc
					ps_bc_drr_slct,	ps_bc_di_slct, ps_bc_dt,

					dg_ps_add
				);

endmodule
