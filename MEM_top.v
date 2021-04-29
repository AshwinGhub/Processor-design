module memory #(parameter PMA_SIZE, PMD_SIZE, DMA_SIZE, DMD_SIZE)
			(
				input wire clk,
				input wire ps_pm_chipSelect, ps_dm_a_chipSelect,
				input wire[PMA_SIZE-1:0] ps_pm_a,
				//input wire[PMD_SIZE-1:0] pmDataIn, (future scope)
				input wire ps_pm_RbW, ps_dm_a_RbW,
				input wire[DMA_SIZE-1:0] ps_dm_a,
				input wire[DMD_SIZE-1:0] dmDataIn,
				output reg[PMD_SIZE-1:0] pmDataOut,
				output reg[DMD_SIZE-1:0] dmDataOut
			);


	//------------------------------------------------------------------------------------------------------------------------------------
	//					PM reading
	//------------------------------------------------------------------------------------------------------------------------------------
		reg [PMD_SIZE-1:0] pmInsts [(2**PMA_SIZE)-1:0];	
		initial
		begin
			$readmemb("C:/Users/Ashwin Pradeep/Desktop/Project Final Year/codes/project_integration_phase2/memory_txt_file/pm_file.txt",pmInsts);
		end

		always@(posedge clk)
		begin
			if(ps_pm_chipSelect)
			begin
					//PM reading
					if(~ps_pm_RbW)
					begin
						pmDataOut<=pmInsts[ps_pm_a];
					end
					else;	//writing condition. data from assembler or PM(I,M)=ureg instruction (future expansion scope)
			end
		end
		


	//------------------------------------------------------------------------------------------------------------------------
	//				DM reading and writing
	//------------------------------------------------------------------------------------------------------------------------
		
		reg [DMD_SIZE-1:0] dmData [(2**DMA_SIZE)-1:0];

		integer file, i;
		reg dm_chipSelect;
		reg dm_RbW;
		reg [DMA_SIZE-1:0] dm_a;
		wire [DMD_SIZE-1:0] dmBypData;


		//Initially open and close to clear the DM file
		initial
		begin
			file=$fopen("C:/Users/Ashwin Pradeep/Desktop/Project Final Year/codes/project_integration_phase2/memory_txt_file/dm_file.txt","w");
			$fclose(file);
		end

		
		//DM bypass
		assign dmBypData = (dm_a==ps_dm_a) ? dmDataIn : dmData[ps_dm_a];
		

		//DM reading
		always@(posedge clk)
		begin
			if(ps_dm_a_chipSelect)
			begin
				if(~ps_dm_a_RbW)
				begin
					$readmemh("C:/Users/Ashwin Pradeep/Desktop/Project Final Year/codes/project_integration_phase2/memory_txt_file/dm_file.txt",dmData);
					dmDataOut<=dmBypData;
				end
			end
		end
		
		//control signal latching for writing purpose only (Write to memory at execute+1 cycle)
		always@(posedge clk)
		begin
			dm_chipSelect <= ps_dm_a_chipSelect;
			dm_RbW <= ps_dm_a_RbW;
			dm_a<=ps_dm_a;
		end

		//DM writing
		always@(posedge clk)
		begin
			if(dm_chipSelect)
			begin
				if(dm_RbW)
				begin
					dmData[dm_a]=dmDataIn;
					file=$fopen("C:/Users/Ashwin Pradeep/Desktop/Project Final Year/codes/project_integration_phase2/memory_txt_file/dm_file.txt");
					for(i=0; i<((2**DMA_SIZE)-1); i=i+1)
					begin
						$fdisplayh(file,dmData[i[DMA_SIZE-1:0]]);
					end
					$fclose(file);
				end
			end
		end

endmodule

/*
module test_memory();

parameter PMA_SIZE=16, PMD_SIZE=32, DMA_SIZE=17, DMD_SIZE=16;

reg clk, ps_pm_chipSelect, ps_dm_a_chipSelect, ps_pm_RbW, ps_dm_a_RbW;
reg[PMA_SIZE-1:0] ps_pm_a;
wire[PMD_SIZE-1:0] pmDataOut;
wire[DMD_SIZE-1:0] dmDataOut;
reg[DMA_SIZE-1:0] ps_dm_a;
reg[DMD_SIZE-1:0] dmDataIn;

memory #(.PMA_SIZE(PMA_SIZE), .PMD_SIZE(PMD_SIZE), .DMA_SIZE(DMA_SIZE), .DMD_SIZE(DMD_SIZE))
		testMem1	(
					clk,
					ps_pm_chipSelect, ps_dm_a_chipSelect,
					ps_pm_a,
					//pmDataIn,
					ps_pm_RbW, ps_dm_a_RbW,
					ps_dm_a,
					dmDataIn,
					pmDataOut,
					dmDataOut
				);

initial
begin
	clk=1; ps_pm_a=16'h0;
	forever begin #5 clk=~clk; end
end

initial
begin
	ps_pm_chipSelect=0;
	#12 ps_pm_chipSelect=1;
end

always@(posedge clk)
begin
	ps_pm_a<=ps_pm_a+1;
end
	
initial
begin
	ps_pm_RbW=0;
end

initial
begin
	ps_dm_a_chipSelect=0;
	#11 ps_dm_a_chipSelect=1;
end

initial
begin
	//ps_dm_a=17'h0_0000;
	//#6 ps_dm_a=17'h0_0003;
	#12 ps_dm_a=17'h0_000a;
	#10 ps_dm_a=17'h0_000f;
end

initial
begin
	#12 ps_dm_a_RbW=0;
	#10 ps_dm_a_RbW=1;
end

initial
begin
	dmDataIn=16'hffee;
end

endmodule
*/
