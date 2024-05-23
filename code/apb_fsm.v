module apb_fsm(
    input valid,
    input [31:0] haddr_1,
    input [31:0] haddr_2,
    input [31:0] hwdata_1,
    input [31:0] hwdata_2,
    input hwrite_reg,
    input temp_selx,
    input hclk,
    input hreset,
    input hwrite,
    input [31:0] prdata,
    output reg [31:0] paddr,
    output reg pwrite,
    output reg [31:0] pwdata,
    output reg penable,
    output reg pselx,
    output reg hready_out,
    output [1:0] hresp,
    output [31:0] hrdata,
    input pready
    );

//STATES OF FSM 
parameter ST_IDLE    =3'b000,
          ST_WWAIT   =3'b001,
	      ST_READ    =3'b010,
	      ST_WRITE   =3'b011,
		  ST_WRITEP  =3'b100,
		  ST_RENABLE =3'b101,
	      ST_WENABLE =3'b110,
		  ST_WENABLEP=3'b111;	 

//PRESENT STATE AND NEXT STATE REGISTERS
reg [2:0] present_state,next_state;
reg [31:0] addr;


//PRESENT STATE LOGIC
always@(posedge hclk or negedge hreset)
  begin
    if(~hreset)
      present_state <= ST_IDLE;
    else
      present_state <= next_state;
  end

  
//NEXT STATE LOGIC
always@(*)
  begin:ns_block
    next_state <= ST_IDLE;//default state
    case(present_state) 
       ST_IDLE: 
         begin
           if(valid == 1 && hwrite == 0)
			  next_state <= ST_READ;
			else if(valid && hwrite)
			  next_state <= ST_WWAIT;
			else
			  next_state <= ST_IDLE;
		  end

       ST_WWAIT:
         begin
           if(valid)
			 next_state <= ST_WRITEP;
		   else
			 next_state <= ST_WRITE;
		 end

      ST_READ: next_state <= ST_RENABLE;

      ST_WRITE:
        begin
          if(valid)
			 next_state <= ST_WENABLEP;
		  else
			 next_state <= ST_WENABLE;
		end

      ST_WRITEP: next_state <= ST_WENABLEP;

      ST_RENABLE:
        begin
	if(~pready)
	next_state<=ST_RENABLE;
	else begin
           if(valid == 0)
			  next_state <= ST_IDLE;
		   if(valid == 1 && hwrite == 0)
			  next_state <= ST_READ;
		   else if(valid && hwrite)
			  next_state <= ST_WWAIT;
         end
	end

     ST_WENABLE: 
       begin
		
	if(~pready)
	next_state<=ST_WENABLE;
	else begin
         if(valid == 0)
		   next_state <= ST_IDLE;
		 if(valid == 1 && hwrite == 0)
		   next_state <= ST_READ;
		 else if(valid && hwrite)
		   next_state <= ST_WWAIT;
	   end
	end		 
    ST_WENABLEP: 
      begin
	if(~pready)
	next_state<=ST_WENABLEP;
	else begin
        if(hwrite_reg ==0)
		   next_state <= ST_READ;
		else if(hwrite_reg == 1 && valid == 0)
		  next_state <= ST_WRITE;
		else if(hwrite_reg == 1 && valid == 1)
		  next_state <= ST_WRITEP;
      	 end
	end
  endcase
end
  
  
//SIGNAL VALUES, OUTPUT LOGIC (COMBINATIONAL)
always@(*)
  begin
    paddr= 0;
    pwdata= 0;
    pwrite= 0;
    penable = 0;
    pselx = 0;
    hready_out = 0;
    case(present_state)
      ST_IDLE : hready_out= 0;
      ST_WWAIT : hready_out = 0;
      ST_READ : 
        begin
          paddr= haddr_1;
		  pselx= temp_selx;
		  hready_out = 0;
        end
      ST_RENABLE : 
        begin
          penable = 1;
		  hready_out = (next_state!=ST_RENABLE);
		  paddr = haddr_2;
		  pselx = temp_selx;
        end
      
      ST_WRITE : 
        begin
          paddr = haddr_1;
		  hready_out = 0;
		  pselx= temp_selx;
		  pwdata= hwdata_1;
		  pwrite= 1;
         end
      
      ST_WENABLE :
        begin
           paddr = haddr_1;
		   hready_out = (next_state!=ST_WENABLE);
		   pselx= temp_selx;
		   pwdata= hwdata_1;
		   pwrite= 1;
		   penable = 1;
         end
      
     ST_WRITEP :  
       begin
         paddr= haddr_2;
		 addr = paddr;
		 pselx= temp_selx;
		 pwdata = hwdata_1;
		 pwrite = 1;
       end
      
    ST_WENABLEP :
      begin
        paddr= addr;
	    hready_out = (next_state!=ST_WENABLEP);
		pselx= temp_selx;
		pwdata = hwdata_2;
		pwrite= 1;
		penable = 1;
      end
				 
  endcase
end
  
  
assign hrdata = prdata;
assign hresp  = 0;

endmodule 


