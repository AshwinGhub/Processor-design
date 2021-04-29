module mul_rnd	
		#(parameter SIZE)
		(
			input wire[31:0] data_in,
			input wire ps_mul_rndPrdt,
			output reg[31:0] out
		);
	
	always@(*)
	begin
		if(ps_mul_rndPrdt)		//signal is from programmer directly. rndPrdt becomes true only during ps_mul_IbF=1 (Fractional case).
		begin
			if(~data_in[15])	
				//truncate
				out = { data_in[31:16], {16{1'b0}} };
			else
			begin
				if(data_in[14:0]=={15{1'b0}})
					//rnd to make data[16]=0 and truncate lsb16
					out = { (data_in[31:16]+data_in[16]), {16{1'b0}} };
				else
					//add 1 to msb16 and truncate lsb16
					out = { (data_in[31:16]+1), {16{1'b0}} };
			end
		end
		
		else
			out=data_in;
	end
endmodule
