`ifndef __apb_intf
`define __apb_intf

interface apb_interface;
  logic  pclk; 
  logic  rst_n;
  logic [2:0] paddr;
  logic  psel;
  logic  penable;
  
 import uvm_pkg::*;
      
//ASERTII

//pready este de tip puls

  property pready_is_pulse;
    @(posedge pclk) pready |=> !pready;
  endproperty

  assert property (pready_is_pulse);

//pready se duce din unu in zero atunci cand psel se duce din 1 in 0
     property peady_fell_with_psel;
    @(posedge pclk) $fell(pready) |-> $fell(psel);
  endproperty

  assert property (peady_fell_with_psel); 

	//$fell 1->0
	  // $rose  0->1
	  //$changed 0 (1) -> 1 (0)
endinterface


`endif