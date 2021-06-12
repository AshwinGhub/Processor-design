//Synthesised RTL
module mul_rnd	
		#(parameter SIZE=16)
		(
			input wire[SIZE*5/2-1:0] data_in,		//mul40_out_data
			input wire ps_mul_rndPrdt,
			output reg[SIZE*5/2-1:0] out		//rnd40_out
		);
	
	always@(*)
	begin
		if(ps_mul_rndPrdt)		//signal is from programmer directly. rndPrdt becomes true only during ps_mul_IbF=1 (Fractional case).
		begin
			if(~data_in[SIZE-1])	
				//truncate
				out = { data_in[SIZE*5/2-1:SIZE], {SIZE{1'b0}} };
			else
			begin
				if(data_in[SIZE-2:0]=={(SIZE-1){1'b0}})
					//rnd to make data[16]=0 and truncate lsb16
					out = { (data_in[SIZE*5/2-1:SIZE]+data_in[SIZE]), {SIZE{1'b0}} };
				else
					//add 1 to msb16 and truncate lsb16
					out = { (data_in[SIZE*5/2-1:SIZE]+1), {SIZE{1'b0}} };
			end
		end
		
		else
			out=data_in;
	end
endmodule
