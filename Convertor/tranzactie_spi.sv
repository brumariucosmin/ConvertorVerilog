`include "uvm_macros.svh"
import uvm_pkg::*;

`ifndef __spi_transaction
`define __spi_transaction

//o tranzactie este formata din totalitatea datelor transmise la un moment dat pe o interfata
class tranzactie_spi extends uvm_sequence_item;
  
  //componenta tranzactie se adauga in baza de date
  `uvm_object_utils(tranzactie_spi)
  
   // Semnale pentru interfața SPI
  rand bit [7:0] data;
  
  //constructorul clasei; această funcție este apelată când se creează un obiect al clasei "tranzactie"
  function new(string name = "element_secventaa");//numele dat este ales aleatoriu, si nu mai este folosit in alta parte
    super.new(name);  
  	addr = 0;
  endfunction
  
  //functie de afisare a unei tranzactii
  function void afiseaza_informatia_tranzactiei();
    $display("\t data      = %b", data);
  endfunction
  
  function spi_transaction copy();
	copy = new();
	copy.data = this.data;
	return copy;
  endfunction

endclass
`endif

