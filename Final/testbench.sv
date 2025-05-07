`include "uvm_macros.svh"
import uvm_pkg::*;

`define PERIOADA_CEASULUI 10


//`define DEBUG      //parametru folosit pentru a activa mesaje pe care noi le stabilim ca ar fi necesare doar la debug

//stabilirea semnificatiei unitatilor de timp din simulator
`timescale 1ns/1ns

//includerea fisierelor la care modulul de top trebuie sa aiba acces

`include "apb_interface_dut.sv"
`include "spi_interface_dut.sv"
`include "test_exemplu.sv"
`include "design.sv"

// Code your testbench here

module top();
   logic        clk;
   wire         rst_n;
   wire  [2:0]  paddr;
   wire         psel;
   wire         penable;
   wire [7:0]pwdata;
  wire pwrite;
  wire [7:0] prdata;
  wire pready;
  wire pslverr;
   wire         miso;
   wire         mosi;
   wire         cs;
   wire sclk;
  //sunt create instantele interfetelor (in acest proiect sunt 2 agenti, deci vor fi 2 interfete); se leaga semnalele interfetelor de semnalele din modulul de top
  apb_interface_dut intf_apb();
  assign intf_apb.pclk = clk;
  assign rst_n            = intf_apb.rst_n;
  assign psel             = intf_apb.psel;
  assign penable          = intf_apb.penable;
  assign paddr            = intf_apb.paddr;
  assign pwdata           = intf_apb.pwdata;
  assign pwrite           = intf_apb.pwrite;
  assign intf_apb.prdata  = prdata;
  assign intf_apb.pready  = pready;
  assign intf_apb.pslverr = pslverr;
  
  spi_interface_dut intf_spi();
  assign mosi =intf_spi.mosi;
  assign intf_spi.miso = miso;
  assign cs = intf_spi.cs;
  assign sclk = sclk;
  
  initial begin
    //cele 2 linii de mai jos permit vizualizarea formelor de unda (pentru a vizualiza formele de unda trebuie bifata si optiunea "Open EPWave after run" din sectiunea "Tools & Simulators" aflata in stanga paginii)
    $dumpfile("dump.vcd");
    $dumpvars;
    //se genereaza ceasul
	clk = 1;
	forever begin 
    #(`PERIOADA_CEASULUI/2)  
    clk <= ~clk;
  end
	end
  
   initial
  	begin
      //se salveaza instantele interfetelor in baza de date UVM
      uvm_config_db#(virtual apb_interface_dut)::set(null, "*", "apb_interface_dut", intf_apb);
      uvm_config_db#(virtual spi_interface_dut)::set(null, "*", "spi_interface_dut", intf_spi);
      //se ruleaza testul dorit
      run_test("test_exemplu");
  	end

  // se instantiaza DUT-ul, facandu-se legaturile intre semnalele din modulul de top si semnalele acestuia
  converter DUT(
	.clk                  (clk    ),
	.rst_n                (rst_n   ),
	.psel                 (psel    ),
	.penable              (penable ),
  .paddr                 (paddr   ),
  .pwdata               (pwdata),
  .pwrite                (pwrite),
  .prdata               (prdata),
  .pready                (pready),
  .pslverr               (pslverr),
  .mosi                  (mosi ),
  .miso                  (miso  ),
  .cs                   (cs),
  .sclk                 (sclk)
);

endmodule