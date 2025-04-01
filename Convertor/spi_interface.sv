`ifndef __spi_intf
`define __spi_intf

interface spi_interface_dut;
  logic clk; 
  logic mosi; // Data line
  logic miso; // SPI data out, spi_done se aserteaza cand a terminat de citit (8)
  logic cs;   // Chip select
  
  import uvm_pkg::*;
  
`ifndef __spi_intf
`define __spi_intf

interface spi_interface_dut;
  logic clk;
  logic reset;
  logic sclk;
  logic mosi; // Data line
  logic miso; // SPI data out, spi_done se asertează când a terminat de citit (8)
  logic cs;   // Chip select

  import uvm_pkg::*;
  
  
    property sck_unmoved_on_idle_ss_line;
    @(posedge clk) $changed(sclk) |-> !cs ;
  endproperty
  assert property (sck_unmoved_on_idle_ss_line);
  
  
  

 
endinterface

`endif

endinterface
`endif
