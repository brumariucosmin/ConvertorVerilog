`ifndef __apb_intf
`define __apb_intf

interface apb_interface;
  logic  clk; 
  logic  rst_n;
  logic [2:0] paddr;
  logic  psel;
  logic  penable;
  logic pwrite;
  logic pwdata;
  logic pslverr;
  logic prdata;
  
  
 import uvm_pkg::*;
      
//ASERTII

//pready este de tip puls

  property pready_is_pulse;
    @(posedge clk) pready |=> !pready;
  endproperty

  assert property (pready_is_pulse);

//pready se duce din unu in zero atunci cand psel se duce din 1 in 0
     property peady_fell_with_psel;
    @(posedge clk) $fell(pready) |-> $fell(psel);
  endproperty

  assert property (peady_fell_with_psel); 

	//$fell 1->0
	  // $rose  0->1
	  //$changed 0 (1) -> 1 (0)
	  
	  
// Asigură că semnalul psel este activ cu un ciclu înainte de penable
property psel_before_penable;
  @(posedge clk) $rose(psel) |-> ##1 $rose(penable);
endproperty
assert property (psel_before_penable);

// Verifică că semnalul pwrite rămâne activ pe întreaga durată a tranzacției de scriere
property pwrite_during_transaction;
  @(posedge clk) psel |-> !$isunknown(pwrite);//similar pentru pwdata 
endproperty
assert property (pwrite_during_transaction);

// Asigură că semnalul pready este activ doar la finalul tranzacției, când penable și psel nu mai sunt active.
property pready_unknown;
  @(posedge clk) (psel && !penable) |=> ##[0:$] (pready ##1 !pready && !penable && !psel);
endproperty
assert property (pready_unknown);

// Verifică faptul că semnalul pslverr este activ doar atunci când pready devine 1
property pslverr_when_pready;
  @(posedge clk) $rose(pslverr) |-> $rose(pready);
endproperty
assert property (pslverr_when_pready);

// Asigură că semnalul penable este activ doar un singur ciclu
property penable_single_cycle;
  @(posedge clk) $rose(penable) |=> $fell(penable);
endproperty
assert property (penable_single_cycle);

property psel_pwrite;
  @(posedge clk) $isunknown(pwrite)  |-> !psel;
endproperty
assert property (psel_pwrite);

endinterface


`endif