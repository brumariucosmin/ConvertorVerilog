`include "uvm_macros.svh"
import uvm_pkg::*;

`ifndef __ambient_scoreboard
`define __ambient_scoreboard

`uvm_analysis_imp_decl(_apb)
`uvm_analysis_imp_decl(_spi)

class scoreboard extends uvm_scoreboard;

  // Registrele interne
  reg [7:0] reg_operand1, reg_operand1_to_modify; // adresa 0
  reg [7:0] reg_result; // adresa 2
  reg [7:0] reg_ctrl;   // adresa 4
  
  // Componente UVM
  `uvm_component_utils(scoreboard)

  // Porturi pentru recepția tranzacțiilor
  uvm_analysis_imp_apb #(tranzactie_apb, scoreboard) port_pentru_datele_de_la_apb;
  uvm_analysis_imp_spi #(tranzactie_spi, scoreboard) port_date_monitor_spi;

  // Structuri de tranzacții
  tranzactie_apb tranzactie_venita_de_la_apb;
  tranzactie_spi tranzactie_venita_de_la_spi;
  tranzactie_spi tranzactie_prezisa_de_referinta;

  bit enable;
  logic [7:0] nr_binar;
  logic [7:0] cod_gray;
  logic [7:0] addr;

  covergroup registers_cg;
    option.per_instance = 1;
    reg_operand1_cp: coverpoint reg_operand1 {
      bins min_val = {0};
      bins little_values = {[1:127]};
      bins high_values = {[128:254]};
      bins max_val = {255};
    }

    reg_result_cp: coverpoint reg_result {
      bins min_val = {0};
      bins random_val[4] = {[1:254]};
      bins max_val = {255};
    }

    err_cp: coverpoint reg_ctrl[6];
    end_cp: coverpoint reg_ctrl[1];
  endgroup

  // Constructor
  function new(string name="scoreboard", uvm_component parent=null);
    super.new(name, parent);
    port_pentru_datele_de_la_apb = new("port_pentru_datele_de_la_apb", this);
    port_date_monitor_spi = new("port_date_monitor_spi", this);
    tranzactie_prezisa_de_referinta = new();
    tranzactie_venita_de_la_apb = new();
    tranzactie_venita_de_la_spi = new();
    registers_cg = new();
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction

  // Funcție de calcul cod Gray
  function tranzactie_spi compute_result(tranzactie_apb tranzactie_prezisa);
    tranzactie_prezisa_de_referinta = new();
    nr_binar = tranzactie_prezisa.data;
    cod_gray = nr_binar ^ (nr_binar >> 1);
    tranzactie_prezisa_de_referinta.data = cod_gray;
    return tranzactie_prezisa_de_referinta;
  endfunction

  // Scriere APB
  function void write_apb(input tranzactie_apb tranzactie_noua_apb);  
    `uvm_info("SCOREBOARD", $sformatf("Primită tranzacție APB: addr=0x%0h, data=0x%0h", tranzactie_noua_apb.addr, tranzactie_noua_apb.data), UVM_LOW)
    
    addr = tranzactie_noua_apb.addr;

    if (tranzactie_noua_apb.write == 1) begin
      case (addr)
        0: reg_operand1 = tranzactie_noua_apb.data;
        2: reg_result = tranzactie_noua_apb.data;
        4: reg_ctrl = tranzactie_noua_apb.data;
        default: $warning("SCOREBOARD: Adresă necunoscută pentru scriere.");
      endcase
      registers_cg.sample(); // doar la scriere
    end else begin
      case (addr)
        0: begin assert(reg_operand1 == tranzactie_noua_apb.data) else `uvm_error("SCOREBOARD", "Eroare la operand1"); end
        2: begin assert(reg_result == tranzactie_noua_apb.data) else `uvm_error("SCOREBOARD", "Eroare la result"); end
        4: begin assert(reg_ctrl == tranzactie_noua_apb.data) else `uvm_error("SCOREBOARD", "Eroare la ctrl"); end
        default: $warning("SCOREBOARD: Adresă necunoscută pentru citire.");
      endcase
    end

    tranzactie_venita_de_la_apb = tranzactie_noua_apb.copy();
    tranzactie_prezisa_de_referinta = compute_result(tranzactie_venita_de_la_apb);
  endfunction

  // Scriere SPI
  function void write_spi(input tranzactie_spi tranzactie_noua_spi);  
    `uvm_info("SCOREBOARD", $sformatf("Primită tranzacție SPI: data=0x%0h", tranzactie_noua_spi.data), UVM_LOW)
    
    tranzactie_venita_de_la_spi = tranzactie_noua_spi.copy();
    verifica_corespondenta_datelor();
  endfunction

  // Verificare corectitudine
  function void verifica_corespondenta_datelor();
    if (tranzactie_venita_de_la_spi.data !== tranzactie_prezisa_de_referinta.data) begin
      `uvm_error("SCOREBOARD", $sformatf("Mismatch SPI: primit=0x%0h, așteptat=0x%0h", 
        tranzactie_venita_de_la_spi.data, tranzactie_prezisa_de_referinta.data))
    end else begin
      `uvm_info("SCOREBOARD", "Conversia Gray este corectă.", UVM_LOW)
    end
  endfunction

endclass
`endif
