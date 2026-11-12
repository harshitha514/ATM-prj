module tb;

reg clk, rst, card_in;
reg [3:0] correct_pin;
reg [1:0] transaction;
reg [15:0] amount, balance;
reg balance_done;
reg dispense_done, error_ack, pin_submit;

wire dispense;
wire balance_display;
wire insufficient_bal;
wire card_locked;
wire [15:0]balance_out;


ATM dut (
    .clk(clk),
    .rst(rst),
    .card_in(card_in),
    .correct_pin(correct_pin),
    .transaction(transaction),
    .amount(amount),
    .balance(balance),
    .balance_done(balance_done),
    .dispense_done(dispense_done),
    .error_ack(error_ack),
    .pin_submit(pin_submit),
    .dispense(dispense),
    .balance_display(balance_display),
    .insufficient_bal(insufficient_bal),
    .card_locked(card_locked),
    .balance_out(balance_out)
);


initial
    clk = 0;
always #5 clk = ~clk;

initial begin
    rst = 1;
    card_in = 0;
    correct_pin = 0;
    transaction = 2'b10;
    amount = 0;
    balance = 16'd5000;

    balance_done = 0;
    dispense_done = 0;
    error_ack = 0;
    pin_submit = 0;

    #12 rst = 0;

    // TEST 1: Card insertion
    #8 card_in = 1;
    #10 card_in = 0;


    // TEST 2: Correct PIN
    #10;
    correct_pin = 4'b1010;
    pin_submit = 1;

    #10 pin_submit = 0;

    // TEST 3: Balance enquiry
    #10 transaction = 2'b00;

    #10 transaction = 2'b10;

    #10 balance_done = 1;

    #10 balance_done = 0;

    // TEST 4: Successful withdrawal
    #10;
    amount = 16'd2000;
    transaction = 2'b01;

    #10 transaction = 2'b10;

    // Dispense state
    #20 dispense_done = 1;

    #10 dispense_done = 0;

    //$monitor("Balance = %d",balance);

    // TEST 6: Insufficient balance
    #10;
    amount = 16'd15000;
    transaction = 2'b01;

    #10 transaction = 2'b10;

    // Error acknowledgement
    #10 error_ack = 1;

    #10 error_ack = 0;

    // TEST 7: Three incorrect PIN attempts

    #10 rst = 1;

    #10 rst = 0;

    #10 card_in = 1;

    #10 card_in = 0;

    // First incorrect PIN
    #10;
    correct_pin = 4'b0001;
    pin_submit = 1;

    #10 pin_submit = 0;

    // Second incorrect PIN
    #10 pin_submit = 1;

    #10 pin_submit = 0;

    // Third incorrect PIN
    #10 pin_submit = 1;
    #10 pin_submit = 0;

    $finish;
end

initial begin
    $monitor(
        "TIME=%0t | PS=%b | NS=%b | ATTEMPTS=%d | TRANS=%b | AMOUNT=%d | BALANCE=%d | BALANCE_OUT=%d | DISPENSE=%b | INSUFFICIENT=%b | LOCKED=%b",
        $time,
        dut.ps,
        dut.ns,
        dut.attempts,
        transaction,
        amount,
        balance,
        balance_out,
        dispense,
        insufficient_bal,
        card_locked
    );
end

endmodule
