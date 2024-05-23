
// AHB MASTER
module ahb_master(input hclk,hreset,hreadyout,
                  input [31:0] hrdata,input [1:0] hresp,
                  output reg [31:0] haddr,hwdata, 
                  output reg hwrite,hreadyin,
                  output reg [1:0] htrans);


always@(negedge hreset)begin
	hwdata = 0; 
        hwrite = 0;
	hreadyin = 0;
	htrans = 0;
	
end


//HTRANS
`define IDLE 2'b00
`define BUSY 2'b01
`define SEQ 2'b10
`define NONSEQ 2'b11

  integer i;
  


//defining routines to be used by the testbench.

//SINGLE WRITE
  task single_write;
    
      @(posedge hclk);
      #1;
      haddr = 32'h0000_0002;
      hwrite = 1;
      hreadyin = 1;
      htrans = 2'b10;
      @(posedge hclk);
      #1;
      hwdata =  32'h0000_0002;
      htrans = 2'b00;
    
  endtask




//8 BURST WRITES
 task burst_write();
       @(posedge hclk);
        #1;
        hreadyin = 1;
        hwrite = 1;
        haddr = 32'h0000_0100;
        htrans = `NONSEQ;
       
	 for(i=0;i<7;i++)
                begin
                  wait(hreadyout);

                  @(posedge hclk);
                  #1;

                  hwdata = haddr;
                  haddr = haddr + 1'b1;
                  htrans = `SEQ;
                end
              wait(hreadyout);
              @(posedge hclk);
              #1;
              hwdata = haddr;
              htrans = `IDLE;

 
endtask






  
//SINGLE READ
  task single_read;
    
      @(posedge hclk);
      #1;
      haddr = 32'h0000_0002;
      hwrite = 0;
      hreadyin = 1;
      htrans = 2'b10;
      @(posedge hclk);
      #1;
      htrans = 2'd00;
    
  endtask 
  


//8 burst reads
task burst_read();
       @(posedge hclk);
      #1;
      hreadyin = 1;
      hwrite = 0;
      haddr = 32'h0000_0100;
      htrans = `NONSEQ;
      
	for(i=0;i<7;i++)
                begin
                  wait(hreadyout);
                  @(posedge hclk);
                  #1;
                  haddr = haddr + 1'b1;
                  htrans = `SEQ;
                end
               htrans = `IDLE;
endtask

 

endmodule
