module converter(clk, rst_n, paddr, pwdata, psel, penable, miso, pwrite, pready, prdata, mosi, cs);

  input logic clk;
  input logic rst_n;
  input logic [2:0] paddr;
  input logic [7:0] pwdata;
  input logic psel;
  input logic penable;
  input logic miso;
  input logic pwrite;
  
  output logic pready;
  //output pslverr,
  output logic[7:0] prdata;
  output logic mosi;
  output logic cs;
  
  reg [7:0] reg_operand, reg_result, reg_control; //adresele: 0, 2, 4
  reg [2:0] cnt_spi;
 
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
			4:reg_control <= pwdata;
			default: $display("unnalocatted address");
			endcase
	always @(posedge clk or negedge rst_n)//write
		if(~rst_n)begin
			pready<=0;
			end
			else if (pready == 1)
			pready <=0;
			else if(psel && !penable)
			pready<=1;
	always @(posedge clk or negedge rst_n)//read
		if(~rst_n)begin
			pready<=0;
			end
			else if(pready == 1)
			pready <= 0;
			else if (psel && !penable)
			pready <= 1;
	always @(posedge clk or negedge rst_n)
			if(!rst_n) begin
			reg_result  <= 8'd0;
			reg_control <= 8'd0;
			mosi 		<= 1'b0; //nu transmitem nimic
			cs			<= 1'b1; //spi dezactivat
			end
			else begin
				if(reg_control[0] == 1'b1) begin //start
					reg_control[0] <= 1'b0; //reset start
					reg_control[1] <= 1'b0; //reset end
					reg_control[7] <= 1'b0; //reset error
				end
				if(reg_operand < 8'd255) begin // daca nr scris este mai mare decat 255
					reg_result <= 8'd0;
					reg_control[1] <= 1'b1;
					reg_control[7] <= 1'b1;
					cs <= 1'b1;
				end 
				else begin
					cnt_spi <= 3'd7;
					cs <= 1'b0;
				end
				if(cs == 1'b0) begin
					mosi<= reg_result[cnt_spi];
				end
				if(cnt_spi == 0) begin
					cs <= 1'b1;
					reg_control[1] <= 1'b1;
				end 
				else begin 
					cnt_spi <= cnt_spi - 1;
				end
				end
				
endmodule