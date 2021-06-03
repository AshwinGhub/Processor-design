//***************************************************************
//-----------------------------------------------------------------------------ALU HARDWARE MODULE-------------------------------------------------------------------------------------------
//***************************************************************

//Control Signals :clk
//                :reset
//	          :ps_alu_en
//                :ps_alu_log
//                :ps_alu_hc     (bits 21-20) 
//                :ps_alu_sc     (bits 19-18-17)
//                :ps_alu_hc[1]   21st bit of opcode 
//                :ps_alu_sc[0]    17th bit of opcode
//                :alu_sat




//Flags:alu_ps_az(Zero)
//     :alu_ps_an(Negative)
//     :alu_ps_an(Carry)
//     :alu_ps_av(Overflow)



module alu #(parameter DATA_WIDTH)
	(clk, reset, xb_dtx, xb_dty, ps_alu_en, ps_alu_log, ps_alu_hc, ps_alu_sc, alu_xb_dt, ps_alu_sat, ps_alu_ci, alu_ps_az, alu_ps_an, alu_ps_ac, alu_ps_av, alu_ps_compd);

input clk, reset, xb_dtx, xb_dty ,ps_alu_en, ps_alu_log, ps_alu_sat, ps_alu_hc, ps_alu_sc, ps_alu_ci;
wire clk, reset, ps_alu_ci;                  
wire [(DATA_WIDTH-1):0]xb_dtx;
wire [(DATA_WIDTH-1):0]xb_dty;
wire ps_alu_en, ps_alu_log;
wire [1:0]ps_alu_hc;
wire [2:0]ps_alu_sc;
wire ps_alu_sat, alu_ps_compd;

output alu_xb_dt, alu_ps_az, alu_ps_an, alu_ps_ac, alu_ps_av, alu_ps_compd;
reg [(DATA_WIDTH-1):0]alu_xb_dt;
reg alu_ps_az,alu_ps_an,alu_ps_ac,alu_ps_av;

reg  [(DATA_WIDTH-1):0]x;
reg  [(DATA_WIDTH-1):0]y;
reg alu_en;
reg alu_log;
reg [1:0]alu_hc;
reg [2:0]alu_sc;

reg [DATA_WIDTH-1:0]value;
reg alu_sat;
wire satEn;

reg [DATA_WIDTH-1:0] a, b;
wire [DATA_WIDTH-1:0] sum, cout;

always@(posedge clk or negedge reset)
begin
	if(~reset)
	      	alu_en = 1'b0;
	else
		alu_en <= ps_alu_en; 
end

always@(posedge clk or negedge reset)
begin
	if(~reset)
	begin
		alu_log <= 1'b0;
            	alu_hc <= 2'b00;
        	alu_sc <= 3'b000;
    	end
        else 
		if(ps_alu_en)
                begin
                      alu_log <= ps_alu_log;
                      alu_hc <= ps_alu_hc;
                      alu_sc <= ps_alu_sc;
                end 
end


always@(posedge clk or negedge reset)
begin
        if(~reset)
	begin
                x<=16'h0001;
                y<=16'h0000;
        end 
      	
	else
        begin
		x <= ps_alu_en? xb_dtx:x;
		y <= (ps_alu_en&~ps_alu_hc[1])? xb_dty:y;
        end
end 

assign alu_ps_compd = {alu_log,alu_hc,alu_sc}==6'b000101 & alu_en;

