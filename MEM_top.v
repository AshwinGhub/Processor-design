// 9th may 3:25 AM dm file address
module memory #(parameter PMA_SIZE, PMD_SIZE, DMA_SIZE, DMD_SIZE, PM_LOCATE, DM_LOCATE)
			(
				input wire clk, reset,
				input wire ps_pm_cslt, ps_dm_cslt,
				input wire[PMA_SIZE-1:0] ps_pm_add,
				//input wire[PMD_SIZE-1:0] pmDataIn, (future scope)
				input wire ps_pm_wrb, ps_dm_wrb,
				input wire[DMA_SIZE-1:0] dg_dm_add,
				input wire[DMD_SIZE-1:0] bc_dt,
				output reg[PMD_SIZE-1:0] pm_ps_op,
				output reg[DMD_SIZE-1:0] dm_bc_dt
			);


//------------------------------------------------------------------------------------------------------------------------------------
//					PM reading
//------------------------------------------------------------------------------------------------------------------------------------
		reg [PMD_SIZE-1:0] pmInsts [(2**PMA_SIZE)-1:0];	
		initial
		begin
			$readmemb(PM_LOCATE,pmInsts);
		end

		always@(posedge clk or negedge reset)
		if(~reset)
			pm_ps_op<=0;
		else
		begin
			if(ps_pm_cslt)
			begin
					//PM reading
					if(~ps_pm_wrb)
					begin
						pm_ps_op<=pmInsts[ps_pm_add];
					end
					else;	//writing condition. data from assembler or PM(I,M)=ureg instruction (future expansion scope)
			end
		end
		


//------------------------------------------------------------------------------------------------------------------------
//				DM reading and writing
//------------------------------------------------------------------------------------------------------------------------
		
		reg [DMD_SIZE-1:0] dmData [(2**DMA_SIZE)-1:0];
		reg [DMD_SIZE-1:0] dm [2*(2**DMA_SIZE)-1:0];	//with address

		integer file, i;
		reg dm_cslt;
		reg dm_wrb;
		reg [DMA_SIZE-1:0] dm_add;
		wire [DMD_SIZE-1:0] dmBypData;


	//----------------------------------------------------------------------------------------
		//Initially open and close to clear the DM file
		initial
		begin
			file=$fopen(DM_LOCATE,"w");
			$fclose(file);
		end
	
	//Comment above initial block if you want to access DM data present in data memory before startup.
	//----------------------------------------------------------------------------------------


		//initially load DM data from DM file (required when DM contains data to be read before startup)
		initial
		begin
			$readmemh(DM_LOCATE,dm);
			for(i=0; i<(2*(2**DMA_SIZE)); i=i+2)
			begin
				dmData[i/2]=dm[i+1];
			end
		end
		
		//DM bypass
		assign dmBypData = (dm_add==dg_dm_add) ? bc_dt : dmData[dg_dm_add];
		

		//DM reading
		always@(posedge clk)
		begin
			if(ps_dm_cslt)
			begin
				if(~ps_dm_wrb)
				begin
					dm_bc_dt<=dmBypData;
				end
			end
		end
		
		//control signal latching for writing purpose only (Write to memory at execute+1 cycle)
		always@(posedge clk)
		begin
			dm_cslt <= ps_dm_cslt;
			dm_wrb <= ps_dm_wrb;
			dm_add<=dg_dm_add;
		end

		//DM writing
		always@(posedge clk )
		begin
			if(dm_cslt)
			begin
				if(dm_wrb)
				begin
					dmData[dm_add][DMD_SIZE-1:0] = bc_dt ;
					file=$fopen(DM_LOCATE);
					for(i=0; i<(2**DMA_SIZE); i=i+1)
					begin
						$fdisplayh(file, i[DMA_SIZE-1:0], "\t", dmData[i]);
					end
					$fclose(file);
				end
			end
		end

endmodule

/*
module test_memory();

parameter PMA_SIZE=16, PMD_SIZE=32, DMA_SIZE=17, DMD_SIZE=16;

reg clk, ps_pm_cslt, ps_dm_cslt, ps_pm_wrb, ps_dm_wrb;
reg[PMA_SIZE-1:0] ps_pm_add;
wire[PMD_SIZE-1:0] pm_ps_op;
wire[DMD_SIZE-1:0] dm_bc_dt;
reg[DMA_SIZE-1:0] dg_dm_add;
reg[DMD_SIZE-1:0] bc_dt;

memory #(.PMA_SIZE(PMA_SIZE), .PMD_SIZE(PMD_SIZE), .DMA_SIZE(DMA_SIZE), .DMD_SIZE(DMD_SIZE))
		testMem1	(
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

initial
begin
	clk=1; ps_pm_add=16'h0;
	forever begin #5 clk=~clk; end
end

initial
begin
	ps_pm_cslt=0;
	#12 ps_pm_cslt=1;
end

always@(posedge clk)
begin
	ps_pm_add<=ps_pm_add+1;
end
	
initial
begin
	ps_pm_wrb=0;
end

initial
begin
	ps_dm_cslt=0;
	#11 ps_dm_cslt=1;
end

initial
begin
	//dg_dm_add=17'h0_0000;
	//#6 dg_dm_add=17'h0_0003;
	#12 dg_dm_add=17'h0_000a;
	#10 dg_dm_add=17'h0_000f;
end

initial
begin
	#12 ps_dm_wrb=0;
	#10 ps_dm_wrb=1;
end

initial
begin
	bc_dt=16'hffee;
end

endmodule
*/
