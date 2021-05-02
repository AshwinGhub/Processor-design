module cnd_dcdr(cnd_en,op_cnd,cnd_stat,astat_bts);

input cnd_en;
input[4:0] op_cnd;
input[7:0] astat_bts;
output cnd_stat;

reg frvr, az, an, azn, ac, av, mv, ms, sv, sz, cnd_stat;

always @(*) begin

	if(cnd_en) begin

		if(op_cnd[4:0]==5'b11111) begin

			frvr= 1'b1;
			az= 1'b0;
			an= 1'b0;
			azn= 1'b0;
			ac= 1'b0;
			av= 1'b0;
			mv= 1'b0;
			ms= 1'b0;
			sv= 1'b0;
			sz= 1'b0;

		end else begin

			frvr= 1'b0;
			az= (op_cnd[3:0]==4'b0000) &  astat_bts[0];
			an= (op_cnd[3:0]==4'b0001) & astat_bts[2];
			azn= (op_cnd[3:0]==4'b0010) & (astat_bts[0] | astat_bts[2]);
			ac= (op_cnd[3:0]==4'b0011) & astat_bts[3];
			av= (op_cnd[3:0]==4'b0100) & astat_bts[1];
			mv= (op_cnd[3:0]==4'b1000) & astat_bts[5];
			ms= (op_cnd[3:0]==4'b1001) & astat_bts[4];
			sv= (op_cnd[3:0]==4'b1010) & astat_bts[6];
			sz= (op_cnd[3:0]==4'b1011) & astat_bts[7];

		end

	end else begin

		frvr= 1'b0;
		az= 1'b0;
		an= 1'b0;
		azn= 1'b0;
		ac= 1'b0;
		av= 1'b0;
		mv= 1'b0;
		ms= 1'b0;
		sv= 1'b0;
		sz= 1'b0;

	end

	cnd_stat= cnd_en & ( frvr | ( (az | an | azn | ac | av | mv | ms | sv | sz) ^ op_cnd[4] ) );

end

endmodule



