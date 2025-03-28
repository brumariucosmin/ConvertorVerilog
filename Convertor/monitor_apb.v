//componenta nu a fost adaptata acestui mediu de verificare
`ifndef __monitor_apb
`define __monitor_apb
`include "apb_transaction.sv"



class monitor_apb extends uvm_monitor;
  
  //monitorul se adauga in baza de date UVM
  `uvm_component_utils (monitor_apb) 
  
  //se declara colectorul de coverage care va inregistra valorile semnalelor de pe interfata citite de monitor
  coverage_monitor_apb colector_coverage_apb_inst;
  
  //este creat portul prin care monitorul trimite spre exterior (la noi, informatia este accesata de scoreboard), prin intermediul agentului, tranzactiile extrase din traficul de pe interfata
  uvm_analysis_port #(apb_transaction) port_date_monitor_apb;
  
  //declaratia interfetei de unde monitorul isi colecteaza datele
  virtual apb_interface monitor_interface_intst;
  
  apb_transaction tranzactie_preluata_apb, aux_tr_apb;
  
  int delay;
  
  //constructorul clasei
  function new(string name = "monitor_apb", uvm_component parent = null);
    
    //prima data se apeleaza constructorul clasei parinte
    super.new(name, parent);
    
    //se creeaza portul prin care monitorul trimite in exterior, prin intermediul agentului, datele pe care le-a cules din traficul de pe interfata
    port_date_monitor_apb = new("port_date_monitor_apb",this);
    
    //se creeaza colectorul de coverage (la creare, se apeleaza constructorul colectorului de coverage)
    colector_coverage_apb_inst = coverage_agent_buton::type_id::create ("colector_coverage_apb_inst", this);
    
    
    //se creeaza obiectul (tranzactia) in care se vor retine datele colectate de pe interfata la fiecare tact de ceas
    tranzactie_preluata_apb = apb_transaction::type_id::create("date_noi");
    
    aux_tr_apb = apb_transaction::type_id::create("datee_noi");
  endfunction
  
  
  //se preia din baza de date interfata la care se va conecta monitorul pentru a citi date, si se "leaga" la interfata pe care deja monitorul o contine
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
      if (!uvm_config_db#(virtual apb_interface)::get(this, "", "apb_interface", monitor_interface_intst))
        `uvm_fatal("monitor_apb", "Nu s-a putut accesa interfata montorului")
  endfunction
        
  
  
  virtual function void connect_phase (uvm_phase phase);
    super.connect_phase(phase);
    
    //in faza UVM "connect", se face conexiunea intre pointerul catre monitor din instanta colectorului de coverage a acestui monitor si monitorul insusi 
	colector_coverage_apb_inst.p_monitor = this;
    
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    
    forever begin
	delay = 0;
      while(monitor_interface_intst.psel ==0)begin
		delay ++;
		@(negedge monitor_interface_intst.clk_i);
	  end
	  @(negedge monitor_interface_intst.clk_i iff pready ==1);
      //preluarea datelor de pe interfata se face la fiecare front negativ de ceas
            
      
      //preiau datele de pe interfata de iesire a DUT-ului (apb_interface)
      tranzactie_preluata_apb.addr = monitor_interface_intst.paddr;
	  tranzactie_preluata_apb.write = monitor_interface_intst.pwrite;
	  if(monitor_interface_intst.pwrite == 1)
		tranzactie_preluata_apb.data = 1'b1;
		else
		tranzactie_preluata_apb.data = 0;
		tranzactie_preluata_apb.err = monitor_interface_intst.pslverr;
      
      aux_tr_apb = tranzactie_preluata_apb.copy();
      
       //tranzactia cuprinzand datele culese de pe interfata se pune la dispozitie pe portul monitorului, daca modulul nu este in reset
     port_date_monitor_apb.write(aux_tr_apb); 
      
      //se inregistreaza valorile de pe cele doua semnale de iesire
      colector_coverage_apb_inst.buton_cg.sample();
      
    end//forever begin
  endtask
  
endclass: monitor_apb

`endif