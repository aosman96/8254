module ReadWrite ( input A0 ,input A1 , input CS ,input WR , input RD , output [3:0] RFlag,
output [3:0] WFlag
 );

assign RFlag =       ((RD == 1'b0 && WR == 1'b1) && {A1,A0} == 2'b00 && CS == 1'b0) ? 4'b0001 :       //counter 0
                     ((RD == 1'b0 && WR == 1'b1) && {A1,A0} == 2'b01 && CS == 1'b0) ? 4'b0010 :	      // counter 1
                     ((RD == 1'b0 && WR == 1'b1) && {A1,A0} == 2'b10 && CS == 1'b0) ? 4'b0100 : 4'b0000 ; //counter 2

assign WFlag =	     ((RD == 1'b1 && WR == 1'b0) && {A1,A0} == 2'b00 && CS == 1'b0) ? 4'b0001 : //counter 0 
                     ((RD == 1'b1 && WR == 1'b0) && {A1,A0} == 2'b01 && CS == 1'b0) ? 4'b0010 : //counter 1
                     ((RD == 1'b1 && WR == 1'b0) && {A1,A0} == 2'b10 && CS == 1'b0) ? 4'b0100 : //counter 2 
                     ((RD == 1'b1 && WR == 1'b0) && {A1,A0} == 2'b11 && CS == 1'b0) ? 4'b1000 : 4'b0000 ; //control register 
 



endmodule 
