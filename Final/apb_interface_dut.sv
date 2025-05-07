`ifndef __apb_intf
`define __apb_intf

interface apb_interface_dut;
  logic  pclk; 
  logic  rst_n;
  logic [2:0] paddr;
  logic  psel;
  logic  penable;
  logic [7:0]pwdata;
  logic pwrite;
  logic [7:0] prdata;
  logic pready;
  logic pslverr;
  
 import uvm_pkg::*;
      
//ASERTII
      
endinterface


`endif