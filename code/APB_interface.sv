module apb_interface(pclk,preset, penable,pwrite,
                     paddr,pwdata,
                     pselx,prdata,
                      pready);                                       

		     input pclk,preset;
		     input penable,pwrite;
                     input [31:0] paddr,pwdata;
                     input pselx;
		     output reg pready;
		     output reg[31:0] prdata; 



//storing whether we have passed the select stage or not
reg  selected = 0;

reg updateram = 0;

//storage memory of the peripheral
ram myram(pwdata,paddr,pwrite,updateram,prdata);


always@(posedge pclk,negedge preset)begin
	
	if(~preset)begin
	pready = 0;
	prdata = 0; 

	end else begin

	if(selected==1'b1)
    	begin
		if(penable)
		begin
		selected <= 1'b0;
		updateram<=1'b1;
		pready<=1'b1;
		end

   	 end

	 else  begin
	if(pselx) begin
	selected <= 1'b1;
	updateram<=1'b0;
	pready<=1'b0;
	end
	
	end
	end
end


endmodule 



//storage memory of the peripheral
module  ram(
   input      [31:0] data,
   input     [31:0] addr,
   input       we,update,
   output reg [31:0] q);


// the size of the memory is made smaller than the possible addresses for the sake of simulation
   reg        [31:0] ram[400];
   always @ (posedge update)
     begin
        if (we)
           ram[addr] <= data;

        q <=   ram[addr];          // output data - output
     end
endmodule

