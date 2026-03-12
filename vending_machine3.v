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
    output       timeout,
    output reg [7:0]   change);
    
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


// -------------------------------------------------------------
// counter
//  -------------------------------------------------------------
    always @(posedge clk or posedge rst) begin
        if (rst || current_state == IDLE)
            counter <= 0;
        else if (current_state != IDLE)
            counter <= counter + 1;
    end
// Inactivity timeout counter (only counts when user is truly idle)
    reg [4:0] inactivity_cnt;          // 5 bits → up to 31 cycles, enough for 15
    reg [1:0]  prev_product;
    reg [2:0]  prev_quantity;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            prev_product   <= 0;
            prev_quantity  <= 0;
            inactivity_cnt <= 0;
        end 
        else begin
            prev_product   <= product;
            prev_quantity  <= quantity;

        if (current_state == IDLE ||
            coin != 2'b00 || cancel || confirm ||
            (product != prev_product) || (quantity != prev_quantity)) begin
            inactivity_cnt <= 0;
        end
        else if (current_state != IDLE) begin
            if (inactivity_cnt < 31)
                inactivity_cnt <= inactivity_cnt + 1;
        end
        end
    end

// Timeout signal (you can adjust threshold)
    wire timeout = (inactivity_cnt >= 15);
// ------------------------------------------------------------
// state transitions  
// ------------------------------------------------------------
    always @(posedge clk or posedge rst) begin
        if(rst)begin
            current_state<=IDLE;
        end
        else 
            current_state<=next_state;
        end
    
// -------------------------------------------------------------
// amount calculation
// -------------------------------------------------------------
    always @(*) begin
        case (product) 
            2'b01: price=8'd10;            //how to take quantity as pulse input ??  how to rst??
            2'b10: price=8'd15;
            2'b11: price=8'd20;
            default:price=price;
        endcase 
        if (quantity >= 1 && quantity <= 4 && price != 0)
            amount = price * quantity;
        else
            amount = 8'd0;
        end
 

// -------------------------------------------------------------
//   state movement and output logic 
// -------------------------------------------------------------
    always @(*) begin
        next_state=current_state;           //it is default case if nothing is inserted then remain in same state.
        deliver=0;
        case (current_state)  
            IDLE:begin
                if (product != 2'b00 && amount > 0)
                    next_state=INSERT;
                end
            INSERT:begin
                if(cancel || timeout) begin   
                    change_load = 1;
                    change_value = credit;
                    next_state=IDLE;
                end
                else if(coin != 2'b00) begin
                    next_state=COMPARE;
                end
                else if (confirm) begin
                    next_state=DISPENSE;
                end
            end
            COMPARE:begin
                if(cancel || timeout) begin
                    next_state=IDLE;
                    change_load = 1;
                    change_value = credit;
                end 
                else if (confirm) begin
                    next_state=IDLE;
                    change_load = 1;
                    change_value = credit;
                end
                else if (credit >= amount) begin
                    next_state=DISPENSE;
                end
            end
            DISPENSE:begin
                if(cancel || timeout)     begin
                    next_state=IDLE;
                    change_load = 1;
                    change_value = credit;
                end 
                else if(confirm && credit>=amount) begin
                    deliver     =1;
                    next_state  =IDLE;
                    change_load = 1;
                    change_value= credit-amount;  // return change if any

                end  
                else if(confirm && credit<amount) begin
                    next_state=IDLE;
                    change_load = 1;
                    change_value = credit;

                end 
            
            end
            default: next_state = IDLE;
        endcase
    end


// --------------------------------------------------------------
// this block will count the amount inserted by user
// --------------------------------------------------------------
    always @(posedge clk or posedge rst) begin
        if (rst || current_state==IDLE || deliver)
            credit <= 8'd0;
        else begin
            case (coin)
                2'b01: credit <= credit + 8'd5;
                2'b10: credit <= credit + 8'd10;
                2'b11: credit <= credit + 8'd20;
                default: credit <= credit; // hold previous value if no coin
            endcase
        end
    end

// ------------------------------------------------------------
// change updation logic
// ------------------------------------------------------------
    reg change_load;
    reg [7:0] change_value;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            change <= 0;
            change_load <= 0;
        end
        else if (change_load) begin
            change <= change_value;
            change_load <= 0;
        end
        else if (current_state == IDLE && inactivity_cnt == 0 && (product != 0 || quantity != 0)) begin   // new transaction starting
            change <= 0;
    end
    // otherwise hold the previous value
    end
endmodule

