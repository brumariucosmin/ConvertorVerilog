`define PERIOADA_CEASULUI 10

//`define DEBUG      //parametru folosit pentru a activa mesaje pe care noi le stabilim ca ar fi necesare doar la debug

//stabilirea semnificatiei unitatilor de timp din simulator
`timescale 1ns/1ns

//includerea fisierelor la care modulul de top trebuie sa aiba acces

`include "design.sv"
`include "counter.sv"

// Code your testbench here
module top();
   logic clk;
   logic rst_n;
   logic [2:0] paddr;
   logic psel;
   logic penable;
   logic [7:0] pwdata;
   logic pwrite;
   logic miso;
   wire pready;
   wire mosi;
   wire cs;
   wire [7:0] prdata;
   wire pslverr;
   wire sclk;
   
  //sunt create instantele interfetelor (in acest proiect sunt 2 agenti, deci vor fi 2 interfete); se leaga semnalele interfetelor de semnalele din modulul de top
 // apb_interface_dut intf_apb();
 // assign intf_apb.pclk = clk;
  //assign rst_n         = intf_apb.rst_n;
  //assign psel          = intf_apb.psel;
  //assign penable       = intf_apb.penable;
  //assign paddr         = intf_apb.paddr;
  
  
  initial begin
    //cele 2 linii de mai jos permit vizualizarea formelor de unda (pentru a vizualiza formele de unda trebuie bifata si optiunea "Open EPWave after run" din sectiunea "Tools & Simulators" aflata in stanga paginii)
   // $dumpfile("dump.vcd");	
   // $dumpvars;
    //se genereaza ceasul
	clk <= 1;
	forever begin 
    #(`PERIOADA_CEASULUI/2)  
    clk <= ~clk;
  end
	end

  // se instantiaza DUT-ul, facandu-se legaturile intre semnalele din modulul de top si semnalele acestuia
  converter DUT(
	.clk (clk),
	.rst_n (rst_n),
	.psel (psel),
	.penable (penable),
	.paddr (paddr),
	.pwdata (pwdata),
	.miso (miso),
	.pwrite (pwrite),
	.pready	(pready),
	.prdata (prdata),
	.mosi(mosi),
	.cs (cs),
	.pslverr (pslverr),
	.sclk (sclk)
);

	
task write_register(bit [2:0] addr, bit [7:0] data);
	//T1
	@(posedge clk);
	paddr <= addr;
	pwrite <= 1'b1;
	psel <= 1'b1;
	penable<= 1'b0;
	pwdata <= data;
	//T2
	@(posedge clk);
	penable <= 1'b1;
	//T3
	@(posedge clk);
	psel <= 1'b0;
	paddr<=1'bz;
	pwrite<=1'bz;
	penable<=1'b0;
	pwdata<='bz;
endtask

task read_register(bit [2:0] addr);
	//T1
	@(posedge clk);
	paddr <= addr;
	pwrite <= 1'b0;
	psel <= 1'b1;
	penable<= 1'b0;
	//T2
	@(posedge clk);
	penable <= 1'b1;
	//T3
	@(posedge clk);
	psel <= 1'b0;
	paddr<=1'bz;
	pwrite<=1'bz;
	penable<=1'b0;
endtask

initial begin
rst_n <= 0;
paddr <= 0;
pwdata <= 0;
psel <= 0;
penable <= 0;
miso <= 0; 
pwrite <= 0;

repeat(5) @(posedge clk);
rst_n <= 1;
repeat(5) @(posedge clk);
write_register(3'd0, 8'h23);
write_register(3'd4, 8'b00000001);
read_register(3'd2);
read_register(3'd0);
read_register(3'd4);

repeat(5) @(posedge clk);
write_register(3'd4, 8'b00000010);
#1000
$stop();
 end
 
endmodule