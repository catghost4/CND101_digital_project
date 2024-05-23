
module AHB_SLAVE(
    input [31:0] HADDR,
    input [31:0] HWDATA,
    input HWRITE,
    input HCLK,
    input HRESET,
    input [1:0] HTRANS,
    input HREADY,
    output reg VALID,
    output reg [31:0] HADDR_1,HADDR_2,HWDATA_1,HWDATA_2,
    output reg HWRITE_REG,
    output TEMP_SELX
    );

//DATA TRANSITION TYPE
parameter IDLE = 2'b00, BUSY = 2'b01, NON_SEQ = 2'b10, SEQ = 2'b11;

//PIPELINING ADDRESS, DATA AND HWRITE
always@(posedge HCLK or negedge HRESET)
  begin:pipeline_block
	  if(~HRESET)//Asynchronous Negative Reset
        begin : reset_block

        HADDR_1 <= 0;
        HADDR_2 <= 0;
        HWDATA_1 <= 0;
        HWDATA_2 <= 0;
        HWRITE_REG <= 0;
      end 

      else
        begin

       HADDR_1 <= HADDR;
       HADDR_2 <= HADDR_1;
       HWDATA_1 <= HWDATA;
       HWDATA_2 <= HWDATA_1;
       HWRITE_REG <= HWRITE;
       end
   end


//which slave to select?, since we only haveone slave, we will only have one wire which is always chosen. 
//for more slaves, add more wires and set only the chosen slave as 1.
assign  TEMP_SELX = 1'b1;


//VALID SIGNAL LOGIC
always@(*)
  begin : valid_logic
    VALID = 1'b0;
    if(HRESET)
        if((HTRANS != IDLE&& HTRANS != BUSY))
            VALID = 1'b1;
		else
		VALID = 1'b0;
  end
endmodule

