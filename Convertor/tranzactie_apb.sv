`ifndef __apb_transaction
`define __apb_transaction

//o tranzactie este formata din totalitatea datelor transmise la un moment dat pe o interfata
class apb_transaction extends uvm_sequence_item;
  
  
    //componenta tranzactie se adauga in baza de date
  `uvm_object_utils(tranzactie_senzor)
  
  rand bit[ADDR_WIDTH-1:0] addr;
  rand bit pwrite;
  rand bit [DATA_WIDTH-1:0] data;
  bit err;
  unsigned delay;

    //functie de afisare a unei tranzactii
  function void post_randomize();
    $display("--------- [Trans] post_randomize ------");
    //$display("\t paddr  = %0h",paddr);
    $display("\t paddr  = %0h\t pwrite = %0h\t pwdata = %0h" ,paddr,pwrite,pwdata);
    $display("-----------------------------------------");
  endfunction

  function apb_transaction copy();
    copy = new();
    copy.paddr  = this.addr;
    copy.pwrite = this.pwrite;
    copy.data = this.data;
   // copy.delay = this.delay;]
    return copy;
  endfunction
  
endclass
`endif