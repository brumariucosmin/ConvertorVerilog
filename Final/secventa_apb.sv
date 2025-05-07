`include "uvm_macros.svh"
import uvm_pkg::*;

`ifndef __input_apb_sequence
`define __input_apb_sequence

class secventa_apb_write_addr4 extends uvm_sequence #(tranzactie_apb);
  
  //noul tip de data (secventa) se adauga la baza de date UVM
  `uvm_object_utils(secventa_apb_write_addr4)
  
  function new(string name="secventa_apb_write_addr4");
    super.new(name);
  endfunction
    //se declara dimensiunea sirului
  rand int numarul_de_tranzactii;
  
  //se constrange dimensiunea sirului de tranzactii intr-un interval ales de noi
  constraint marimea_sirului_c{
    //constrangerile declarate cu cuvantul cheie "soft" se pot suprascrie ulterior
    soft numarul_de_tranzactii ==1;
  }
  function void post_randomize();
    $display("secventa_apb_write_addr4: Marimea sirului de tranzactii=%0d", numarul_de_tranzactii);
   endfunction
  
  virtual task body();
    
    //`ifdef DEBUG
    //	$display("phase_shift= ", phase_shift);
    //`endif;
    `uvm_info("secventa_apb_write_addr4", $sformatf("A inceput secventa cu dimensiunea de %-2d elemente", numarul_de_tranzactii), UVM_NONE)
    
    for (int i=0; i< numarul_de_tranzactii; i++) begin
      
      //se creaza o tranzactie folosindu-se cuvantul cheie "req"
      req = tranzactie_apb::type_id::create("req");
      
      //se incepe crearea tranzactiei
      start_item(req);
      //se genereaza random valori in intervalele de interes pt fiecare apb 
      assert (req.randomize() with {addr==4;
                                     write ==1;
                                     delay inside {[0:3]};
                                     data == 'b00000001;});
      `ifdef DEBUG
      `uvm_info("secventa_apb_write_addr4", $sformatf("La timpul %0t s-a generat elementul %0d cu informatiile:\n ", $time, i), UVM_LOW)
        req.afiseaza_informatia_tranzactiei();
      `endif;
      
      //s-a terminat crearea tranzactiei; aceasta poate pleca catre sequencer
      finish_item(req);
    end
    `uvm_info("secventa_apb_write_addr4", $sformatf("S-au generat toate cele %0d tranzactii", numarul_de_tranzactii), UVM_LOW)
  endtask
endclass
//se declara o clasa care genereaza o secventa de date
class secventa_apb_write_addr0 extends uvm_sequence #(tranzactie_apb);
  
  //noul tip de data (secventa) se adauga la baza de date UVM
  `uvm_object_utils(secventa_apb_write_addr0)
  
  function new(string name="secventa_apb_write_addr0");
    super.new(name);
  endfunction
    //se declara dimensiunea sirului
  rand int numarul_de_tranzactii;
  
  //se constrange dimensiunea sirului de tranzactii intr-un interval ales de noi
  constraint marimea_sirului_c{
    //constrangerile declarate cu cuvantul cheie "soft" se pot suprascrie ulterior
    soft numarul_de_tranzactii ==1;
  }
  function void post_randomize();
    $display("secventa_apb_write_addr0: Marimea sirului de tranzactii=%0d", numarul_de_tranzactii);
   endfunction
  
  virtual task body();
    
    //`ifdef DEBUG
    //	$display("phase_shift= ", phase_shift);
    //`endif;
    `uvm_info("secventa_apb_write_addr0", $sformatf("A inceput secventa cu dimensiunea de %-2d elemente", numarul_de_tranzactii), UVM_NONE)
    
    for (int i=0; i< numarul_de_tranzactii; i++) begin
      
      //se creaza o tranzactie folosindu-se cuvantul cheie "req"
      req = tranzactie_apb::type_id::create("req");
      
      //se incepe crearea tranzactiei
      start_item(req);
      //se genereaza random valori in intervalele de interes pt fiecare apb 
      assert (req.randomize() with {addr==0;
                                     write ==1;
                                     delay inside {[0:3]};
                                     data == 'd23;});
      `ifdef DEBUG
      `uvm_info("secventa_apb_write_addr0", $sformatf("La timpul %0t s-a generat elementul %0d cu informatiile:\n ", $time, i), UVM_LOW)
        req.afiseaza_informatia_tranzactiei();
      `endif;
      
      //s-a terminat crearea tranzactiei; aceasta poate pleca catre sequencer
      finish_item(req);
    end
    `uvm_info("secventa_apb_write_addr0", $sformatf("S-au generat toate cele %0d tranzactii", numarul_de_tranzactii), UVM_LOW)
  endtask
endclass
//se declara o clasa care genereaza o secventa de date
class secventa_apb extends uvm_sequence #(tranzactie_apb);
  
  //noul tip de data (secventa) se adauga la baza de date UVM
  `uvm_object_utils(secventa_apb)
  
  //se declara dimensiunea sirului
  rand int numarul_de_tranzactii;
  
  //se constrange dimensiunea sirului de tranzactii intr-un interval ales de noi
  constraint marimea_sirului_c{
    //constrangerile declarate cu cuvantul cheie "soft" se pot suprascrie ulterior
    soft numarul_de_tranzactii inside {[10:10+5]};
  }
  
  function new(string name="secventa_apb");
    super.new(name);
  endfunction
    
  function void post_randomize();
    $display("SECVENTA_apb: Marimea sirului de tranzactii=%0d", numarul_de_tranzactii);
   endfunction
  
  virtual task body();
    
    //`ifdef DEBUG
    //	$display("phase_shift= ", phase_shift);
    //`endif;
    `uvm_info("SECVENTA_apb", $sformatf("A inceput secventa cu dimensiunea de %-2d elemente", numarul_de_tranzactii), UVM_NONE)
    
    for (int i=0; i< numarul_de_tranzactii; i++) begin
      
      //se creaza o tranzactie folosindu-se cuvantul cheie "req"
      req = tranzactie_apb::type_id::create("req");
      
      //se incepe crearea tranzactiei
      start_item(req);
      //se genereaza random valori in intervalele de interes pt fiecare apb 
      assert (req.randomize() with {addr inside {[0:4]};
                                     write inside {[0:1]};
                                     delay inside {[0:3]};});
      `ifdef DEBUG
      `uvm_info("SECVENTA_apb", $sformatf("La timpul %0t s-a generat elementul %0d cu informatiile:\n ", $time, i), UVM_LOW)
        req.afiseaza_informatia_tranzactiei();
      `endif;
      
      //s-a terminat crearea tranzactiei; aceasta poate pleca catre sequencer
      finish_item(req);
    end
    `uvm_info("SECVENTA_apb", $sformatf("S-au generat toate cele %0d tranzactii", numarul_de_tranzactii), UVM_LOW)
  endtask
endclass
`endif
// task write_register(bit [2:0] addr, bit [7:0] data);
// 	//T1
// 	paddr <= addr;
// 	pwrite <= 1'b1;
// 	psel <= 1'b1;
// 	penable<= 1'b0;
// 	pwdata <= data;
// 	//T2
// 	penable <= 1'b1;
// 	//T3
// 	psel <= 1'b0;
// 	paddr<=1'bz;
// 	pwrite<=1'bz;
// 	penable<=1'b0;
// 	pwdata<='bz;
// endtask

// task read_register(bit [2:0] addr);
// 	//T1
// 	paddr <= addr;
// 	pwrite <= 1'b0;
// 	psel <= 1'b1;
// 	penable<= 1'b0;
// 	//T2
// 	penable <= 1'b1;
// 	//T3
// 	psel <= 1'b0;
// 	paddr<=1'bz;
// 	pwrite<=1'bz;
// 	penable<=1'b0;
// endtask
// write_register(3'd0, 8'd23);
// write_register(3'd4, 8'b00000001);
// read_register(3'd2);
// read_register(3'd0);
// read_register(3'd4);