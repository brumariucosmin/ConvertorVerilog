`include "uvm_macros.svh"
import uvm_pkg::*;

`ifndef __ambient_scoreboard
`define __ambient_scoreboard

//se declara prefixele pe care le vor avea elementele folosite pentru a prelua datele de la agentul de intrari, respectiv de la agentul de semafoare
`uvm_analysis_imp_decl(_apb)
`uvm_analysis_imp_decl(_spi)

class scoreboard extends uvm_scoreboard;


reg [7:0] reg_operand1, reg_operand1_to_modify; // adresa 0
reg [7:0] reg_result; // adresa 2
reg [7:0] reg_ctrl; // adresa 4
  
  //se adauga componenta in baza de date UVM
  `uvm_component_utils(scoreboard)
  
  //se declara porturile prin intermediul carora scoreboardul primeste datele de la agenti, aceste date reflectand functionalitatea DUT-ului
  uvm_analysis_imp_apb #(apb_transaction, scoreboard) port_pentru_datele_de_la_apb;
  uvm_analysis_imp_spi #(tranzactie_spi, scoreboard) port_pentru_datele_de_laSpi;

  //se declara structurile necesare pentru verificare
  apb_transaction tranzactie_venita_de_la_apb; // datele primite de la APB
  tranzactie_spi tranzactie_venita_de_la_spi; // datele primite de la SPI
  tranzactie_spi tranzactie_prezisa_de_referinta; // datele calculate de scoreboard
  
  bit enable;
  logic [7:0] nr_binar;
  genvar i;
  
   //constructorul clasei
  function new(string name="scoreboard", uvm_component parent=null);
    super.new(name, parent);
    // Initializarea porturilor
    port_pentru_datele_de_la_apb = new("pentru_datele_de_laapb", this);
    port_pentru_datele_de_laSpi = new("pentru_datele_de_laspi", this);

    // Inițializarea tranzacțiilor
    tranzactie_prezisa_de_referinta = new();    
    tranzactie_venita_de_la_apb = new();    
    tranzactie_venita_de_la_spi = new();    
	
	// Instanțierea covergroup-urilor
	registers_cg = new();
  endfunction
  
  virtual function void connect_phase (uvm_phase phase);
    super.connect_phase(phase);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction
  
  // Functie pentru calcularea conversiei de la decimal la binar
  function tranzactie_spi compute_result(apb_transaction tranzactie_prezisa);
    tranzactie_prezisa_de_referinta = new();
        nr_binar = 8'b0;

 // Codare Gray
		cod_gray = nr_binar ^ (nr_binar >> 1);
		tranzactie_prezisa_de_referinta.data = cod_gray;

    return tranzactie_prezisa_de_referinta;
  endfunction
  
  
  // Functie apelata cand primim date de la APB
  function void write_apb(input apb_transaction tranzactie_noua_apb);  
    `uvm_info("SCOREBOARD", $sformatf("S-a primit de la agentul apb tranzactia cu informatia:\n"), UVM_LOW)
	
	if (tranzactie_noua_apb.write ==1) begin// write transactions
		case (addr)
	0: reg_operand1 <= tranzactie_noua_apb.data;
	2: reg_result <= tranzactie_noua_apb.data;
	4: reg_ctrl <= tranzactie_noua_apb.data;
    default: $warning ("SCOREBOARD: wring address");
	endcase
	registers_cg.sample();
	end
	else
		case (addr)
	0: assert(reg_operand1 == tranzactie_noua_apb.data);
	2: assert(reg_result == tranzactie_noua_apb.data);
	4: assert(reg_ctrl == tranzactie_noua_apb.data);
    default: $warning ("SCOREBOARD: wring address");
	endcase
	
    tranzactie_noua_apb.afiseaza_informatia_tranzactiei();
    
    // Salvam tranzactia nou primita
    tranzactie_venita_de_la_apb = new();
    tranzactie_venita_de_la_apb = tranzactie_noua_apb.copy();
    
    // Calculam rezultatul așteptat
    tranzactie_prezisa_de_referinta = compute_result(tranzactie_venita_de_la_apb);
  endfunction : write_apb
  
  // Functie apelata cand primim date de la SPI
  function void write_spi(input tranzactie_spi tranzactie_noua_spi);  
    `uvm_info("SCOREBOARD", $sformatf("S-a primit de la agentul spi tranzactia cu informatia:\n"), UVM_LOW)
    tranzactie_noua_spi.afiseaza_informatia_tranzactiei();
    
    // Salvam tranzactia nou primita
    tranzactie_venita_de_la_spi = new();
    tranzactie_venita_de_la_spi = tranzactie_noua_spi.copy();
    
    // Verificam corectitudinea conversiei
    verifica_corespondenta_datelor();
  endfunction : write_spi
  
  // Functie care verifica daca dataa primita de la SPI corespunde celei calculate
  function void verifica_corespondenta_datelor();
    if (tranzactie_venita_de_la_spi.data !== tranzactie_prezisa_de_referinta.data) begin
        `uvm_error("SCOREBOARD", "Mismatch între dataa SPI și conversia preconizată!")
    end else begin
        `uvm_info("SCOREBOARD", "Conversia este corectă", UVM_LOW)
    end
  endfunction
  
  
  covergroup registers_cg;
    option.per_instance = 1;
    reg_operand1_cp: coverpoint scoreboard.reg_operand1{
        bins min_val = {0};
        bins little_values = {[1:128]};
		bins high_values = {[128:254]};
      	bins max_val = {255};
    reg_result_cp: coverpoint scoreboard.reg_result{
        bins min_val = {0};
        bins random_val[4] = {[1:$]};
      	bins max_val = {255};
    err_cp: coverpoint scoreboard.reg_ctrl[6];
	end_cp: coverpoint scoreboard.reg_ctrl[1];

  endgroup
  
  //se creeaza grupul de coverage; ATENTIE! Fara functia de mai jos, grupul de coverage nu va putea esantiona niciodata date deoarece pana acum el a fost doar declarat, nu si creat
  function new(string name, uvm_component parent);
    super.new(name, parent);
    $cast(scoreboard, parent);//with the use of $cast, type check will occur during runtime
	registers_cg = new();
  endfunction
  
  
endclass
  

endclass
`endif
