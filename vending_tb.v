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

    task product_choice(input[1:0] p);
        begin
            product=p;
            @(posedge clk);
            // product=2'b00;
            // repeat(2)@(posedge clk);
        end
    endtask

    task quantity_choice(input[2:0] q);
        begin
            quantity=q;
            @(posedge clk);
            // quantity=2'b00;
            // repeat(2)@(posedge clk);
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
// test case 1
        @(posedge clk);
        product_choice(2'b10);
        @(posedge clk);
        quantity_choice(3'd4);
        @(posedge clk);
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
// test case 2
        @(posedge clk);
        product_choice(2'b11);
         @(posedge clk);
        quantity_choice(3'd3);
        @(posedge clk);
        insert_coin(2'b11);
        insert_coin(2'b01);
        insert_coin(2'b10);


        // // Confirm purchase
        // confirm_purchase();




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
            "T=%0t  |credit=%0d | amount=%0d | deliver=%b | change=%0d",
            $time, dut.credit, dut.amount, deliver, change
        );
end
//for printing output at ever clk pulse
//    always @(posedge clk) begin
//     $display("T=%0t |coin=%b  |  credit=%0d | amount=%0d | deliver=%b | change=%0d",
//               $time,coin, dut.credit, dut.amount, deliver, change );
//     end
  
endmodule