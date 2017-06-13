module ControlRegister(
inout [7:0] DataBus ,  //data bus 3moman 
input WR,   // signal el write 
output  [2:0] StatusLatchFlag ,
output  [2:0] CounterLatchFlag ,
output  [5:0] ControlWord,
output  [2:0]ChgControlWord
);
//da el readback
assign CounterLatchFlag[0]= (WR == 1 &&DataBus[0]==0 && DataBus[5]==0 &&  DataBus[7:6]==2'b11 &&DataBus[1]==1 )? 1:
      (DataBus[5:4]==2'b00 && WR == 1 && DataBus[7]==0 && DataBus[6]==0 ) ? 'b1:'b0 ;  //da el latch command                                                                                           0;
assign CounterLatchFlag[1] = (WR == 1 &&DataBus[0]==0 && DataBus[5]==0 &&  DataBus[7:6]==2'b11 &&DataBus[2]==1 )?1:
      (DataBus[5:4]==2'b00 && WR == 1 &&  DataBus[6]==1 )? 'b1:'b0 ;   //da el latch command 
assign CounterLatchFlag[2] = (WR == 1 &&DataBus[0]==0 && DataBus[5]==0 &&  DataBus[7:6]==2'b11 &&DataBus[3]==1)?1:
      (DataBus[5:4]==2'b00 && WR == 1 &&  DataBus[7]==1 )? 'b1: 'b0 ; //da el latch command 
assign StatusLatchFlag[0]= (WR == 1 &&DataBus[0]==0 && DataBus[4]== 'b0 &&  DataBus[7:6]==2'b11 &&DataBus[1]==1 )?1:0;
assign StatusLatchFlag[1] = (WR == 1 &&DataBus[0]==0 && DataBus[4]==0 &&  DataBus[7:6]==2'b11 &&DataBus[2]==1 )?1:0;
assign StatusLatchFlag[2] = (WR == 1 &&DataBus[0]==0 && DataBus[4]==0 &&  DataBus[7:6]==2'b11 &&DataBus[3]==1)?1:0;





//da lw 7asal reporgaming   
assign ControlWord = DataBus[5:0];
assign ChgControlWord = (DataBus[7:6] == 2'b00 && DataBus[5:4]!=2'b00) ? 'b001 :
 			(DataBus[7:6] == 2'b01 && DataBus[5:4]!=2'b00)? 'b010 :
			(DataBus[7:6] == 2'b10 && DataBus[5:4]!=2'b00)? 'b100 :'b000 ;
endmodule 
