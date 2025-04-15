`ifndef __spi_intf
`define __spi_intf

interface spi_interface_dut;
  logic  clk; 
  logic  mosi; //data
  logic  miso;//spi_done se aserteaza cand a terminat de citit (8)
  logic  cs;
  
 import uvm_pkg::*;
      
//ASERTII
      // asertie ca la al 8lea bit miso e 1 -> spi_done
	  // asertie ca la bit 1-7 miso e 0 
	  // asertie cat timp trimiti data cs ==0  
endinterface


`endif