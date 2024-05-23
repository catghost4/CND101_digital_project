
module testbench();
  reg hclk,hreset,pclk,preset;
  wire hreadyout;
  wire [31:0] prdata;
  wire [1:0] hresp;
  wire [31:0] hrdata;
  wire [31:0] haddr,hwdata;
  wire hwrite,hreadyin;
  wire [1:0] htrans;
  
  wire penable,pwrite;
  wire pselx;
  wire [31:0] paddr,pwdata;
  wire pready;

  assign hrdata = prdata;
 
 //AHB MASTER INSTANTIATION
  ahb_master  ahb_master_dut(hclk,hreset,hreadyout,hrdata,hresp,haddr,hwdata,hwrite,hreadyin,htrans);

 //BRIDGE TOP INSTANTIATION
 bridge_top top_bridge_dut(haddr,hwdata,hwrite,hclk,hreset,htrans,hreadyin,prdata,paddr,pwrite,pwdata,penable,pselx,hreadyout,hresp,hrdata,pready);
 //APB INTERFACE INSTANTIATION
  apb_interface apb_interface_dut(pclk,preset,penable,pwrite,paddr,pwdata,pselx,prdata,pready);
  
//CLOCK GENERATION
  initial
    begin
      hclk = 1;
      forever #5 hclk = ~ hclk;      
  end

  initial
	begin
	pclk = 1;
	forever #10 pclk = ~ pclk; //the pclk period must be an integer multiple of the hclk period, and must be at least twice the value.
	end

//RESET GENERATION
  initial
    begin
      hreset = 0;
      #4;
      hreset =1;
    end

  initial
    begin
      preset = 0;
      #4;
      preset =1;
    end






//test routines
  initial
    begin

	 ahb_master_dut.single_write();

	#100;

 	ahb_master_dut.burst_write();

	#300;
	
	
      ahb_master_dut.single_read();

	#100;

      ahb_master_dut.burst_read();
	  
      @(posedge hclk);
      #300 $finish;
    end

endmodule
