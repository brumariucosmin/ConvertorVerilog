//componenta nu a fost adaptata acestui mediu de verificare
`ifndef _driver_interface_inst
`define _driver_interface_inst

//driverul va prelua date de tip "tranzactie", pe care le va trimite DUT-ului, conform protocolul de comunicatie de pe interfata
class apb_driver extends uvm_driver #(apb_driver);
  
  //driverul se adauga in baza de date UVM
  `uvm_component_utils (apb_driver)
  
  //este declarata interfata pe care driverul va trimite datele
  virtual interfata_dut driver_interface_inst;
  
  //constructorul clasei
  function new(string name = "apb_driver", uvm_component parent = null);
    //este apelat constructorul clasei parinte
    super.new(name, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    //este apelata mai intai functia build_phase din clasa parinte
    super.build_phase(phase);
    if (!uvm_config_db#(virtual interfata_dut)::get(this, "", "interfata_dut", driver_interface_inst))begin
      `uvm_fatal("APB_DRIVER", "Nu s-a putut accesa interfata_dut")
    end
  endfunction
  
  task drive(tranzactie_apb informatia_de_transmis)
   $timeformat(-9, 2, " ns", 20);//cand se va afisa in consola timpul, folosind directiva %t timpul va fi afisat in nanosecunde (-9), cu 2 zecimale, iar dupa valoare se va afisa abrevierea " ns"
   //T1
    @(posedge driver_interface_inst.clk_i);//transmiterea datelor se sincronizeaza cu ceasul de sistem
    this.driver_interface_inst.paddr   <= informatia_de_transmis.addr;
	
		this.driver_interface_inst.pwrite  <= informatia_de_transmis.write;
	if (informatia_de_transmis.write ==1)begin
		this.driver_interface_inst.pwdata  <= informatia_de_transmis.data;
	end
    this.driver_interface_inst.psel    <= 1'b1;
	//T2
     @(posedge driver_interface_inst.clk_i);//transmiterea datelor se sincronizeaza cu ceasul de sistem
    this.driver_interface_inst.penable <= 0;
	//T3
     @(posedge driver_interface_inst.clk_i iff driver_interface_inst.pready == 1);//transmiterea datelor se sincronizeaza cu ceasul de sistem
    this.driver_interface_inst.paddr   <= 'bz;
	this.driver_interface_inst.pwrite  <= 1'bz;
	this.driver_interface_inst.psel <= 1'b0;
	this.driver_interface_inst.penable <= 1'b0;
	this.driver_interface_inst.pwdata <= 'bz;
	 
  endtask

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      `uvm_info("APB_DRIVER", $sformatf("Se asteapta o tranzactie de la sequencer"), UVM_LOW)
      seq_item_port.get_next_item(req);
      `uvm_info("APB_DRIVER", $sformatf("S-a primit o tranzactie de la sequencer"), UVM_LOW)
      drive(req);
      `uvm_info("APB_DRIVER", $sformatf("Tranzactia a fost transmisa pe interfata"), UVM_LOW)
      seq_item_port.item_done();
    end
  endtask
   
endclass
`endif