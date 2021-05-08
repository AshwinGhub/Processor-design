//6th May 7:36 PM reset added
module multiplier
			#(parameter RF_DATASIZE)
			(	
				//data below
				input wire[RF_DATASIZE-1:0] xb_dtx, xb_dty, 
				output wire[RF_DATASIZE-1:0] mul_xb_dt,
				
				//control signals below
				input wire ps_mul_en, ps_mul_otreg,
				input wire[3:0] ps_mul_dtsts,
				input wire[1:0] ps_mul_cls,
				
				//universal signals
				input wire clk, reset,

				//flags
				output reg mul_ps_mv, 
				output wire mul_ps_mn
			);
		
	//latching the control signals for execute cycle usage
	//=======================================================================================
		reg mul_en, mul_otreg;
		reg mul_rndPrdt, mul_IbF, mul_rxUbS, mul_ryUbS;		//mul_dtsts[3:0]
		reg[1:0] mul_cls;
		always@(posedge clk or negedge reset)
		begin 
			if(~reset)
			begin
				mul_en <= 1'b0;
				mul_otreg <= 1'b0;
				mul_ryUbS <= 1'b0;
				mul_rxUbS <= 1'b0;
				mul_IbF <= 1'b0;
				mul_rndPrdt <= 1'b0;
				mul_cls <= 2'b00;
			end
			else
				mul_en <= ps_mul_en;
		end	
		always@(posedge clk)
		begin
			if(ps_mul_en)
			begin
				mul_otreg <= ps_mul_otreg;
				mul_ryUbS <= ps_mul_dtsts[3];
				mul_rxUbS <= ps_mul_dtsts[2];
				mul_IbF <= ps_mul_dtsts[1];
				mul_rndPrdt <= ps_mul_dtsts[0];
				mul_cls <= ps_mul_cls;
			end
		end
	//=======================================================================================
	
		wire mul_mrUbS;
		assign mul_mrUbS=mul_rxUbS;	//Used for SAT MR instruction. The rxUbS data status bit is shared for both Rx data status and MR data status.

		reg[RF_DATASIZE-1:0] Rx16_latched, Ry16_latched;
		
		//latch Register File inputs multiplier entry
		always@(posedge clk or negedge reset)
		begin
			if(~reset)
			begin
				Rx16_latched <= 16'h0;
				Ry16_latched <= 16'h0;
			end
			else
				if(ps_mul_en & ps_mul_cls!=2'b00)
				begin
					Rx16_latched <= xb_dtx;	//latch only when multiplier enabled and also its not a saturate instruction which only requires MR
					Ry16_latched <= xb_dty;
				end
		end

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
		//assign s1 = ~mul_ryUbS;					//USI - s1=0, s0=0
		//assign s0 = mul_rxUbS & (mul_IbF | ~mul_ryUbS);
		assign s1 = ~mul_rxUbS | ~mul_ryUbS;
		assign s0 = (mul_rxUbS & (~mul_ryUbS |  mul_IbF)) | (~mul_rxUbS & mul_ryUbS);

		reg[2*RF_DATASIZE-1:0] mul32_product_data;	//32 bit multiplier product wire
		reg[(RF_DATASIZE*5/2)-1:0] mul40_out_data;	//40 bit multiplier output
		
		//multiplier product logic for SS, UU, SU cases in Fractional and Integer modes
		always@(*)
		begin
			case( {s1,s0} )
				
				2'b00:	mul32_product_data=S_p[2*RF_DATASIZE+1:2];		// SSI	(discard 1:0 bits)	[33:2]
				
				2'b01:	mul32_product_data=S_p[2*RF_DATASIZE+1:2]<<1;		// SSF	(discard MSB by left shifting to prevent redundancy in sign)	[33:2]<<1
				
				2'b10:	mul32_product_data=S_p[2*RF_DATASIZE-1:0];		// UUI and UUF	(discard 33:32 bits)	[31:0]

				2'b11:	mul32_product_data=S_p[2*RF_DATASIZE:1];		// SUI, SUF, USI, USF (discard 33rd and 0th bit)	[32:1]
			endcase
		end
		
		reg[(RF_DATASIZE*5/2)-1:0] mr40_data;
		wire[(RF_DATASIZE*5/2)-1:0] mr_in_data;

		//assign mr_byp_data = (ps_mul_mrBypass) ? mr_in_data : mr40_data;

		wire[(RF_DATASIZE*5/2)-1:0] sat_out;
		wire satEn;
		
		assign satEn = (mul_cls==2'b00) & mul_en;

		mul_sat sat1(satEn, mr40_data, mul_mrUbS, mul_IbF, sat_out);	
		defparam sat1.SIZE=RF_DATASIZE;
		
		
		wire[2*RF_DATASIZE-1:0] rnd32_out;

		mul_rnd rnd1(mul32_product_data, mul_rndPrdt, rnd32_out);
		defparam rnd1.SIZE=RF_DATASIZE;
		
				
		
		
		
		
		
		
		
		
		
		
		
		/*
//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		//multiplier operation selector
		always@(*)
		begin
			
				if(~mul_cls[1])
				begin

					//saturate	mul_cls=00
					if(~mul_cls[0])
						mul40_out_data<=sat_out;

					//product	mul_cls=01
					else
						if(mul_IbF)
							//mul40_out_data<={ {(RF_DATASIZE/2){1'b0}},rnd32_out };	//{8 zeros, 32bit product} for unsigned result
							mul40_out_data<={ { (RF_DATASIZE/2) {(mul_rxUbS|mul_ryUbS) & rnd32_out[2*RF_DATASIZE-1]} },rnd32_out };		//sign extend 32 bit product to 40 for signed	
						else
							//mul40_out_data<={ {(RF_DATASIZE*3/2){1'b0}},rnd32_out[2*RF_DATASIZE-1:RF_DATASIZE] }; //{24 zeros, 16bit product[31:16] }
							//mul40_out_data<={ {(RF_DATASIZE*3/2){1'b0}},rnd32_out[RF_DATASIZE-1:0] }; //{24 zeros, 16bit product[15:0]} for unsigned result
							mul40_out_data<={ { (RF_DATASIZE*3/2) {(mul_rxUbS|mul_ryUbS) & rnd32_out[RF_DATASIZE-1]} },rnd32_out[RF_DATASIZE-1:0] };   //sign extend 16LSBs to 40 for signed
				end
				
				//accumulate	mul_cls=1X
				else
					if(mul_IbF)
						mul40_out_data <= mr40_data + mul_cls[0] + ( { {(RF_DATASIZE/2) {(mul_rxUbS|mul_ryUbS) & rnd32_out[2*RF_DATASIZE-1]} },rnd32_out } ^ { (RF_DATASIZE*5/2){mul_cls[0]} } );	//40bit sign extended subtEn is xor ed
					else
						//mul40_out_data <= mr_byp_data + mul_cls[0] + ( { {(RF_DATASIZE*3/2){1'b0}},rnd32_out[31:16] } ^ { (RF_DATASIZE*5/2){mul_cls[0]} } );
						mul40_out_data <= mr40_data + mul_cls[0] + ( { {(RF_DATASIZE*3/2) {(mul_rxUbS|mul_ryUbS) & rnd32_out[RF_DATASIZE-1]} },rnd32_out[RF_DATASIZE-1:0] } ^ { (RF_DATASIZE*5/2){mul_cls[0]} } );
			
		end
		
		wire mul_mrWen;		//Write enable signal for enabling MR write
		assign mul_mrWen = mul_otreg & mul_en;	//ANDing mul_otreg with mul_en ensures that mul_otreg signal goes low when multiplier is disabled and avoids unnecessary MR updates (which happens if last instruction is MR accumulate instruction)

		//multiplexer at input of mr to decide whether data is to be written into MR
		assign mr_in_data = (mul_mrWen) ? mul40_out_data : mr40_data; 

		//mr writing logic
		always@(posedge clk)
		begin
			mr40_data<=mr_in_data;
		end
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/
		
		
		
		
		


		
	        //multiplier operation classification
		always@(*)
		begin
			casex(mul_cls)
				
				2'b00:	//saturate
					mul40_out_data = sat_out;

				2'b01:	//product
					mul40_out_data = { { RF_DATASIZE/2 {(mul_rxUbS|mul_ryUbS) & rnd32_out[2*RF_DATASIZE-1]} }, rnd32_out };		//sign extend 32 bit product to 40 bits.

				2'b1X:	//accumulate
					mul40_out_data = mr40_data + mul_cls[0] + ( { { RF_DATASIZE/2 {(mul_rxUbS|mul_ryUbS) & rnd32_out[2*RF_DATASIZE-1]} }, rnd32_out } ^ { RF_DATASIZE*5/2 {mul_cls[0]} } ) ;	//sign extend product to 40 bits and then find 2's complement and add to mr
			endcase
		end
		
		//multiplexer at input of mr to decide whether data is to be written into MR
		assign mr_in_data = (mul_otreg & mul_en) ? mul40_out_data : mr40_data;	
	//ANDing mul_otreg with mul_en ensures that mul_otreg signal goes low when multiplier is disabled and avoids unnecessary MR updates (which happens if last instruction is MR accumulate instruction)
		
		//MR write logic
		always@(posedge clk or negedge reset)
		begin
			if(~reset)
				mr40_data<=40'h0;		//reset mr so that at reset, mul_cls=00 -> mv flag doesn't go to x
			else
				mr40_data<=mr_in_data;
		end



		
		
		
		
		
		
		//16 bit data extraction from mul40_out_data for passing to Rn
		assign mul_xb_dt = mul_IbF ? mul40_out_data[(2*RF_DATASIZE-1):RF_DATASIZE] : mul40_out_data[RF_DATASIZE-1:0];
		
		//mul40_out_data[31:16] : mul40_out_data[15:0]

		
		//overflow flag updation		- This works only for
		always@(*)
		begin
			case( {mul_rxUbS|mul_ryUbS , mul_IbF} )		
			
					2'b00:	//UI
						mul_ps_mv = ~(mul40_out_data[(RF_DATASIZE*5/2)-1:RF_DATASIZE]=={24{1'h0}}); 			//DATA_IN[39:16]== 24 zeros
				
					2'b01:	//UF
						mul_ps_mv = ~(mul40_out_data[(RF_DATASIZE*5/2)-1:RF_DATASIZE*2]==8'h00); 			//data_in[39:32]==8'h00
				
					2'b10:	//SI
						mul_ps_mv = ~(mul40_out_data[(RF_DATASIZE*5/2)-1:RF_DATASIZE-1]=={25{1'h1}} | mul40_out_data[(RF_DATASIZE*5/2)-1:RF_DATASIZE-1]=={25{1'h0}});	//data_in[39:15]== 25 ones or 25 zeros

					2'b11:	//SF
						mul_ps_mv = ~(mul40_out_data[(RF_DATASIZE*5/2)-1:RF_DATASIZE*2-1]=={9{1'h1}} | mul40_out_data[(RF_DATASIZE*5/2)-1:RF_DATASIZE*2-1]=={9{1'h0}});			//data_in[39:31]== 9 ones or 9 zeros
			endcase
		end
		
		
		//sign flag MN updation
		assign mul_ps_mn = (mul_rxUbS|mul_ryUbS) & mul40_out_data[(RF_DATASIZE*5/2)-1];

endmodule




	/*
	*			Control signal breakdown
		*						
		*		mul_otreg = 0 (Rn), 1 (MR)
		*		
				mul_dtsts = 0000 (UUI),	0010 (UUF), 0011(UUFR), 0100 (SUI), 0110 (SUF), 0111 (SUFR), 1000 (USI), 1010 (USF), 1011 (USFR), 1100 (SSI), 1110 (SSF), 1111 (SSFR)
		*
		*		mul_cls = 00 (SAT), 01 (Product), 10 (Accumulate ADD), 11 (Accumulate SUB)
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
