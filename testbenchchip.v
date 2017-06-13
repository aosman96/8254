`timescale 1ns/10ps
`include "Chip.v"
module TestBench_tb2();

reg RD;
reg WR;
reg CS;
reg A0;
reg A1;
reg clk1,clk2,clk3,gate0,gate1,gate2;
wire out1,out2,out3;
reg  [7:0] Datai;
wire [7:0] DataO;
//reg mem_oe;
assign DataO = (~WR) ?Datai :'bz ;//1 is always true

chip c( DataO, RD,WR, CS, A0, A1, clk1, clk2, clk3, gate0, gate1, gate2, out1, out2,out3);

localparam period=10;

always
begin
	#(period/2) clk1 = ~clk1;
	#(period/2) clk2 = ~clk2;
	#(period/2) clk3 = ~clk3;
end

initial begin
CS=0;
clk1=0;
clk2=0;
clk3=0;

gate0=0;
gate1=0;
gate2=0;
A0=1;
A1=1;
#(1*period)
	WR=0;
	RD=1;
	Datai='b00010001;       //send to control register : mode0 , binary ,least signficant byte , counter0 

#(1*period) 
	WR = 1;
	A0=0;
	A1=0;
	RD=1;
	//gate0=1;
	Datai = 'h10;   // send to counter zero 10 decimal 
#(1*period)
	WR=0;

#(1*period)
	WR = 1;
	gate0=1;
/*
#(10*period)
	WR = 0;
	Datai = 'd8;
#(1*period)
	WR = 1;
	gate0=0;
#(5*period)
	gate0=1;
*/
/*#(5*period)
	A0=1;
	A1=1;
	WR=0;
	RD=1;
	Datai='b11000010; // send Read back status and count to counter zero
	
#(2*period)	
	A0=0;
	A1=0;
	WR=1;
	RD=0;

#(1*period)
	RD = 1;
#(1*period)
	RD=0;	
#(1*period)
	RD = 1;
	A0=0;
	A1=0;
#(5*period)	
	WR=0;
	RD=1;
	Datai='d8;	//Send new configuration to counter 0 through CR
#(1*period)
	WR=1;
	gate0=0;
#(1*period)
	gate0=1;
*/
#(20*period)
	//gate0=1;



	//gate0=1;
/*
#(1*period)	
	A0=1;
	A1=1;
	WR=0;
	RD=1;
	Datai='b01111011;	//Send new configuration to counter 1 through CR
	
#(1*period) 
	A0 =1;
	A1 =0 ;
	WR =0 ;
	RD =1 ;
	Datai = 'd10 ; //send 16 decimal as lsb which is (10hex) to counter 1
		
#(1*period)
	WR=1;
#(1*period)		
 	WR = 0;
	Datai = 'd0;	
#(1*period)	
	WR = 1;
	gate1 = 1;
#(5*period)
	A0=1;
	A1=1;
	WR=0;
	RD=1;
	Datai='b01000000;	//Send Counter Latch to Counter 1

#(4*period)
	A0=1;
	A1=0;
	WR=1;
	RD=0;			//Send a read signal to counter 1 to read the latch
#(1*period)
	RD=1;
#(1*period) 
	A0=1;
	A1=1;
	WR=0;
	RD=1;
	Datai='b00010010;	//Send new configuraton to Counter 0 (Mode 1)
#(1*period)
	A0=0;
	A1=0;
	WR=0;
	RD=1;
	Datai='d5;		//Send initial count as LSB to Counter 0
	gate0 = 0;
#(1*period)
	WR = 1;
	gate0 = 1;
#(7*period)		// - Full Run, then Reactivate -->
	gate0 = 0;	// - Stop gate and acivate again -->
#(1*period)		// - Add count while counting -->
	gate0 = 1;	//
#(7*period)
	gate0 = 0;
#(1*period)
	gate0 = 1;
#(4*period)
	gate0 = 0;
#(1*period)
	gate0 = 1;
#(1*period)
	WR = 0;
	Datai = 'd10;
#(1*period)
	WR = 1;
#(15*period)
	



	
	gate0 = 0;
	A0=1;
	A1=1;
	WR=0;
	RD=1;
	Datai='b00010100;	//Send new configuraton to Counter 0 (Mode 2)
#(1*period)
	A0=0;
	A1=0;
	WR=0;
	RD=1;
	Datai='d5;		//Send initial count as LSB to Counter 0
#(1*period)
	WR = 1;
	gate0 = 1;
#(7*period)		// - Full Run, then Reactivate -->
	WR = 0;		// - Stop gate and acivate again -->
#(1*period)		// - Add count while counting -->
	WR = 1;	//
#(7*period)
	gate0 = 0;
#(1*period)
	gate0 = 1;
#(1*period)
	WR = 0;
	Datai = 'd10;
#(1*period)
	WR = 1;
#(15*period)
	

	gate0 = 0;
	A0=1;
	A1=1;
	WR=0;
	RD=1;
	Datai='b00010100;	//Send new configuraton to Counter 0 (Mode 3)
#(1*period)
	A0=0;
	A1=0;
	WR=0;
	RD=1;
	Datai='d5;		//Send initial count as LSB to Counter 0
#(1*period)
	WR = 1;
	gate0 = 1;
#(7*period)		// - Full Run, then Reactivate -->
	WR = 0;		// - Stop gate and acivate again -->
#(1*period)		// - Add count while counting -->
	WR = 1;	//
#(7*period)
	gate0 = 0;
#(1*period)
	gate0 = 1;
#(1*period)
	WR = 0;
	Datai = 'd10;
#(1*period)
	WR = 1;
#(15*period)



	gate0 = 0;
	A0=1;
	A1=1;
	WR=0;
	RD=1;
	Datai='b00010100;	//Send new configuraton to Counter 0 (Mode 4)
#(1*period)
	A0=0;
	A1=0;
	WR=0;
	RD=1;
	Datai='d5;		//Send initial count as LSB to Counter 0
#(1*period)
	WR = 1;
	gate0 = 1;
#(7*period)		// - Full Run, then Reactivate -->
	WR = 0;		// - Stop gate and acivate again -->
#(1*period)		// - Add count while counting -->
	WR = 1;	//
#(7*period)
	gate0 = 0;
#(1*period)
	gate0 = 1;
#(1*period)
	WR = 0;
	Datai = 'd10;
#(1*period)
	WR = 1;
#(15*period)


	gate0 = 0;
	A0=1;
	A1=1;
	WR=0;
	RD=1;
	Datai='b00010100;	//Send new configuraton to Counter 0 (Mode 5)
#(1*period)
	A0=0;
	A1=0;
	WR=0;
	RD=1;
	Datai='d5;		//Send initial count as LSB to Counter 0
#(1*period)
	WR = 1;
	gate0 = 1;
#(7*period)		// - Full Run, then Reactivate -->
	gate0 = 0;		// - Stop gate and acivate again -->
#(1*period)		// - Add count while counting -->
	gate0 = 1;	//
#(7*period)
	gate0 = 0;
#(1*period)
	gate0 = 1;
#(1*period)
	WR = 0;
	gate0 = 0;
	Datai = 'd10;
#(1*period)
	gate0 = 1;
*/
#(15*period)
$finish;
end

endmodule
