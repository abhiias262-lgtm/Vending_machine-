// // number of product=3
// price of product = 10,15,20
// number of states =5(S0,S5,S10,S15,S20)
// Coins allowed 5,10,20:
// no coin =00;
// coin 5 = 01;
// coin 10 = 10;
// coin 20 = 11;
// sel=00=none
// sel=01=prdA
// sel=10=prdB
// sel=11=prdC


// now the quantity will be entered by the user 
// in this the exact amount of change will be displayed 
// purchase confirmation is required.
// product will be dispensed only when user confirms purchase by pressing dispense button
// user can cancel purchase at every moment of time even after inserting full amount 

`timescale 1ns/1ns
module machine(
    input           clk,
    input           rst,
    input           cancel,
    input           confirm,  //after inserting full amount confirm purchase
    input  [1:0]    product,  // A or B or C
    input  [2:0]    quantity,    //Max 4
    input  [1:0]    coin,
    output reg      deliver,
    output reg [7:0]   change
);

    // products
    parameter A=2'b01,B=2'b10,C=2'b11;

    // states 
    parameter IDLE=2'd0, INSERT=2'd1,
            COMPARE=2'd2,DISPENSE=2'd3;

    
    reg [7:0]   price;          //price of product
    reg [7:0]   amount;         //it is the cost of all product. 
    reg [7:0]   credit;         //keep track of amount inserted by user (coin)
    reg [1:0]   current_state;
    reg [1:0]   next_state;



// here, state will be updated after every clock pulse 
    always @(posedge clk or posedge rst) begin
        if(rst)begin
            current_state<=IDLE;
        end
        else 
            current_state<=next_state;
        end
    

// amount calculation
    always @(*) begin
        amount=0; 
        price=8'd0; 
        case (product)
        2'b01: price=8'd10;            //how to take quantity as pulse input ??  how to rst??
        2'b10: price=8'd15;
        2'b11: price=8'd20;
        endcase  
        amount=quantity*price;
        end
    

//   state transition 
    always @(*) begin
        next_state=current_state;           //it is default case if nothing is inserted then remain in same state.
        deliver=0;
        case (current_state)  
            IDLE:begin
                if (product != 2'b00)
                    next_state=INSERT;
                end
            INSERT:begin
                if(cancel)      next_state=IDLE;
                else if(coin != 2'b00) begin
                    next_state=COMPARE;
                end
                // counter aayega yahan 
            end
            COMPARE:begin
                if(cancel)      next_state=IDLE;
                else if(credit<amount)begin
                    next_state=INSERT;
                end
                else begin
                    next_state=DISPENSE;
                end

            end
            DISPENSE:begin
                if(cancel)      next_state=IDLE; 
                else if(confirm) begin
                    deliver=1;
                    next_state=IDLE;
                end         
                // add counter in this state
            end
        endcase
    end

    // this block will count the amount inserted by user
always @(posedge clk or posedge rst) begin
    if (rst || cancel || (current_state == DISPENSE && confirm))
        credit <= 8'd0;
    else begin
        case (coin)
            2'b01: credit <= credit + 8'd5;
            2'b10: credit <= credit + 8'd10;
            2'b11: credit <= credit + 8'd20;
            default: credit <= credit;
        endcase
    end
end


    // it should be clocked ultimately output 
always @(*) begin
    if (rst)
        change = 8'd0;

    else if (deliver)
        change = credit - amount;
    else
        change = change;  // hold
    end
endmodule

module machine_tb;
    reg clk,rst,cancel,confirm;
    reg [1:0]coin,product;
    reg [2:0]quantity;
    wire [7:0]change;
    wire deliver;

    machine dut(.clk(clk),.rst(rst),.cancel(cancel),.confirm(confirm),.coin(coin),
                .product(product),.quantity(quantity),.change(change),.deliver(deliver));

    initial clk=0;
    always #5 clk = ~clk;

    task insert_coin(input [1:0] c);
    begin
        coin = c;     // coin pulse
        @(posedge clk);
        coin = 2'b00; // release
        @(posedge clk);
    end
    endtask

    task confirm_purchase;
    begin
        confirm = 1;
        @(posedge clk);
        confirm = 0;
    end
    endtask

    // ---------------- TEST SEQUENCE ----------------
    initial begin
        // Defaults
        rst = 1;
        cancel = 0;
        confirm = 0;
        coin = 0;
        product = 0;
        quantity = 0;

        // Reset
        repeat(2) @(posedge clk);
        rst = 0;

        @(posedge clk);
        product  = 2'b10;
        quantity = 3'd4;


        insert_coin(2'b01);
        insert_coin(2'b01);
        insert_coin(2'b10);
        insert_coin(2'b11);
        insert_coin(2'b11);
        insert_coin(2'b11);

        // Confirm purchase
        confirm_purchase();

        // Wait and finish
        repeat(4) @(posedge clk);
        $finish;
    end

    initial begin
    $dumpfile("machine.vcd");   // waveform file
    $dumpvars(0, machine_tb);   // dump all signals
    end


// for printing single line output
always @(posedge clk) begin
    if (coin != 0 || deliver)
        $display(
            "T=%0t | credit=%0d | amount=%0d | deliver=%b | change=%0d",
            $time, dut.credit, dut.amount, deliver, change
        );
end
// for printing output at ever clk pulse
//    always @(posedge clk) begin
//     $display("T=%0t |coin=%b  |  credit=%0d | amount=%0d | deliver=%b | change=%0d",
//               $time,coin, dut.credit, dut.amount, deliver, change );
//     end

    

    
endmodule