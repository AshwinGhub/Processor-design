module test_core();

reg clk, reset;

core_top #(.PMA_SIZE(16), .PMD_SIZE(32), .DMA_SIZE(16), .DMD_SIZE(16), .RF_DATASIZE(16), .ADDRESS_WIDTH(4), .SIGNAL_WIDTH(3), .PM_LOCATE("C:/Users/Ashwin Pradeep/Desktop/Project Final Year/GIT repo/memory_txt_files/pm_file.txt"), .DM_LOCATE("C:/Users/Ashwin Pradeep/Desktop/Project Final Year/GIT repo/memory_txt_files/dm_file.txt"))
	core_obj	(
				clk,
				reset
			);

initial 
begin
	clk=1;
	forever begin #5 clk=~clk; end
end
	
initial
begin
	reset=1;
	#1 reset=0;
	#2 reset=1;
end

endmodule
