//Synthesised RTL
module multiplier
			#(parameter RF_DATASIZE=16)
			(	
				//data below
				input wire[RF_DATASIZE-1:0] xb_dtx, xb_dty, 
				output wire[RF_DATASIZE-1:0] mul_xb_dt,
				
				//control signals below
				input wire ps_mul_en, ps_mul_otreg,
				input wire[3:0] ps_mul_dtsts,
				input wire[1:0] ps_mul_cls, ps_mul_sc,
				
				//universal signals
				input wire clk, reset,

				//flags
				output wire mul_ps_mv, mul_ps_mn
			);
		
	//latching the control signals for execute cycle usage
	//=======================================================================================
		reg mul_en, mul_otreg;
		reg mul_rndPrdt, mul_IbF, mul_rxUbS, mul_ryUbS;		//mul_dtsts[3:0]
		reg[1:0] mul_cls, mul_sc;
		always@(posedge clk or negedge reset)
		begin 
			if(~reset)
			begin
				mul_en <= 1'b0;
			end
			else
				mul_en <= ps_mul_en;
		end	
		always@(posedge clk or negedge reset)
		begin
		    if(~reset)
		    begin
		        mul_otreg <= 1'b0;
				mul_ryUbS <= 1'b0;
				mul_rxUbS <= 1'b0;
				mul_IbF <= 1'b0;
				mul_rndPrdt <= 1'b0;
				mul_cls <= 2'b00;
				mul_sc <= 2'b00;
			end
			else if(ps_mul_en)
			begin
				mul_otreg <= ps_mul_otreg;
				mul_ryUbS <= ps_mul_dtsts[3];
				mul_rxUbS <= ps_mul_dtsts[2];
				mul_IbF <= ps_mul_dtsts[1];
				mul_rndPrdt <= ps_mul_dtsts[0];
				mul_cls <= ps_mul_cls;
				mul_sc <= ps_mul_sc;
			end
		end
	//=======================================================================================
	
	
	
		wire mul_mrUbS;
		assign mul_mrUbS=mul_rxUbS;	//Used for SAT MR instruction. The rxUbS data status bit is shared for both Rx data status and MR data status.

		reg[RF_DATASIZE-1:0] Rx16_latched, Ry16_latched;
		
	//latch Rx and Ry at entry of multiplier to use data only in execute
	//=======================================================================================
		always@(posedge clk or negedge reset)
		begin
			if(~reset)
			begin
				Ry16_latched <= 16'h0;
			end
			else
				if( ps_mul_en & ps_mul_cls!=2'b00 )
					Ry16_latched <= xb_dty;
		end

		always@(posedge clk or negedge reset)
		begin
		    if(~reset)
		    begin
		          Rx16_latched <= 16'h0;
		    end
			else if( ps_mul_en & ~(ps_mul_cls==2'b00 & (~ps_mul_otreg|(&ps_mul_sc))) )
				Rx16_latched <= xb_dtx;
		end
	//=======================================================================================
	

		
	
		wire[RF_DATASIZE:0] U_Rx, S_Rx, U_Ry, S_Ry;	//17 bit wires for converting to signed

		assign U_Rx={1'b0,Rx16_latched};
		assign S_Rx={Rx16_latched,1'b0};		//Signed -> left shifted by appending zero
		assign U_Ry={1'b0,Ry16_latched};
		assign S_Ry={Ry16_latched,1'b0};

		wire signed[RF_DATASIZE:0] S_x,S_y;		//17 bit SIGNED wires for SIGNED multiplication
		assign S_x = mul_rxUbS ? S_Rx : U_Rx;
		assign S_y = mul_ryUbS ? S_Ry : U_Ry;

		wire signed[2*RF_DATASIZE+1:0] S_p;		//34 bit SIGNED product wire
		assign S_p = S_x * S_y;
			
		wire s1,s0;	//product mux select lines
		assign s1 = ~mul_rxUbS | ~mul_ryUbS;
		assign s0 = (mul_rxUbS & (~mul_ryUbS |  mul_IbF)) | (~mul_rxUbS & mul_ryUbS);

		reg[2*RF_DATASIZE-1:0] mul32_product_data;	//32 bit multiplier product wire
		reg[(RF_DATASIZE*5/2)-1:0] mul40_out_data;	//40 bit multiplier output
	
	//multiplier product logic for SS, UU, SU cases in Fractional and Integer mode
	//=========================================================================================
		always@(*)
		begin
			case( {s1,s0} )
				
				2'b00:	mul32_product_data=S_p[2*RF_DATASIZE+1:2];		// SSI	(discard 1:0 bits)	[33:2]
				
				2'b01:	mul32_product_data=S_p[2*RF_DATASIZE+1:2]<<1;		// SSF	(discard MSB by left shifting to prevent redundancy in sign)	[33:2]<<1
				
				2'b10:	mul32_product_data=S_p[2*RF_DATASIZE-1:0];		// UUI and UUF	(discard 33:32 bits)	[31:0]

				2'b11:	mul32_product_data=S_p[2*RF_DATASIZE:1];		// SUI, SUF, USI, USF (discard 33rd and 0th bit)	[32:1]
			endcase
		end
	//=========================================================================================
	


		reg [(RF_DATASIZE*5/2)-1:0] mr40_data;
		wire [(RF_DATASIZE*5/2)-1:0] mr_in_data;
		reg [RF_DATASIZE-1:0] mr_slice;	//16 bit MRx value. Used for Rn=MRx

		wire[(RF_DATASIZE*5/2)-1:0] sat_out;
		wire satEn;
		
		assign satEn = (mul_cls==2'b00) & (mul_sc==2'b11);
		//satEn stays high after mul is disabled if last instruction is sat MR

		mul_sat sat1(satEn, mr40_data, mul_mrUbS, mul_IbF, sat_out);	
		defparam sat1.SIZE=RF_DATASIZE;
		
		
		wire[RF_DATASIZE*5/2-1:0] rnd40_out;

		mul_rnd rnd1(mul40_out_data, mul_rndPrdt, rnd40_out);
		defparam rnd1.SIZE=RF_DATASIZE;
		
		
	//multiplier operation classification
	//=======================================================================
		always@(*)
		begin
			casex(mul_cls)
				
				2'b00:	//saturate and MR<->Rn transfers
					case(mul_sc)			//mul40_out_data and mr_slice are 2 different muxes with same select line
						2'b00:			//MR0 (no sign extension as per sharc)
							begin	
								//mul40_out_data = { {RF_DATASIZE*3/2{1'h0}}, Rx16_latched };
								mul40_out_data = { mr40_data[RF_DATASIZE*5/2-1:RF_DATASIZE], Rx16_latched };
								mr_slice = mr40_data[RF_DATASIZE-1:0];	
							end
						2'b01:			//MR1 (sign extended)
							begin
								//mul40_out_data = { {RF_DATASIZE/2{Rx16_latched[RF_DATASIZE-1]}}, Rx16_latched, {RF_DATASIZE{1'h0}} };	
								mul40_out_data = { {RF_DATASIZE/2{Rx16_latched[RF_DATASIZE-1]}}, Rx16_latched, mr40_data[RF_DATASIZE-1:0] };
								mr_slice = mr40_data[RF_DATASIZE*2-1:RF_DATASIZE];
							end
						2'b10:	
							begin		//MR2 (sign extend)
								//mul40_out_data = { Rx16_latched[RF_DATASIZE/2-1:0], {RF_DATASIZE*2{1'h0}} };
								mul40_out_data = { Rx16_latched[RF_DATASIZE/2-1:0], mr40_data[RF_DATASIZE*2-1:0] };
								mr_slice = {{RF_DATASIZE/2{mr40_data[RF_DATASIZE*5/2-1]}}, mr40_data[RF_DATASIZE*5/2-1 : RF_DATASIZE*2]};
							end				
						2'b11:	
						    begin
						          mul40_out_data = sat_out;	//SAT MR
					              mr_slice = {RF_DATASIZE{1'h0}};
					        end
					endcase

				2'b01:	//product
				    begin
    					//mul40_out_data = { { RF_DATASIZE/2 {(mul_rxUbS|mul_ryUbS) & rnd40_out[2*RF_DATASIZE-1]} }, rnd40_out };		//sign extend 32 bit product to 40 bits.
                        mul40_out_data = { { RF_DATASIZE/2 { S_x[RF_DATASIZE]^S_y[RF_DATASIZE] } }, mul32_product_data };
						mr_slice = {RF_DATASIZE{1'h0}};
                    end
				2'b1X:	//accumulate
					begin
    					//mul40_out_data = mr40_data + mul_cls[0] + ( { { RF_DATASIZE/2 {(mul_rxUbS|mul_ryUbS) & rnd40_out[2*RF_DATASIZE-1]} }, rnd40_out } ^ { RF_DATASIZE*5/2 {mul_cls[0]} } ) ;	//sign extend product to 40 bits and then find 2's complement and add to mr
                        mul40_out_data = mr40_data + mul_cls[0] + ( { { RF_DATASIZE/2 { S_x[RF_DATASIZE]^S_y[RF_DATASIZE] } }, mul32_product_data } ^ { RF_DATASIZE*5/2 {mul_cls[0]} } ) ;	//sign extend product to 40 bits and then find 2's complement and add to mr
                        mr_slice = {RF_DATASIZE{1'h0}};
                    end
			endcase
		end
	//======================================================================
		
		
	
		//multiplexer at input of mr to decide whether data is to be written into MR
		assign mr_in_data = (mul_otreg & mul_en) ? rnd40_out : mr40_data;
		
		//ANDing mul_otreg with mul_en ensures that mul_otreg signal goes low when multiplier 
		//is disabled and avoids unnecessary MR updates 
		//(which happens if last instruction is MR accumulate instruction)
		



	//MR write logic
	//=======================================================================
		always@(posedge clk or negedge reset)
		begin
			if(~reset)
				mr40_data<=40'h0;		//reset mr so that at reset, mul_cls=00 -> mv flag doesn't go to x
			else
				mr40_data<=mr_in_data;
		end
	//=======================================================================

	
		wire [RF_DATASIZE-1:0] mul_out;
		
		//16 bit data extraction from mul40_out_data for passing to output mux
		assign mul_out = mul_IbF ? rnd40_out[(2*RF_DATASIZE-1):RF_DATASIZE] : rnd40_out[RF_DATASIZE-1:0];
		
		

	//Output to Rn
	//=================================================================================
		assign mul_xb_dt = (mul_cls==2'b00 & mul_sc!=2'b11) ? mr_slice : mul_out;
	//=================================================================================
	

		wire mul_mn;
		reg mul_mv;
		
		//overflow flag internal
		always@(*)
		begin
			case( {mul_rxUbS|mul_ryUbS , mul_IbF} )		
			
					2'b00:	//UI	[39:16]== 24 zeros
						mul_mv = ~(rnd40_out[(RF_DATASIZE*5/2)-1:RF_DATASIZE]=={24{1'h0}}); 
				
					2'b01:	//UF	[39:32]==8'h00
						mul_mv = ~(rnd40_out[(RF_DATASIZE*5/2)-1:RF_DATASIZE*2]==8'h00);
				
					2'b10:	//SI 	[39:15]== 25 ones or 25 zeros
						mul_mv = ~(rnd40_out[(RF_DATASIZE*5/2)-1:RF_DATASIZE-1]=={25{1'h1}} | mul40_out_data[(RF_DATASIZE*5/2)-1:RF_DATASIZE-1]=={25{1'h0}});	
					2'b11:	//SF	[39:31]== 9 ones or 9 zeros
						mul_mv = ~(rnd40_out[(RF_DATASIZE*5/2)-1:RF_DATASIZE*2-1]=={9{1'h1}} | mul40_out_data[(RF_DATASIZE*5/2)-1:RF_DATASIZE*2-1]=={9{1'h0}});
			endcase
		end
		
		
		//sign flag internal
		assign mul_mn = (mul_rxUbS|mul_ryUbS) & rnd40_out[(RF_DATASIZE*5/2)-1];



	//Flag updation before giving to out port
	//====================================================================================
		assign mul_ps_mv = mul_mv & ~(mul_cls==2'b00 & mul_sc!=2'b11);
		assign mul_ps_mn = mul_mn & ~(mul_cls==2'b00 & mul_sc!=2'b11);
	//====================================================================================
	

endmodule




	/*
	*			Control signal breakdown
		*						
		*		mul_otreg = 0 (Rn), 1 (MR)
		*		
				mul_dtsts = 0000 (UUI),	0010 (UUF), 0011(UUFR), 0100 (SUI), 0110 (SUF), 0111 (SUFR), 1000 (USI), 1010 (USF), 1011 (USFR), 1100 (SSI), 1110 (SSF), 1111 (SSFR)
		*
		*		mul_cls = 00 (refer mul_sc signal), 01 (Product), 10 (Accumulate ADD), 11 (Accumulate SUB)
		*
				mul_sc = 00 (MR0), 01 (MR1), 10 (MR2), 11 (SAT MR)
		*
				{s1,s0} = 00 (SSI), 01 (SSF), 10 (UU), 11 (SU|US)
		*		
		*
		*/




	//==============================================================
	//
	//			Testbench for mul
	//
	//==============================================================
	/*
	
	module test_cu_mul();
	
	reg reset, clk;
	wire [15:0] mul_out;

	reg ps_mul_en, ps_mul_otreg;
	reg [3:0] ps_mul_dtsts;
	reg [1:0] ps_mul_cls;
				
	wire flag1, flag2;

	multiplier #(.RF_DATASIZE(16)) m_tobj
			(	16'habcd, 16'hcdef, 
				mul_out,

				//control signals below
				ps_mul_en, ps_mul_otreg,
				ps_mul_dtsts,
				ps_mul_cls,
				
				//universal signals
				clk, reset,

				//flags
				mul_ps_mv, 
				mul_ps_mn
			);
	
	initial
	begin
		reset=1;
		#1 reset=0;
		#2 reset=1;
	end

	initial
	begin
		clk=0;
		#10
		clk=1;
		forever begin
			#5 clk=~clk;
		end
	end

	always@(negedge reset)
		if(~reset)
			ps_mul_en<=1'b0;		//PS supplies enable=0 on reset. This is required condition!

	always@(posedge clk)
	//if(~reset)
		begin
			#5
			ps_mul_en<=1'b1;
			ps_mul_otreg<=1'b1;
			ps_mul_dtsts<=4'b1;
			ps_mul_cls<=2'b01;
		end

	endmodule 
	*/
