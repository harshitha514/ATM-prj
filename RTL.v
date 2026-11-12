module ATM(
input clk,rst,card_in,
input [3:0]correct_pin,
input [1:0]transaction,
input [15:0]amount,
input [15:0] balance,
input balance_done,dispense_done,error_ack,pin_submit,
output dispense,balance_display,insufficient_bal,card_locked,
output reg [15:0]balance_out
);

reg [3:0]ns;
reg [3:0]ps;
reg [1:0] attempts;

parameter s0=4'b0000,s1=4'b0001,s2=4'b0010,s3=4'b0011,s4=4'b0100,s5=4'b0101,s6=4'b0110,s7=4'b0111;

always @(posedge clk) begin
	if(rst)
		ps<=s0;
	else
		ps<=ns;
end

always @(posedge clk) begin
	if(rst)
		attempts<=0;
	else if(ps==s0)
		attempts<=0;
	else if(pin_submit && ps==s1) begin
		if(correct_pin==4'b1010)
		attempts<=0;
		else if(attempts <3)
			attempts<=attempts + 1'b1;
	end
		
end

always @(posedge clk) begin
	if(rst)
		balance_out <=balance;
	else if(ps==s5 && dispense_done)
		balance_out<=balance_out - amount;
end


always @(*) begin
	ns=ps;
	case(ps)
		s0: begin
			if(card_in)
				ns=s1;
			else
				ns=s0;
		end
		s1: begin
			if(pin_submit) begin
				if(correct_pin==4'b1010) 
					ns=s2;
				else if(attempts == 2)
					ns=s7;
				else
					ns=s1;
				end
			end
			s2: begin
				case(transaction)
					2'b00: ns =s3;
					2'b01: ns = s4;
					2'b10: ns = s2;
					default: ns = s2;
				endcase
			end
			s3: begin
				if(balance_done)
					ns=s2;
			end
			s4:  begin
				if(amount<=balance_out)
					ns=s5;
				else if(amount>balance_out)
					ns=s6;
			end
			s5: begin
				if(dispense_done)
					ns=s2;
			end
			s6: begin
				if(error_ack)
					ns=s2;
			end
			s7: begin
				ns=s7;
			end
			default:
				ns=s0;
		endcase
	end
assign dispense = (ps==s5);
assign balance_display= (ps==s3);
assign insufficient_bal = (ps==s6);
assign card_locked = (ps==s7);
endmodule
