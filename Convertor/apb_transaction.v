`ifndef __apb_transaction
`define __apb_transaction

//o tranzactie este formata din totalitatea datelor transmise la un moment dat pe o interfata
class apb_transaction extends uvm_sequence_item;
  
  
    //componenta tranzactie se adauga in baza de date
  `uvm_object_utils(tranzactie_senzor)
  
  rand bit[ADDR_WIDTH-1:0] addr;
  rand bit write;// 1: tranzactie de scriere; 0: tranzactie de citire
  rand bit [DATA_WIDTH-1:0] data;
  rand bit err;
  rand int delay;
  
  
  constraint delay_c {delay inside {[1:15]};}

    //functie de afisare a unei tranzactii
  function void post_randomize();
    $display("--------- [Trans] post_randomize ------");
    //$display("\t paddr  = %0h",paddr);
    $display("\t addr  = %0h\t write = %0h\t data = %0h \t err = %0h \t delay = %0d" ,addr,write,data, err, delay);
    $display("-----------------------------------------");
  endfunction

  function apb_transaction copy();
  apb_transaction transaction;
    transaction = new();
    transaction.paddr  = this.addr;
    transaction.write = this.write;
    transaction.data = this.data;
    transaction.delay = this.delay;
	transaction.err = this.err;
    return transaction;
  endfunction
  
endclass
`endif