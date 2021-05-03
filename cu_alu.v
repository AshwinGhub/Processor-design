//***************************************************************
//-----------------------------------------------------------------------------ALU HARDWARE MODULE-------------------------------------------------------------------------------------------
//***************************************************************

//Control Signals :clk
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
	(clk, xb_dtx, xb_dty, ps_alu_en, ps_alu_log, ps_alu_hc, ps_alu_sc, alu_xb_dt, ps_alu_sat, alu_ps_az, alu_ps_an, alu_ps_ac, alu_ps_av);

input clk, xb_dtx, xb_dty ,ps_alu_en, ps_alu_log, ps_alu_sat, ps_alu_hc, ps_alu_sc;      
wire clk;                                                                                        
wire [(DATA_WIDTH-1):0]xb_dtx;
wire [(DATA_WIDTH-1):0]xb_dty;
wire ps_alu_en, ps_alu_log;
wire [1:0]ps_alu_hc;
wire [2:0]ps_alu_sc;
wire ps_alu_sat;

output alu_xb_dt, alu_ps_az, alu_ps_an, alu_ps_ac, alu_ps_av;
reg [(DATA_WIDTH-1):0]alu_xb_dt;
reg alu_ps_az,alu_ps_an,alu_ps_ac,alu_ps_av;

reg  [(DATA_WIDTH):0]value;
reg  [(DATA_WIDTH-1):0]x;
reg  [(DATA_WIDTH-1):0]y;
reg alu_en;
reg alu_log;
reg [1:0]alu_hc;
reg [2:0]alu_sc;


always@(posedge clk)
begin 
          alu_en<= ps_alu_en;
end 

always@(posedge clk)
begin
         if(ps_alu_en)
                begin
                      alu_log<= ps_alu_log;
                      alu_hc<= ps_alu_hc;
                      alu_sc<= ps_alu_sc;
                end 

end  



always@(posedge clk)
begin
		x<= ps_alu_en? xb_dtx:x;
		y<= (ps_alu_en&~ps_alu_hc[1])? xb_dty:y;

end


