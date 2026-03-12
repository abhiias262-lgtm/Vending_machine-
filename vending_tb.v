// --------------------------------------------------------------
// testbench for vending machine
// --------------------------------------------------------------
module machine_tb;
    reg clk,rst,cancel,confirm;
    reg [1:0]coin,product;
    reg [2:0]quantity;
    wire [7:0]change;
    wire deliver;
    wire timeout;

    machine dut(.clk(clk),.rst(rst),.cancel(cancel),.confirm(confirm),.coin(coin),
                .product(product),.quantity(quantity),.change(change),.deliver(deliver),.timeout(timeout));

    initial begin
        $display("--------------------- user menu ------------------");
        $display("--------------------------------------------------");
        $display("products available:");
        $display("selest 1 for product A:  10");
        $display("selest 2 for productB:  15");  
        $display("selest 3 for productC:  20");
        $display("--------------------------------------------------");
        $display("coins accepted:");
        $display("5, 10, 20");   
        $display("--------------------------------------------------");
        $display("To select product, use: product_choice(product_code)");
        $display("To select quantity, use: quantity_choice(quantity)");
        $display("To insert coin, use: insert_coin(coin_code)");
        $display("To confirm purchase, use: confirm_purchase()");
        $display("To cancel purchase, use: cancel_purchase()");
        $display("--------------------------------------------------");
    end

    initial clk=0;
    always #5 clk = ~clk;

// ------------------------------------------------------
// insert coin as pulse input and then release it to 0 in next clock cycle.
// ----------------------------------------------------
    task insert_coin(input [1:0] c);
    begin
        if (c == 2'b01 )
            $display("Inserting coin: 5");
        else if (c == 2'b10)
            $display("Inserting coin: 10");
        else if (c == 2'b11)
            $display("Inserting coin: 20");
        else
            $display("Invalid coin code: %b", c);
        coin = c;     // coin pulse
        @(posedge clk);
        coin = 2'b00; // release
        @(posedge clk);
    end
    endtask

    // ----------------------------------------------------
    // confirm purchase will be taken as pulse and then it will be released to 0 in next clock cycle.
    // ----------------------------------------------------
    task confirm_purchase;
    begin
        confirm = 1;
        repeat(2) @(posedge clk);
        $display("Purchase confirmed");
        confirm = 0;
        @(posedge clk);
    end
    endtask

    // ----------------------------------------------------
    // product and quantity will be selected by user and it will be held until user change it.
    // ----------------------------------------------------
    task product_choice(input[1:0] p);
        begin
            product=p;
            @(posedge clk);
            $display("Selected product: %d", p);
        end
    endtask

    // ----------------------------------------------------
    // quantity will be selected by user and it will be held until user change it. max quantity is 4
    // ----------------------------------------------------
    task quantity_choice(input[2:0] q);
        begin
            quantity=q;
             @(posedge clk);
            $display("Selected quantity: %d", q);
        end
    endtask

    // ----------------------------------------------------
    // cancel purchase will be taken as pulse and then it will be released to 0 in next clock cycle.
    // ----------------------------------------------------
    task cancel_purchase;begin
        cancel=1;
        repeat(2) @(posedge clk);
        $display("Purchase cancelled");
        cancel=0;
         @(posedge clk);
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

    $display("--------------------------------------------------------------");
    // test case 1
        $display("\n--- Test Case 1: Successful purchase with change ---");
        @(posedge clk);
        product_choice(2'b10);
        @(posedge clk);
        quantity_choice(3'd3);
        @(posedge clk);
        insert_coin(2'b01);
        insert_coin(2'b01);
        insert_coin(2'b10);
        insert_coin(2'b11);
        insert_coin(2'b11);
        insert_coin(2'b11);
        confirm_purchase();
        repeat(4) @(posedge clk);
        $display("Expected: deliver=1, change=35");
    $display("--------------------------------------------------------------");


    // test case 2
        $display("\n--- Test Case 2: Insufficient funds ---");
        @(posedge clk);
        product_choice(2'b11);
         @(posedge clk);
        quantity_choice(3'd2);
        @(posedge clk);
        insert_coin(2'b11);
        insert_coin(2'b01);
        insert_coin(2'b10);
        confirm_purchase();    // confirm without inserting full amount  
        repeat(4) @(posedge clk);
        $display("Expected: deliver=0, change = 35 ");
    $display("--------------------------------------------------------------");


    // test case 3
        $display("\n--- Test Case 3: Cancel purchase ---");
        @(posedge clk);
        product_choice(2'b10);
        @(posedge clk);
        quantity_choice(3'd4);
        @(posedge clk);
        insert_coin(2'b01);
        insert_coin(2'b01);
        // Cancel purchase before inserting full amount
        cancel_purchase();
        repeat(4) @(posedge clk);
        $display("Expected: deliver=0, change=10 (refund of inserted coins) ");
    $display("--------------------------------------------------------------");


    // test case 4
        $display("\n--- Test Case 4: Timeout ---");
        @(posedge clk);
        product_choice(2'b10);
         @(posedge clk);
        quantity_choice(3'd2);
        @(posedge clk);
        insert_coin(2'b11);
        insert_coin(2'b01);
        insert_coin(2'b10);
        // Wait for timeout (15 cycles of inactivity)
        $display("Waiting for timeout...");
        repeat(16) @(posedge clk);
    $display("--------------------------------------------------------------");


    //  test case 5
        $display("\n--- Test Case 5: Cancel after inserting full amount ---");
        @(posedge clk);
        product_choice(2'b01);
         @(posedge clk);
        quantity_choice(3'd4);
        @(posedge clk);
        insert_coin(2'b11);
        insert_coin(2'b11);
        cancel_purchase(); // Cancel after inserting full amount
        repeat(4) @(posedge clk);
        $display("Expected: deliver=0, change=40 (refund of inserted coins) ");

        repeat(50) @(posedge clk);
        $finish;
    end


    initial begin
    $dumpfile("machine.vcd");   // waveform file
    $dumpvars(0, machine_tb);   // dump all signals
    end


    always @(posedge clk) begin
        if ( (timeout && (change != 0)) || (deliver && (change != 0)) || (cancel && (change != 0)) || (confirm && (change != 0)) ) begin
            $display("T=%0t  | deliver=%b | change=%0d |",$time, deliver, change);
        end
    end

endmodule