`timescale 1ns/10ps
`include "counter.v"
module Counter_tb2();


reg [5:0] ControlWord1;
reg EnableCounterLatch1;
reg EnableStatusLatch1;
reg ReadSignal1;
reg WriteSignal1;
reg clkinput1;
reg gate1;
reg ChgControlWord;
reg  [7:0] Data1i;
wire [7:0] Data1O;

wire out1;
wire  [15:0] CEoutput1;

//reg mem_oe;
assign Data1O = (WriteSignal1) ?Data1i :'bz ;	//1 is always true


Counter UUT(Data1O,out1,WriteSignal1,ReadSignal1,clkinput1,gate1,EnableStatusLatch1,
	    EnableCounterLatch1, ControlWord1, ChgControlWord,CEoutput1);
	    
localparam period=10;

always
	#(period/2) clkinput1 = ~clkinput1;

initial begin
clkinput1 = 0;
ReadSignal1 =0;
WriteSignal1 = 0;

gate1 = 0;
ControlWord1 = 'b010011;
ChgControlWord=1;
EnableCounterLatch1=0;
EnableStatusLatch1=0;
#(1*period)
ChgControlWord=0;
Data1i = 'd16;
WriteSignal1 = 1;
#(1*period)
	WriteSignal1 = 0;
#(1*period)
	gate1 = 1;
#(5*period)
	EnableCounterLatch1=1;
#(1*period)
	EnableCounterLatch1=0;
#(1*period)
ReadSignal1=1;
#(5*period)
ReadSignal1=0;
#(20*period)
$finish;
end

endmodule
