`ifndef __spi_intf
`define __spi_intf

interface spi_interface;
  logic clk_i; 
  logic reset_n;
  logic  sclk; 
  logic  mosi;
  logic  miso;
  logic  cs;
  logic  spi_done
;
  
 import uvm_pkg::*;
      
//ASERTII
      
endinterface


`endif