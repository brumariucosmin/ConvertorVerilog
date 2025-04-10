`include "counter.sv"

module converter #(parameter bit[7:0] NO_OF_SPI_BITS = 8)(clk, rst_n, paddr, pwdata, psel, penable, miso, pwrite, pready, pslverr, prdata, mosi, old_cs, sclk);

  input logic clk;
  input logic rst_n;
  input logic [2:0] paddr;
  input logic [7:0] pwdata;
  input logic psel;
  input logic penable;
  input logic miso;
  input logic pwrite;
  
  output logic pready;
  output logic pslverr;
  output logic[7:0] prdata;
  output logic mosi;
  output logic old_cs;
  output logic sclk;
	
  reg [7:0] reg_operand, reg_result, reg_control; //adresele: 0, 2, 4
  reg [2:0] cnt_spi;
  
  reg [7:0] count_out;
  reg count_up_down;
  reg enable;
  reg load;
  reg terminate_cnt;
  reg posedge_sclk, negedge_sclk, cs_delayed;
  reg sclk_delayed;
  reg cs;
  
  counter counter_inst(
  .clk (clk),
  .rst_n(rst_n),
  .load (load),
  .enable (enable),
  .count_up_down (1'b0),
  .data_in (NO_OF_SPI_BITS-1),
  .count_out (count_out),
  .terminate_cnt (terminate_cnt)
  );
  
	always @(posedge clk or negedge rst_n)
		if(~rst_n)
			sclk <= 0;
		else if(old_cs == 0)
			sclk <= ~sclk;
			else
			sclk <= 0;
			
  always @(posedge clk or negedge rst_n)//read
	if(~rst_n)
		prdata<=0;
		else
		if(psel && !penable && !pwrite)
		case(paddr)
		0:prdata<= reg_operand;
		2: prdata<= reg_result;
		4: prdata<= reg_control;
		default: $display("unnalocatted address");
		endcase
	always @(posedge clk or negedge rst_n)//write
		if(~rst_n)begin
			reg_operand<=0;
			reg_result<= 0;
			reg_control<=0;
			end
			else if(psel && !penable && pwrite)
			case(paddr)
			0:begin
			reg_operand <= pwdata;
			reg_result <= pwdata ^ (pwdata >> 1);
			end
		//	2: reg_result<= pwdata;
			2: $warning("read_only_register");
			4:reg_control <= pwdata;
			default: $display("unnalocatted address");
			endcase
			
			
			
	always @(posedge clk or negedge rst_n)//write
		if(~rst_n)begin
			reg_control<=0;
			end
			else if(psel && !penable && pwrite && paddr ==4)
			reg_control <= pwdata;
			else 
			    begin 
				   if(reg_control[0] == 1'b1)  //start
					    reg_control[0] <= 1'b0; //reset start
					if(reg_control[1] == 1'b1)  //stop
					   reg_control[1] <= 1'b0; //reset stop
					   
				 //  reg_control[1] <= old_cs;
				 if(reg_control[1] == 1 && terminate_cnt==0)
				 reg_control[7] <= 1;
			    end
				
							
	always @(posedge clk or negedge rst_n)//old_cs
		if(~rst_n)
			old_cs<= 1;
			else if(reg_control[0] == 1)
			old_cs <= 0;
			else if(reg_control[1] == 1 || count_out == 0)
			old_cs <= 1;
			
			
		always @(posedge clk or negedge rst_n)//cs_delayed
		if(~rst_n)
			cs_delayed<= 1;
			else
			cs_delayed <= old_cs;
			
			assign cs = cs_delayed & old_cs;
			
			assign enable = (~old_cs & negedge_sclk) | load;//cand old_cs nu este activat, nici counter-ul nu numara
			
	always @(*)//mosi
	begin
		 if(old_cs == 0 && posedge_sclk )
			mosi <= reg_result[count_out];
			else if (cs ==1)
			mosi <= 1'bz;
	end		
			
			
	always @(posedge clk or negedge rst_n)//sclk intarziat
		if(~rst_n)
			sclk_delayed<= 0;
			else 
			sclk_delayed <= sclk;
			
	  assign posedge_sclk = sclk & ~sclk_delayed;
	  assign negedge_sclk = ~sclk & sclk_delayed;
	assign load = reg_control[0];
			
	always @(posedge clk or negedge rst_n)
		if(~rst_n)
			pready<=0;
			
			else if (pready == 1)
			pready <=0;
			else if(psel && !penable)
			pready<=1;
			
	always @(posedge clk or negedge rst_n)//pslverr (in caz ca nu accesam o adresa corecta)
		if(~rst_n)
			pslverr<=0;
			
			else if(pslverr == 1)
			pslverr <= 0;
			else if (psel && !penable && (!(paddr == 0 ||paddr == 2 || paddr ==4)||(paddr==2 && pwrite ==1)))
			pslverr <= 1;
			/*
	always @(posedge clk or negedge rst_n)
			if(!rst_n) begin
			mosi 		<= 1'b0; //nu transmitem nimic
			old_cs			<= 1'b1; //spi dezactivat
			end
			else begin
				end
				if(reg_operand < 8'd255) begin // daca nr scris este mai mare decat 255
					reg_result <= 8'd0;
					reg_control[1] <= 1'b1;
					reg_control[7] <= 1'b1;
					old_cs <= 1'b1;
				end 
				else begin
					cnt_spi <= 3'd7;
					old_cs <= 1'b0;
				end
				if(old_cs == 1'b0) begin
					mosi<= reg_result[cnt_spi];
				end
				if(cnt_spi == 0) begin
					old_cs <= 1'b1;
					reg_control[1] <= 1'b1;
				end 
				else begin 
					cnt_spi <= cnt_spi - 1;
				end
				end*/
				
endmodule