always@(*)
begin
	if(alu_log) 
	begin
		case(alu_hc)
 			2'b00: 
				case(alu_sc[1:0]) 
                                	2'b00:  //Rx AND Ry
			                        alu_xb_dt=x&y;
                                                
			                2'b01:	//Rx OR Ry
			                        alu_xb_dt=x|y;
                                                
			                2'b10:	//Rx XOR Ry
			                        alu_xb_dt=x^y;
                                                
					default: alu_xb_dt=16'h1;
                                endcase
			
			2'b10:  //REG_OR, REG_AND
				alu_xb_dt = alu_sc[0] ? (|x) : &x;

			2'b11:  //NOT Rx
			        alu_xb_dt=~x;

			default: alu_xb_dt=16'h1;
		endcase
	end
	
	else
	begin 
        	case(alu_hc)
			2'b00:
				begin	
					a=x;
					if(alu_sc[2])		//comp
					begin
						b=(~y)+1'b1;
						alu_xb_dt=(|sum)&~(b==16'h8000) ? sum^{{DATA_WIDTH-1{cout[DATA_WIDTH-1]^cout[DATA_WIDTH-2]}},(cout[DATA_WIDTH-1]^cout[DATA_WIDTH-2])} : sum;	//if sum is 0 then we make alu_xb_dt=sum
					end

					else
					begin
						if(alu_sc[1])	//rx+ry+ci, rx-ry+borrow(ci-1)
							b = (y^{16{alu_sc[0]}})+alu_sc[0] + (ps_alu_ci^alu_sc[0]);
						else		//rx+ry, rx-ry
							b = (y^{16{alu_sc[0]}})+alu_sc[0];
						alu_xb_dt=value;
					end
				end

			2'b01:  
				begin
					a=x;
					b=(y^{16{alu_sc[0]}})+alu_sc[0];
					if(alu_sc[1]) 	//max(rx,ry)	here we check whether x and y are same or different signs and then perform operation
						alu_xb_dt=(x[DATA_WIDTH-1]^y[DATA_WIDTH-1])?(x[DATA_WIDTH-1]?y:x):(sum[DATA_WIDTH-1]?y:x);
					else		//min(rx,ry)
						alu_xb_dt=(x[DATA_WIDTH-1]^y[DATA_WIDTH-1])?(x[DATA_WIDTH-1]?x:y):(sum[DATA_WIDTH-1]?x:y);
				end

			2'b10:	// Rn= -Rx 
				begin
					a=x^{16{alu_sc[0]}};
					b={{DATA_WIDTH-1{1'h0}},alu_sc[0]};
					alu_xb_dt=value;
				end

			2'b11:	//Rn = ABS Rx
				begin
					a=x^{16{x[DATA_WIDTH-1]}};
			        	b={{DATA_WIDTH-1{1'h0}},x[DATA_WIDTH-1]};
					alu_xb_dt=value;
				end
		endcase 
	end
end

always@(posedge clk or negedge reset)
begin
	if(~reset)
		alu_sat<=0;
	else
		alu_sat<=satEn;
end

assign satEn = alu_en ? ps_alu_sat : alu_sat;

always@(*)
begin
	// Flag Updation
	alu_ps_az = alu_xb_dt==16'h0;
	alu_ps_an = alu_xb_dt[DATA_WIDTH-1];

	//AC is reset for logical, COMP, MIN and MAX instructions
	alu_ps_ac = cout[DATA_WIDTH-1] & (~alu_log) & (~(
		{alu_log,alu_hc,alu_sc}==6'b000_101 | 
		{alu_log,alu_hc,alu_sc}==6'b001_001 | 
		{alu_log,alu_hc,alu_sc}==6'b001_011 ));
		//{alu_log,alu_hc,alu_sc[2:1]}==6'b001_100 ));

	//AV is reset for all logical, COMP, MIN and MAX instructions	(NOTE: AV flag shows overflow of value before saturation)
	alu_ps_av = (cout[DATA_WIDTH-1]^cout[DATA_WIDTH-2]) & (~alu_log) & (~(
		{alu_log,alu_hc,alu_sc}==6'b000_101 | 
		{alu_log,alu_hc,alu_sc}==6'b001_001 | 
		{alu_log,alu_hc,alu_sc}==6'b001_011 )) ;
	
	//Saturation	       
	if(satEn) 
	begin
		if(alu_ps_av) 
                begin
			if(sum[DATA_WIDTH-1])
				value = 16'h7fff;
			else
				value = 16'h8000;
                end 
	end
	
	else
		value=sum;
end

genvar i;
generate
	full_adder #(.SIZE(DATA_WIDTH)) f (a[0],b[0],1'b0,sum[0],cout[0]);
	for(i=1;i<DATA_WIDTH;i=i+1)
		full_adder #(.SIZE(DATA_WIDTH)) f (a[i],b[i],cout[i-1],sum[i],cout[i]);
endgenerate

endmodule

module full_adder # (parameter SIZE=16)
	(
		input wire a,b,c,
		output wire sum,cout
	);
	assign sum=a^b^c;
	assign cout=(a&b)|(b&c)|(a&c);
endmodule


/*module afinalbench #(parameter DATA_WIDTH=16)();
reg  clk;
reg reset;
reg  [DATA_WIDTH-1:0] xb_dtx;
reg  [DATA_WIDTH-1:0] xb_dty;
reg ps_alu_en ;
reg ps_alu_log;
reg ps_alu_sat;
reg [1:0]ps_alu_hc;
reg [2:0]ps_alu_sc;
wire alu_ps_az;
wire alu_ps_an;
wire alu_ps_ac;
wire alu_ps_av;
wire [(DATA_WIDTH):0]value;
wire  [(DATA_WIDTH-1):0]x;
wire [(DATA_WIDTH-1):0]y;
wire alu_en;
wire alu_log;
wire [1:0]alu_hc;
wire [2:0]alu_sc;

wire signed [DATA_WIDTH-1:0]alu_xb_dt;


alu_final aft_bench(clk, reset, xb_dtx, xb_dty, ps_alu_en, ps_alu_log, ps_alu_hc, ps_alu_sc, alu_xb_dt, ps_alu_sat, alu_ps_az, alu_ps_an, alu_ps_ac, alu_ps_av);



initial begin
clk=1;
forever begin
#5 clk=~clk;
end
end 


initial begin
reset=0;
#5 reset=~reset;
end 



initial
begin
 
	ps_alu_en=0;
               
       #21 ps_alu_en = 1;
		 
//$urandom_range(1,0);                                                          

end 




initial
begin
 
	ps_alu_log =1;
              
               #21 ps_alu_log = 0;  
       #21 ps_alu_log = 1;                                       
                      
end

initial
begin
 
	ps_alu_sat=0;
	#21
                forever begin
                        
                   #10 ps_alu_sat =$urandom_range(1,0);                                                          
                        end

end 


 

initial
begin
        #21
	ps_alu_hc=2'b00;

                forever begin
                        
                   #10 ps_alu_hc = 2'b11;
                   #10 ps_alu_hc = 2'b00;
                   #10 ps_alu_hc = 2'b00;
                   #10 ps_alu_hc = 2'b00;
                   #10 ps_alu_hc = 2'b00;
                   #10 ps_alu_hc = 2'b00;
                                                         
                        end

end 

initial
begin
          #21
	ps_alu_sc=3'b101;
                forever begin
                        
                   #10 ps_alu_sc = 3'b001;
                   #10 ps_alu_sc = 3'b101;
                   #10 ps_alu_sc = 3'b001;
                   #10 ps_alu_sc = 3'b010;
                   #10 ps_alu_sc = 3'b010;
                   #10 ps_alu_sc= 3'b000;
                                                         
                        end

end 


initial
begin
	 #21
      xb_dtx=16'h8000;
               forever begin 
            #10 xb_dtx= 16'hb102;
            #10 xb_dtx= 16'h0005;
            #10 xb_dtx= 16'h0004;
            #10 xb_dtx= 16'h0005;
            #10 xb_dtx= 16'h0006;
            #10 xb_dtx= 16'h0007;
            #10 xb_dtx= 16'h0008;
            #10 xb_dtx= 16'h0009;
                      end                                                                                   //$urandom_range(0,600); end 
end


initial
begin
	 #21
      xb_dty= 16'hc039;
             forever begin 
            #10 xb_dty=  16'h0002;
            #10 xb_dty=  16'h0073;
            #10 xb_dty=  16'h0001;
            #10 xb_dty=  16'h0d03;
            #10 xb_dty=  16'h00e4;
            #10 xb_dty=  16'h0d07;
            #10 xb_dty=  16'h0f08;
            #10 xb_dty=  16'h0006;                                                                         //$urandom_range(0,600); end 
                    end
end


endmodule */

