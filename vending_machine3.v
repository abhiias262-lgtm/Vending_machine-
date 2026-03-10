// // number of product=3
// price of product = 10,15,20

// Coins allowed 5,10,20:
// no coin =00;
// coin 5 = 01;
// coin 10 = 10;
// coin 20 = 11;


//2
// now the quantity will be entered by the user 
// in this the exact amount of change will be displayed 
// purchase confirmation is required.
// product will be dispensed only when user confirms purchase by pressing dispense button
// user can cancel purchase at every moment of time even after inserting full amount 


//3
// this machine includes counter which will wait for instructions from user if it will not recieve any -
// - then cancel purchase automatically .wait for 15 unit


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
    reg [3:0]   counter;
    reg         timeout;


// counter
always @(posedge clk ) begin
    if (rst) begin
        counter <= 0;             // power-on reset
    end
    else if (current_state == IDLE) begin
        counter <= 0;             // idle → no timing
    end
    else if (coin != 2'b00) begin
        counter <= 0;             // coin activity
    end
    else if (product != 2'b00) begin
        counter <= 0;             // selection activity
    end
    else if (cancel) begin
        counter <= 0;             // manual cancel
    end
    else begin
        counter <= counter + 1;   // no activity → count time
    end


    timeout <= (counter == 4'hf);
end

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
        if (rst || cancel)begin
            amount=8'd0;
            price=8'd0;
        end
        else begin
        case (product) 
        2'b01: price=8'd10;            //how to take quantity as pulse input ??  how to rst??
        2'b10: price=8'd15;
        2'b11: price=8'd20;
        default:price=price;
        endcase 
        amount=quantity*price;
        end
 
       
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
                else if(timeout==1) begin
                    next_state=IDLE;
                end
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
                else if(confirm && credit>=amount) begin
                    deliver=1;
                    next_state=IDLE;
                end  
                else if(confirm && credit<amount) begin
                    next_state=IDLE;
                    deliver=0;
                end 
                else if(timeout==1)  next_state=IDLE;     
                
            end
        endcase
    end

    // this block will count the amount inserted by user
always @(posedge clk or posedge rst) begin
    if (rst || cancel || current_state==IDLE)
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
    if (rst || current_state==IDLE || cancel)
        change = 8'd0;
    else if (timeout) begin
        change = credit;
    end
    else if (deliver)
        change = credit - amount;
    
end
endmodule

