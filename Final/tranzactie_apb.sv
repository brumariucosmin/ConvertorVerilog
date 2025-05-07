`ifndef __tranzactie_apb
`define __tranzactie_apb

//o tranzactie este formata din totalitatea datelor transmise la un moment dat pe o interfata
class tranzactie_apb extends uvm_sequence_item;
  
  
    //componenta tranzactie se adauga in baza de date
  `uvm_object_utils(tranzactie_apb)
  
  rand bit[3  -1:0] addr;
  rand bit write;// 1: tranzactie de scriere; 0: tranzactie de citire
  rand bit [8-1:0] data;
  rand bit err;
  rand int delay;
  
  
  constraint delay_c {delay inside {[1:15]};}

    //constructorul clasei; această funcție este apelată când se creează un obiect al clasei "tranzactie"
  function new(string name = "element_secventaa");//numele dat este ales aleatoriu, si nu mai este folosit in alta parte
    super.new(name);  
  	data = 0;
    addr = 0;
    write = 0;
    addr = 0;
    err = 0;
    delay = 3;
  endfunction

    //functie de afisare a unei tranzactii
  function void afiseaza_informatia_tranzactiei();
    $display("\t APB: addr  = %0h\t write = %0h\t data = %0h \t err = %0h \t delay = %0d" ,addr,write,data, err, delay);
  endfunction 

  function tranzactie_apb copy();
  tranzactie_apb transaction;
    transaction = new();
    transaction.addr  = this.addr;
    transaction.write = this.write;
    transaction.data = this.data;
    transaction.delay = this.delay;
	transaction.err = this.err;
    return transaction;
  endfunction
  
endclass
`endif