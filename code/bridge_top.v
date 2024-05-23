module bridge_top(input [31:0] HADDR,
    input [31:0] HWDATA,
    input HWRITE,
    input HCLK,
    input HRESET,
    input [1:0] HTRANS,
    input HREADY,
    input [31:0] prdata,
    output [31:0] paddr,
    output  pwrite,
    output [31:0] pwdata,
    output penable,
    output pselx,
    output hready_out,
    output [1:0] hresp,
    output [31:0] hrdata,
    input pready
    );

wire VALID;
wire HWRITE_REG;
wire TEMP_SELX;

//PIPELINING REGISTERERS
wire [31:0] HADDR_1,HADDR_2,HWDATA_1,HWDATA_2;
//INSTATNTIATING AHB_SLAVE
AHB_SLAVE ahb_slave(HADDR,HWDATA,HWRITE,HCLK,HRESET,HTRANS,HREADY,VALID,HADDR_1,HADDR_2,HWDATA_1,HWDATA_2,HWRITE_REG,TEMP_SELX);
//INSTATNTIATING FSM CONTROLLER
apb_fsm fsm_controller(VALID,HADDR_1,HADDR_2,HWDATA_1,HWDATA_2,HWRITE_REG,TEMP_SELX,HCLK,HRESET,HWRITE,prdata,paddr,pwrite,
  pwdata,penable,pselx,hready_out,hresp,hrdata,pready);
  
endmodule