always@(*)
begin

          if(alu_log) 
             begin 
                                      
                      case(alu_hc)
 
                          2'b00: begin
                                  
                                     case(alu_sc) 
                                       
                                        3'b000:  //Rx AND Ry
			                          begin
				                   
				                      value=x&y;
                                                      alu_xb_dt= value;
                                                      alu_ps_an= (alu_xb_dt[DATA_WIDTH-1]==1);
                                                      alu_ps_ac =0;
                                                      alu_ps_av=0;
			                           end

			                3'b001:	//Rx OR Ry
			                          begin
				                     
				                      value=x|y;
                                                      alu_xb_dt= value;
                                                      alu_ps_an= (alu_xb_dt[DATA_WIDTH-1]==1);
                                                      alu_ps_ac =0;
                                                      alu_ps_av=0;
			                          end

			                3'b010:	//Rx XOR Ry
			                          begin
                                                     
				                      value=x^y;
                                                      alu_xb_dt= value;
                                                      alu_ps_an= (alu_xb_dt[DATA_WIDTH-1]==1);
			                              alu_ps_ac =0;
                                                      alu_ps_av=0;
                                                 end
                                     endcase 
                                   end 
 
                            2'b10:   begin 
 
                                         case(alu_sc)
                
                                         3'b000:  // REG_AND RX
                                                  begin 
                                                      
                                                      value= &x;
                                                      alu_xb_dt= value;
                                                      alu_ps_an= (alu_xb_dt[DATA_WIDTH-1]==1);
                                                      alu_ps_ac =0;
                                                      alu_ps_av=0;
                                                   end 

                                          3'b001:  // REG_OR RX
                                                  begin 
                                                     
                                                      value= |x;
                                                      alu_xb_dt= value;
                                                      alu_ps_an= (alu_xb_dt[DATA_WIDTH-1]==1);
                                                      alu_ps_ac =0;
                                                      alu_ps_av=0;
                                                   end 
                                          endcase 
 
                                      end 

                              2'b11:   begin 
 
                                          case(alu_sc)

                                             3'b000:  // NOT Rx
			                               begin				                           
				                          value=~x;
                                                          alu_xb_dt= value;
                                                          alu_ps_an= (alu_xb_dt[DATA_WIDTH-1]==1);
                                                          alu_ps_ac =0;
                                                          alu_ps_av=0;
			                               end
                                          endcase 
			                end 
                          endcase 
                      end


               else

               begin 
                   case(alu_hc)
			2'b00:	
			        begin
                                    case(alu_sc)
                                          3'b000:                     //x+y 
                                                   begin
						   value=x+ (y^{16{alu_sc[0]}}) + alu_sc[0];
						   alu_xb_dt=value;
                                                   alu_ps_an= (alu_xb_dt[DATA_WIDTH-1]==1);
                                                   alu_ps_ac= (value[DATA_WIDTH]==1);
                                                   alu_ps_av=(value[DATA_WIDTH-2]^value[DATA_WIDTH-1]==1);
			                           end

			                  3'b001:	              //x-y
			                           begin
				                   value=x+ (y^{16{alu_sc[0]}}) + alu_sc[0];
						   alu_xb_dt=value;
                                                   alu_ps_an= (alu_xb_dt[DATA_WIDTH-1]==1);
                                                   alu_ps_ac= (value[DATA_WIDTH]==1);
                                                   alu_ps_av=(value[DATA_WIDTH-2]^value[DATA_WIDTH-1]==1);
			                           end
			
			                  3'b010: 	             //x+y+CI 
			                           begin 
				                   value=x+ (y^{16{alu_sc[0]}}) + alu_sc[0]+ alu_ps_ac ;
						   alu_xb_dt=value;
                                                   alu_ps_an= (alu_xb_dt[DATA_WIDTH-1]==1);
                                                   alu_ps_ac= (value[DATA_WIDTH]==1);
                                                   alu_ps_av=(value[DATA_WIDTH-2]^value[DATA_WIDTH-1]==1);
			                           end

			                 3'b011: 	            //x-y+CI-1
			                           begin
				                   value=x+ (y^{16{alu_sc[0]}}) + alu_sc[0]+ alu_ps_ac - alu_sc[0] ;
						   alu_xb_dt=value;
                                                   alu_ps_an= (alu_xb_dt[DATA_WIDTH-1]==1);
                                                   alu_ps_ac= (value[DATA_WIDTH]==1);
                                                   alu_ps_av=(value[DATA_WIDTH-2]^value[DATA_WIDTH-1]==1);
			                           end

			                3'b101:	   begin 
                                                                    //comp(rx,ry) 
				                   if(x==y)
					             alu_ps_az=1; 
				                   else
					             alu_ps_az=0;

                                                   alu_ps_ac =0;
                                                   alu_ps_av =0;
                                                   if(x<y)
                                                      alu_ps_an = 1'b1;
                                                   else
                                                       alu_ps_an = 1'b0;

                                                   end 

                                    endcase 
			         end

                      2'b01:  begin
                                
                                case(alu_sc)

                                   3'b001: begin                                 //min(rx,ry)
				           value=x+(y^{16{alu_sc[0]}})+ alu_sc[0];	
				                begin
					           if(value[DATA_WIDTH-1]==1) begin
						         alu_xb_dt=x;
                                                         alu_ps_an= (alu_xb_dt[DATA_WIDTH-1]==1);
                                                         alu_ps_ac =0; 
                                                         alu_ps_av=0;
                                                         end 
					           else
                                                         begin
						        alu_xb_dt=y;
                                                        alu_ps_an= (alu_xb_dt[DATA_WIDTH-1]==1);
                                                        alu_ps_ac=0;
                                                        alu_ps_av=0;
                                                          end 
				                end
			                   end

                                   3'b011: begin                               //max(rx,ry)                                            
				           value=x+(y^{16{alu_sc[0]}})+ alu_sc[0];	
				                begin
					             if(value[DATA_WIDTH-1]==1) begin
						         alu_xb_dt=y;
                                                         alu_ps_an= (alu_xb_dt[DATA_WIDTH-1]==1);
                                                         alu_ps_ac=0;
                                                         alu_ps_av=0;           end 
					             else
                                                          begin 
						         alu_xb_dt=x;
                                                         alu_ps_an= (alu_xb_dt[DATA_WIDTH-1]==1);
                                                         alu_ps_ac=0;
                                                         alu_ps_av=0; end 
				                end
			                   end
                                 endcase 
                              end 


                    2'b10:  begin
                                 
                              case(alu_sc) 
                        
                                  3'b001:  begin                                // Rn= -Rx 
				           value=(x^{16{alu_sc[0]}})+ alu_sc[0];
					   alu_xb_dt=value;
                                           alu_ps_an= (alu_xb_dt[DATA_WIDTH-1]==1);
                                           alu_ps_ac= (value[DATA_WIDTH]==1);
                                           alu_ps_av=(value[DATA_WIDTH-2]^value[DATA_WIDTH-1]==1);
			                   end
                              endcase 
                            end 


		    2'b11:	                         //Rn = ABS Rx
                             begin
                                    
                                case(alu_sc)
                  
                                  3'b001:  begin 
				           if(x[DATA_WIDTH-1]==1) 
				                   begin
					              value=(x^{16{alu_sc[0]}})+ alu_sc[0];
						      alu_xb_dt=value;
                                                      alu_ps_an= (alu_xb_dt[DATA_WIDTH-1]==1);
                                                      alu_ps_ac=0;
                                                      alu_ps_av=(value[DATA_WIDTH-2]^value[DATA_WIDTH-1]==1);
					           end
				           else
				                   begin
					             value=x;
						     alu_xb_dt=value;
                                                     alu_ps_an= (alu_xb_dt[DATA_WIDTH-1]==1);
                                                     alu_ps_ac=0;
                                                     alu_ps_av=(value[DATA_WIDTH-2]^value[DATA_WIDTH-1]==1);
				                   end
			                   end
                                 endcase 
                             end 




 endcase 
 end  
end

always@(*)
begin

	begin
		                                                     //Zero Flag
			
		       alu_ps_az= (alu_xb_dt==16'h0000);
	end


	


                                                                   //Saturation 
        begin
			if(ps_alu_sat) begin

                                  if(alu_ps_av) 
                                               begin

 				                       if(value[DATA_WIDTH-1]==1)
					                        alu_xb_dt=32'h7fff;
				                       else
					                        alu_xb_dt=32'h8000;

                                                end 
                                   
			              end 
      end


end 	

endmodule
		

	
/*
module testalbench #(parameter DATA_WIDTH=16)();
reg  clk;
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


test_alu ta(clk, xb_dtx, xb_dty, ps_alu_en, ps_alu_log, ps_alu_hc, ps_alu_sc, alu_xb_dt, ps_alu_sat, alu_ps_az, alu_ps_an, alu_ps_ac, alu_ps_av);



initial begin
clk=1;
forever begin
#5 clk=~clk;
end
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
	ps_alu_hc=2'b10;

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
	ps_alu_sc=3'b001;
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
      xb_dtx=16'ha001;
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


endmodule 
*/
