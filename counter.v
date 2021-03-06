
module Counter (
inout [7:0] DataBus,
output reg Out ,
input WriteEnable ,
input ReadEnable ,
input clk,
input gate,
input  StatusLatchFlag,
input  CounterLatchFlag,
input [5:0] ControlWord,
input ChgControlWord,
output reg [15:0] Count
);
reg [5:0] ConfigControlWord ;
reg ReadBackStatusEnable = 0 ;
reg ReadBackCounterEnable = 0 ;
reg [15:0] CE ;
//reg [15:0] Count ;
reg [15:0] HalfLife ;
reg [7:0] StatusLatch ='bz;
reg [15:0] CounterLatch='bz ;
reg [2:0] Mode;
reg NullCounterFlag;
reg Trigger;
reg [5:0] State_Reg='bz;
reg [5:0] State_Next='bz;
reg [1:0]ReadFlag=2'd3; //Both are used to Read/Write the "Least then Most" thingie
reg [1:0]WriteFlag=2'd3;
reg ReadyToRead = 0;
reg ReadyToCount=2'd0;
reg [7:0] GettingOut;
reg [1:0]ReadStatus=2'd3;//For reading either status, counter or both
assign DataBus = (ReadyToRead)? GettingOut:'bz;
always @(negedge ReadEnable)
begin
ReadyToRead = 0 ;
end
localparam Mode0 = 'd0;
localparam Mode1 = 'd1;
localparam Mode2 = 'd2;
localparam Mode3 = 'd3;
localparam Mode4 = 'd4;
localparam Mode5 = 'd5;

localparam Mode00 = 'd6;
localparam Mode01 = 'd7;
localparam Mode02 = 'd8;
localparam Mode03 = 'd9;
localparam Mode04 = 'd31;

localparam Mode10 = 'd10;
localparam Mode11 = 'd11;
localparam Mode12 = 'd12;
localparam Mode13 = 'd32;

localparam Mode20 = 'd13;
localparam Mode21 = 'd14;
localparam Mode22 = 'd15;
localparam Mode23 = 'd16;

localparam Mode30 = 'd17;
localparam Mode31 = 'd18;
localparam Mode32 = 'd19;
localparam Mode33 = 'd20;

localparam Mode40 = 'd21;
localparam Mode41 = 'd22;
localparam Mode42 = 'd23;
localparam Mode43 = 'd24;
localparam Mode44 = 'd29;
localparam Mode45 = 'd33;

localparam Mode50 = 'd25;
localparam Mode51 = 'd26;
localparam Mode52 = 'd27;
localparam Mode53 = 'd28;
localparam Mode54 = 'd30;
localparam Mode55 = 'd34;

always@(ChgControlWord)
begin
	if(ChgControlWord)
	begin
		ConfigControlWord = ControlWord;
		Mode = ConfigControlWord[3:1];
	end
end 
	
always @(Count)
begin
	if(ReadBackCounterEnable==0)
		CounterLatch = Count;
end

always@(StatusLatchFlag,CounterLatchFlag)
begin
	if(StatusLatchFlag && ReadBackStatusEnable!=1)
	begin
		ReadBackStatusEnable = 1;
		StatusLatch[5:0] = ConfigControlWord;
		StatusLatch[6] = ~ReadBackCounterEnable;
		StatusLatch[7] = Out;
	end
	
	if(CounterLatchFlag && ReadBackCounterEnable!=1)
	begin
		CounterLatch = Count;
		ReadBackCounterEnable = 1;
	end
end

