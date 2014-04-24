
module t_cpu();
  wire hlt;
  reg clk, rst_n;
  
  
  cpu cpu(clk, rst_n, hlt);
  
  always 
    #4 clk = ~clk;
    
  initial begin
    clk = 1'b0;
    rst_n = 1'b0;
    #4 rst_n = 1'b1;
  end
  
  always @(hlt)
    if(hlt) $stop;
      
endmodule
