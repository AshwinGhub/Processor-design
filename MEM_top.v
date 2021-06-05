//Synthesised RTL (unconnected PM)
module memory #(parameter 
           `ifdef IGNORE
                   PM_LOCATE, DM_LOCATE,
           `endif
                    PMA_SIZE=3, PMD_SIZE=32, DMA_SIZE=3, DMD_SIZE=16)
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
		reg [PMD_SIZE-1:0] pmWithCall [(2**PMA_SIZE)-1:0];	

		integer address, calladdress=0;
		integer file, i;

`ifdef IGNORE
		initial
		begin
			$readmemb(PM_LOCATE,pmInsts);
			//stop iterating at 32'hx. Compare with 32'haaaa_aaaa (unused opcode) instead.
			//verilog can't seem to compare 32'hx.
			for(address=0; pmInsts[address[PMA_SIZE-1:0]]!=32'haaaa_aaaa;address=address+1)		
			begin
				//if we detect MSB 16 bits as 1s, it means lsb bits 
				//represent call pm address if(&( pmInsts [address[15:0]] [31:16] ))
				if(&( pmInsts [address[PMA_SIZE-1:0]] [PMD_SIZE-1:PMD_SIZE/2] ))		
				begin
					calladdress=pmInsts[address[PMA_SIZE-1:0]];	//address obtained from opcode lsb16
					address=address+1;				
				end				
				pmWithCall[calladdress[PMA_SIZE-1:0]]=pmInsts[address[PMA_SIZE-1:0]];
				calladdress=calladdress+1;

				//Overwriting when calladdress resets and next
				//instruction is not a CALL instruction
				if(calladdress[PMA_SIZE-1:0]==16'h0 & ~(&(pmInsts[address[PMA_SIZE-1:0]+1][PMD_SIZE-1:PMD_SIZE/2])))
				begin
					$display("/////////////////////////////////////////////////////////////////////////////");
					$display("\nCaution. Starting locations overwritten\n");
					$display("/////////////////////////////////////////////////////////////////////////////");
				end
			end
		//================================================================================================================================================
			//below commented part used for checking opcode location after rearranging based on CALL. Ignore....
			/*file=$fopen("C:\\Users\\Ashwin-Pradeep\\Desktop\\Project-Final-Year\\GIT-repo\\memory_files\\pm_CALL\\calling\\pm_file.txt","w");
			for(i=0;i<2**PMA_SIZE;i=i+1)
			begin
				//$fdisplay(file, i[PMA_SIZE-1:0]);
				$fdisplayb(file, i[PMA_SIZE-1:0], "\t", pmWithCall[i[PMA_SIZE-1:0]]);
			end
			$fclose(file);*/
		//================================================================================================================================================	
	    end
`endif

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
						pm_ps_op<=pmWithCall[ps_pm_add];
					end
					else   //writing condition. data from assembler or PM(I,M)=ureg instruction (future expansion scope)
					   pm_ps_op<=32'h0;
			end
			else
			     pm_ps_op<=32'h0;
		end
		

//------------------------------------------------------------------------------------------------------------------------
//				DM reading and writing
//------------------------------------------------------------------------------------------------------------------------
		
		reg [DMD_SIZE-1:0] dmData [(2**DMA_SIZE)-1:0];
		reg [DMD_SIZE-1:0] dm [2*(2**DMA_SIZE)-1:0];	//with address

		reg dm_cslt;
		reg dm_wrb;
		reg [DMA_SIZE-1:0] dm_add;
		wire [DMD_SIZE-1:0] dmBypData;

`ifdef IGNORE
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
				dmData[i/2]=dm[i+1];    //here address is to be discarded. Hence we read two words at a time
			end
		end
`endif

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
`ifdef IGNORE
					file=$fopen(DM_LOCATE);
					for(i=0; i<(2**DMA_SIZE); i=i+1)
					begin
						$fdisplayh(file, i[DMA_SIZE-1:0], "\t", dmData[i]);
					end
					$fclose(file);
`endif
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
