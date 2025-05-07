`include "uvm_macros.svh"
import uvm_pkg::*;

`ifndef __spi_monitor
`define __spi_monitor
//`include "tranzactie_semafoare.sv"

class monitor_spi extends uvm_monitor;
  
  //monitorul se adauga in baza de date UVM
  `uvm_component_utils (monitor_spi) 
  
  //se declara colectorul de coverage care va inregistra valorile semnalelor de pe interfata citite de monitor
  coverage_spi colector_coverage_spi; 
  
  //este creat portul prin care monitorul trimite spre exterior (la noi, informatia este accesata de scoreboard), prin intermediul agentului, tranzactiile extrase din traficul de pe interfata
  uvm_analysis_port #(tranzactie_spi) port_date_monitor_spi;
  
  //declaratia interfetei de unde monitorul isi colecteaza datele
  //virtual interfata_spi interfata_monitor_spi;
  virtual spi_interface_dut interfata_monitor_spi;
  
  tranzactie_spi starea_preluata_a_spiului, aux_tr_spi;
  
  int counter_bit_pos = 7;
  
  //constructorul clasei
  function new(string name = "monitor_spi", uvm_component parent = null);
    
    //prima data se apeleaza constructorul clasei parinte
    super.new(name, parent);
    
    //se creeaza portul prin care monitorul trimite in exterior, prin intermediul agentului, datele pe care le-a cules din traficul de pe interfata
    port_date_monitor_spi = new("port_date_monitor_spi",this);
    
    //se creeaza colectorul de coverage (la creare, se apeleaza constructorul colectorului de coverage)
    
    colector_coverage_spi = coverage_spi::type_id::create ("colector_coverage_spi", this);
    
    
    //se creeaza obiectul (tranzactia) in care se vor retine datele colectate de pe interfata la fiecare tact de ceas
    starea_preluata_a_spiului = tranzactie_spi::type_id::create("date_noi");
    
    aux_tr_spi = tranzactie_spi::type_id::create("datee_noi");
  endfunction
  
  
  //se preia din baza de date interfata la care se va conecta monitorul pentru a citi date, si se "leaga" la interfata pe care deja monitorul o contine
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if (!uvm_config_db#(virtual spi_interface_dut)::get(this, "", "spi_interface_dut", interfata_monitor_spi))
        `uvm_fatal("MONITOR_spi", "Nu s-a putut accesa interfata monitorului")
  endfunction
        
  
  
  virtual function void connect_phase (uvm_phase phase);
    super.connect_phase(phase);
    
    //in faza UVM "connect", se face conexiunea intre pointerul catre monitor din instanta colectorului de coverage a acestui monitor si monitorul insusi 
	colector_coverage_spi.p_monitor = this;
    
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    
	forever begin
       //!!!!sa astept ca datele sa fie valide
        @(posedge interfata_monitor_spi.sclk); 
        wait(interfata_monitor_spi.cs == 0); 
		for(counter_bit_pos = 7; counter_bit_pos >=0;counter_bit_pos--)begin
         //vreau sa citesc semnalul valid_i doar pe fronturile descrescatoare de ceas         //preiau datele de pe interfata de iesire a DUT-ului (interfata_semafoare)
         starea_preluata_a_spiului.data[counter_bit_pos] = interfata_monitor_spi.mosi;
          `uvm_info("MONITOR_spi", $sformatf("counter_bit_pos: %d", counter_bit_pos), UVM_NONE)
	     ////////////////////////////////////////////////////// <----- AICI;
         @(posedge interfata_monitor_spi.sclk); 
        end
       aux_tr_spi = starea_preluata_a_spiului.copy();//nu vreau sa folosesc pointerul starea_preluata_a_spiului pentru a trimite datele, deoarece continutul acestuia se schimba, iar scoreboardul va citi alte date 
       
        //tranzactia cuprinzand datele culese de pe interfata se pune la dispozitie pe portul monitorului, daca modulul nu este in reset
       port_date_monitor_spi.write(aux_tr_spi); 
       `uvm_info("MONITOR_spi", $sformatf("S-a receptionat tranzactia cu informatiile:"), UVM_NONE)
       aux_tr_spi.afiseaza_informatia_tranzactiei();
	   
       //se inregistreaza valorile de pe cele doua semnale de iesire
       colector_coverage_spi.stari_spi_cg.sample();
       
	   @(negedge interfata_monitor_spi.sclk); //acest wait il adaug deoarece uneori o tranzactie este interpretata a fi doua tranzactii identice back to back (validul este citit ca fiind 1 pe doua fronturi consecutive de ceas); in implementarea curenta nu se poate sa vina doua tranzactii back to back
       
       
     end//forever begin
  endtask
  
  
endclass: monitor_spi

`endif