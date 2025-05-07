module counter(clk, rst_n, count_up_down, enable, load, data_in, count_out, terminate_cnt);
  input logic clk;
  input logic rst_n;
  input logic load;
  input logic enable;
  input logic count_up_down;
  input logic [7:0] data_in;
  
  output logic [7:0] count_out;
  output logic terminate_cnt;
  
	always @(posedge clk or negedge rst_n)
		if(~rst_n)
			count_out <= 0;
		else if(~enable)
			count_out <= count_out;
			else if(load)
				count_out = data_in;
				else if(~count_up_down && count_out !=0)
					count_out -= 1;
					else if(count_out!=0)
					count_out += 1;
	
	always @* begin
		if(count_out == 0)
			terminate_cnt <= 1;
		else
			terminate_cnt <= 0;
	end
endmodule