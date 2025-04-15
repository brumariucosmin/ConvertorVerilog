`include "uvm_macros.svh"
import uvm_pkg::*;

`ifndef __spi_driver
`define __spi_driver

//driverul va prelua date de tip "tranzactie", pe care le va trimite DUT-ului, conform protocolul de comunicatie de pe interfata
class driver_agent_spi extends uvm_driver #(tranzactie_spi);
  
  //driverul se adauga in baza de date UVM
  `uvm_component_utils (driver_agent_spi)
  
  //este declarata interfata pe care driverul va trimite datele
  virtual spi_interface_dut interfata_driverului_pentru_spi;
  int i;
  //constructorul clasei
  function new(string name = "driver_agent_spi", uvm_component parent = null);
    //este apelat constructorul clasei parinte
    super.new(name, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    //este apelata mai intai functia build_phase din clasa parinte
    super.build_phase(phase);
    if (!uvm_config_db#(virtual spi_interface_dut)::get(this, "", "spi_interface_dut", interfata_driverului_pentru_spi))begin
      `uvm_fatal("DRIVER_AGENT_spi", "Nu s-a putut accesa interfata_spiului")
    end
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
		wait(interfata_driverului_pentru_spi.cs == 0);
		@(posedge interfata_driverului_pentru_spi.clk);
		for(i=0;i<=7;i++)begin
		if (i<7)interfata_driverului_pentru_spi.miso <=0; //spi_done
		//count pana la 8 
		else interfata_driverului_pentru_spi.miso <=1; //spi_done
		@(posedge interfata_driverului_pentru_spi.clk);
		end
		interfata_driverului_pentru_spi.miso <=0;
		@(posedge interfata_driverului_pentru_spi.clk);
	end
  endtask
    
    `ifdef DEBUG
    $display("DRIVER_AGENT_spi, dupa transmisie; [T=%0t]", $realtime);
    `endif;
  endtask
  
endclass
`endif