always @(posedge WriteEnable)
begin
    if (WriteFlag==2'd3) 
        begin
        if (ConfigControlWord[5:4]==2'b01) 
            begin
            WriteFlag=2'd2;
            CE[15:8]=8'b0;
            end
        else if (ConfigControlWord[5:4]==2'b10)
            begin
            WriteFlag=2'd1;
            CE[15:8]=8'b0;
            end

        else if (ConfigControlWord[5:4]==2'b11)
            WriteFlag=2'd0;
        end

    if (WriteFlag==2'd0)
        begin
        CE[7:0]=DataBus[7:0];
        WriteFlag=2'd1;
        end
    else if (WriteFlag==2'd1)
        begin
        CE[15:8]=DataBus[7:0];
        WriteFlag=2'd3;
        ReadyToCount=1'b1;
        end
    else if (WriteFlag==2'd2)
        begin
        CE[7:0]=DataBus[7:0];
        WriteFlag=2'd3;
        ReadyToCount=1'b1;
        end
end

always@(posedge gate)
begin
Trigger = 1;
end

always@(posedge Trigger)
begin
	
	if(Mode==Mode4)
		Trigger = 0;
end


always @(Mode)
begin
	case(Mode)
		Mode0: 
		begin
			Out = 1'b0;
			State_Reg = Mode00;
			State_Next = Mode00;
		end
		Mode1: 
		begin
			Out = 1'b1;
            		State_Reg = Mode10;
			State_Next = Mode10;
		end
		Mode2:
		begin
			Out=1'b1;
			State_Reg = Mode20;
			State_Next = Mode20;
		end
   		Mode3:
		begin
			Out=1'b1;
			State_Reg = Mode30;
			State_Next = Mode30;
		end
   		Mode4:
		begin
			Out = 1'b1;
			State_Reg = Mode40;
			State_Next = Mode40;
		end
		Mode5:
			begin
    			Out = 1'b1;
			State_Reg = Mode50;
			State_Next = Mode50;
   			end
 	endcase
end
/*
always@( posedge WriteEnable)
begin
	if(WriteEnable && Mode==Mode)
		State_Reg = Mode00;
end
*/
always@(State_Reg,ReadyToCount,Count,Trigger)
begin
	case(State_Reg)
		Mode00:
		begin
			if(ReadyToCount==1)
				State_Next = Mode01;
			else
				State_Next = Mode00;
		end
	      	Mode01:
			State_Next = Mode02;
		Mode02:
		begin
			if(ReadyToCount)
				State_Next = Mode01;
			else if(Count>0)
				State_Next = Mode02;
			else if(Count==0)
				State_Next = Mode03;
		end
		Mode03:
			State_Next = Mode04;
		Mode04:
			if(ReadyToCount)
				State_Next = Mode01;
			else if(Count>0)
				State_Next = Mode04;
			else if(Count==0)
				State_Next = Mode03;
		Mode10:
		begin
			if(Trigger)
			begin
				Count = CE;
				Trigger = 0;
				State_Next = Mode11;
			end
			else
				State_Next = Mode10;
		end
		Mode11:
		begin
			if(Trigger)
				State_Next = Mode10;
			else if(Count<1)
				State_Next = Mode12;
			else
				State_Next = Mode11;
		end	
		Mode12:
				State_Next = Mode13;
		Mode13:
			if(Trigger)
			begin
				Count = CE;
				Trigger = 0;
				State_Next = Mode11;
			end
			else if(Count==0)
				State_Next = Mode12;
			else
				State_Next = Mode13;
		Mode20:
			if(gate)
				State_Next = Mode21;
			else
				State_Next = Mode20;
		Mode21:
			State_Next = Mode22;
		Mode22:

			if(Trigger)
			State_Next = Mode21;
			else if(Count>2)
				State_Next = Mode22;
			else if(Count<=2)
				State_Next = Mode23;
		Mode23:
			
			 if(gate==0)
				State_Next = Mode23;
			else
				State_Next = Mode21;
		Mode30:
			if(gate)
				State_Next = Mode31;
			else
				State_Next = Mode30;
		Mode31:
			State_Next = Mode32;
		Mode32:
			
			if(Trigger)
			State_Next = Mode31;
			else if(Count>0)
				State_Next = Mode32;
			else if(Count<1)
				State_Next = Mode33;
		Mode33:
			if(gate==0)
				State_Next = Mode33;
			else
				State_Next = Mode31;
		Mode40:
			if(ReadyToCount)
				State_Next = Mode44;
			else
				State_Next = Mode40;
		Mode44:
			State_Next = Mode41;
		Mode41:
			if(ReadyToCount)
				State_Next = Mode40;
			else if(Count<1)
				State_Next = Mode42;
			else
				State_Next = Mode41;
		Mode42:
			State_Next = Mode43;
		Mode43:
			if(ReadyToCount)
				State_Next = Mode40;
			else
				State_Next = Mode45;
		Mode45:
			if(ReadyToCount)
				State_Next = Mode40;
			else if(Count<1)
				State_Next = Mode42;
			else
				State_Next = Mode45;
		Mode50:
			if(Trigger)
				State_Next = Mode54;
			else
				State_Next = Mode50;
		Mode54:
			State_Next = Mode51;
		Mode51:
			if(Count<1)
				State_Next = Mode52;
		Mode52:
			State_Next = Mode53;
		Mode53:
			if(Trigger)
				State_Next = Mode54;
			else
				State_Next = Mode53;
		Mode55:
			if(Trigger)
				State_Next = Mode54;
			else if(Count<1)
				State_Next = Mode52;
			else
				State_Next = Mode55;
	endcase
end

always@(negedge clk)
begin
State_Reg = State_Next ;
end

always@(negedge clk,State_Reg)
begin
	case(State_Reg)
	Mode01:
	begin
		Out = 0;
		Count = CE;
		ReadyToCount = 0;
	end
	Mode02:
	begin
           if(gate)
               begin
               if(ConfigControlWord[0]==1'b0)
                   Count = Count-1;
               else
                   begin
                   if(Count[3:0]>4'h0)
                       Count[3:0]=Count[3:0]-1;
                   else
                       begin
                       Count[3:0]=4'h9;
                       if(Count[7:4]>4'h0)
       	                    Count[7:4]=Count[7:4]-1;
       	                else
       	                    begin
       	                    Count[7:4]=4'h9;
       	                    if(Count[11:8]>4'h0)
       	                        Count[11:8]=Count[11:8]-1;
       	                    else
       	                        begin
       	                        Count[11:8]=4'h9;
       	                        Count[15:12]=Count[15:12]-1;
       	                        end
       	                    end
       	                end
       	            end
        	end
	end
	Mode03:
	begin
		Out = 1;
		Count = (ConfigControlWord[0] == 0)? 'hFFFF:'h9999;
	end
	Mode04:
	begin
		if(gate)
               	begin
               	if(ConfigControlWord[0]==1'b0)
                   Count = Count-1;
               	else
                   begin
                   if(Count[3:0]>4'h0)
                       Count[3:0]=Count[3:0]-1;
                   else
                       begin
                       Count[3:0]=4'h9;
                       if(Count[7:4]>4'h0)
       	                    Count[7:4]=Count[7:4]-1;
       	                else
       	                    begin
       	                    Count[7:4]=4'h9;
       	                    if(Count[11:8]>4'h0)
       	                        Count[11:8]=Count[11:8]-1;
       	                    else
       	                        begin
       	                        Count[11:8]=4'h9;
       	                        Count[15:12]=Count[15:12]-1;
       	                        end
       	                    end
       	                end
       	            end
        	end
	end
	Mode10:
		ReadyToCount = 0;
	Mode11:
	begin
            Out=1'b0;
            begin
            if(ConfigControlWord[0]==1'b0)
       	     	Count = Count-1;
            else
                 begin
                 if(Count[3:0]>4'h0)
                     Count[3:0]=Count[3:0]-1;
                 else
                     begin
                     Count[3:0]=4'h9;
                     if(Count[7:4]>4'h0)
                         Count[7:4]=Count[7:4]-1;
                     else
                         begin
                         Count[7:4]=4'h9;
                         if(Count[11:8]>4'h0)
                             Count[11:8]=Count[11:8]-1;
                         else
                             begin
                             Count[11:8]=4'h9;
                             Count[15:12]=Count[15:12]-1;
                             end
                         end
                     end
                 end
             end
       	end
	Mode12: 
	begin
		Out = 1'b1;
		Count = (ConfigControlWord[0] == 0)? 'hFFFF:'h9999;
	end
	Mode13:
	begin
            begin
            if(ConfigControlWord[0]==1'b0)
       	     	Count = Count-1;
            else
                 begin
                 if(Count[3:0]>4'h0)
                     Count[3:0]=Count[3:0]-1;
                 else
                     begin
                     Count[3:0]=4'h9;
                     if(Count[7:4]>4'h0)
                         Count[7:4]=Count[7:4]-1;
                     else
                         begin
                         Count[7:4]=4'h9;
                         if(Count[11:8]>4'h0)
                             Count[11:8]=Count[11:8]-1;
                         else
                             begin
                             Count[11:8]=4'h9;
                             Count[15:12]=Count[15:12]-1;
                             end
                         end
                     end
                 end
             end
       	end
	Mode20:
		ReadyToCount = 0;
	Mode21:
	begin
		Count = CE;
		Trigger = 0;
	end
	Mode22:
	begin
            Out = 0;
            if(gate && Count>1)
                begin
                if(ConfigControlWord[0]==1'b0)
       	            Count = Count-1;
                else
                    begin
                    if(Count[3:0]>4'h0)
                        Count[3:0]=Count[3:0]-1;
                    else
                        begin
                        Count[3:0]=4'h9;
                        if(Count[7:4]>4'h0)
                            Count[7:4]=Count[7:4]-1;
                        else
                            begin
                            Count[7:4]=4'h9;
                            if(Count[11:8]>4'h0)
                                Count[11:8]=Count[11:8]-1;
                            else
                                begin
                                Count[11:8]=4'h9;
                                Count[15:12]=Count[15:12]-1;
                                end
                            end
                        end
                    end
        end
	else if(Count<=1)
		Out = 0;
        end
	Mode23:
	begin
		Out = 1;
		Trigger = 0;
		Count = CE;
	end
	Mode30:
		ReadyToCount = 0;
	Mode31:
	begin
		Count = CE;
		Trigger = 0;
		if(Count[0]==1'b1)
		begin
			if(ConfigControlWord[0]==1'b0)
				HalfLife=((Count-1)>>>1)+1;
			else
				HalfLife=(((Count[15:12]*1000+Count[11:8]*100+Count[7:4]*10+Count[3:0])-1)>>>1)+1;
		end
		else
		begin
			if(ConfigControlWord[0]==1'b0)
				HalfLife=((Count)>>>1);
			else
				HalfLife=((Count[15:12]*1000+Count[11:8]*100+Count[7:4]*10+Count[3:0])>>>1);
		end
		Out = 1;
	end
	Mode32:
	begin
	if(gate==0)
		Out = 1;
	if(Count==HalfLife && gate)
		Out = 0;
        if(gate && Count>0)
            begin
            if(ConfigControlWord[0]==1'b0)
       	        Count = Count-1;
            else
                begin
                if(Count[3:0]>4'h0)
                    Count[3:0]=Count[3:0]-1;
                else
                    begin
                    Count[3:0]=4'h9;
                    if(Count[7:4]>4'h0)
                        Count[7:4]=Count[7:4]-1;
                    else
                        begin
                        Count[7:4]=4'h9;
                        if(Count[11:8]>4'h0)
                            Count[11:8]=Count[11:8]-1;
                        else
                            begin
                            Count[11:8]=4'h9;
                            Count[15:12]=Count[15:12]-1;
                            end
                        end
                    end
                end
            end
	end
	Mode33:
	begin
	Out = 1;
	if(gate==1)
		Count = CE;
	else if(gate == 0 && Trigger == 1)
		begin
			Trigger = 0;
			Count = CE;
		end
	else if(gate==0 && Trigger ==0) 
		State_Next = Mode23 ;

	end
	/*Mode40:
	begin
		if(ReadyToCount && gate)
		begin
			Count = CE;
			ReadyToCount = 0;
		end
	end*/
	Mode44:
	begin
		Count = CE;
		ReadyToCount = 0;
	end
	Mode41:
	begin
        	Out=1;
        	if(gate && Count >0)
        		begin
        		if(ConfigControlWord[0]==1'b0)
       	        		Count = Count-1;
                	else
              		begin
                    	if(Count[3:0]>4'h0)
                    		Count[3:0]=Count[3:0]-1;
              		else
        		begin
                        	Count[3:0]=4'h9;
                        if(Count[7:4]>4'h0)
                        	Count[7:4]=Count[7:4]-1;
                        else
                        begin
                        	Count[7:4]=4'h9;
                        if(Count[11:8]>4'h0)
                        	Count[11:8]=Count[11:8]-1;
                        else
                        begin
                        	Count[11:8]=4'h9;
                        	Count[15:12]=Count[15:12]-1;
                        end
                        end
                        end
                    	end
                	end
        end
	Mode42:
		Out = 0;
	Mode43:
	begin
		Out = 1;
		Count = (ConfigControlWord[0] == 0)? 'hFFFF:'h9999;
	end
	Mode45:
	begin
		if(gate && Count >0)
        		begin
        		if(ConfigControlWord[0]==1'b0)
       	        		Count = Count-1;
                	else
              		begin
                    	if(Count[3:0]>4'h0)
                    		Count[3:0]=Count[3:0]-1;
              		else
        		begin
                        	Count[3:0]=4'h9;
                        if(Count[7:4]>4'h0)
                        	Count[7:4]=Count[7:4]-1;
                        else
                        begin
                        	Count[7:4]=4'h9;
                        if(Count[11:8]>4'h0)
                        	Count[11:8]=Count[11:8]-1;
                        else
                        begin
                        	Count[11:8]=4'h9;
                        	Count[15:12]=Count[15:12]-1;
                        end
                        end
                        end
                    	end
                	end
        end
	/*Mode50:
	begin
		if(Trigger && gate)
		begin
			Count = CE;
			Trigger = 0;
		end
	end*/
	Mode54:
	begin
		Count = CE;
		Trigger = 0;
	end
	Mode51:
	begin
        	Out=1;
        	if(gate && Count>0)
        		begin
        		if(ConfigControlWord[0]==1'b0)
       	        		Count = Count-1;
                	else
              		begin
                    	if(Count[3:0]>4'h0)
                    		Count[3:0]=Count[3:0]-1;
              		else
        		begin
                        	Count[3:0]=4'h9;
                        if(Count[7:4]>4'h0)
                        	Count[7:4]=Count[7:4]-1;
                        else
                        begin
                        	Count[7:4]=4'h9;
                        if(Count[11:8]>4'h0)
                        	Count[11:8]=Count[11:8]-1;
                        else
                        begin
                        	Count[11:8]=4'h9;
                        	Count[15:12]=Count[15:12]-1;
                        end
                        end
                        end
                    	end
                	end
        end
	Mode52:
		Out = 0;
	Mode53:
	begin
		Out = 1;
		Count = (ConfigControlWord[0] == 0)? 'hFFFF:'h9999;
	end
	Mode55:
	begin
		if(gate && Count>0)
        		begin
        		if(ConfigControlWord[0]==1'b0)
       	        		Count = Count-1;
                	else
              		begin
                    	if(Count[3:0]>4'h0)
                    		Count[3:0]=Count[3:0]-1;
              		else
        		begin
                        	Count[3:0]=4'h9;
                        if(Count[7:4]>4'h0)
                        	Count[7:4]=Count[7:4]-1;
                        else
                        begin
                        	Count[7:4]=4'h9;
                        if(Count[11:8]>4'h0)
                        	Count[11:8]=Count[11:8]-1;
                        else
                        begin
                        	Count[11:8]=4'h9;
                        	Count[15:12]=Count[15:12]-1;
                        end
                        end
                        end
                    	end
                	end
        end
endcase
end

always@(ReadEnable)
begin
if(ReadEnable)
begin
	if (ReadStatus==2'd3)
	begin
		if (ReadBackCounterEnable && ReadBackStatusEnable)
		ReadStatus=2'd0;
		else if ( ReadBackStatusEnable)
		ReadStatus=2'd1;
		else if  (ReadBackCounterEnable)
		ReadStatus=2'd2;
	end 
	if (ReadStatus==2'd0)
	begin
		GettingOut=StatusLatch;
		ReadStatus =2'd2;
		ReadBackStatusEnable = 0;
	end
	else if (ReadStatus==2'd1)
	begin
		GettingOut=StatusLatch;
		ReadStatus =2'd3;
		ReadBackStatusEnable = 0;
	end
	else if (ReadStatus==2'd2)
	begin
		if(ReadFlag==2'd3)
		begin
			if (ConfigControlWord[5:4]==2'b01) 
            		ReadFlag=2'd2;
        		else if (ConfigControlWord[5:4]==2'b10)
        		ReadFlag=2'd1;
        		else if (ConfigControlWord[5:4]==2'b11)
     			ReadFlag=2'd0;
		end
		if (ReadFlag==2'd0)
		begin
			GettingOut=CounterLatch[7:0];
			ReadFlag = 2'd1;
		end
		else if (ReadFlag==2'd1)
		begin
			GettingOut=CounterLatch[15:8];
			ReadBackCounterEnable = 0;
			ReadFlag = 2'd3;
			ReadStatus = 2'd3;
		end
		else if (ReadFlag == 2'd2)
		begin
			GettingOut=CounterLatch[7:0];
			ReadBackCounterEnable = 0;
			ReadFlag = 2'd3;
			ReadStatus = 2'd3;
		end
	end
ReadyToRead = 1 ;
end
end


endmodule 

