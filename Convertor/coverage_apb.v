`ifndef __coverage_apb
`define __coverage_apb

//aceasta clasa este folosita pentru a se vedea cate combinatii de intrari au fost trimise DUT-ului; aceasta clasa este doar de model, si probabil va fi modificata, deoarece in general nu ne intereseaza sa obtinem in simulare toate combinatiile posibile de intrari ale unui DUT
class coverage_monitor_apb extends uvm_component;
  
  //componenta se adauga in baza de date
  `uvm_component_utils(coverage_monitor_apb)
  
  //se declara pointerul catre monitorul care da datele asupra carora se vor face masuratorile de coverage
  monitor_agent_buton p_monitor;
  
  covergroup buton_cg;
    option.per_instance = 1;
wr_rd_cp:    coverpoint p_monitor.tranzactie_preluata_apb.write;
data_cp: coverpoint p_monitor.tranzactie_preluata_apb.data{
option.at_least = 2;
	bins valoare_minima = {0};
	bins intervale_valori[4] = {[1:$]};
	bins valoare_maxima = {255};
}
addr_cp: coverpoint p_monitor.tranzactie_preluata_apb.addr{
    bins addr_operand1 = {0};
	bins addr_result = {2};
	bins addr_ctrl = {4};
    bins celelalte_valori: default;
}    
err_cp: coverpoint p_monitor.tranzactie_preluata_apb.err{
   bins trans_ok = {0};
   bins trans_eronata = {1};
}

delay_cp: coverpoint p_monitor.tranzactie_preluata_apb.delay{
illegal_bins intarzieri_negative = {[-100:-1]};
   illegal_bins fara_distanta = {0};
   bins intarziere_de_un_tact = {1};
   bins intarzieri_mici ={[2:10]};
   bins intarzieri_mari ={[11:20]};
   bins intarzieri_mici ={[20:$]};
}

addr_wr_rd_cx: cross addr_cp, wr_rd_cp;

addr_err_cx: cross addr_cp, err_cp{
	illegal_bins n_se_poate = binsof(addr_cp.celelalte_valori) && binsof(err_cp.trans_ok);
}
    //se presupune ca este de interes sa se vada ce combinatii au aparut intre cele 6 intrari posibile

  endgroup
  
  //se creaza grupul de coverage; ATENTIE! Fara functia de mai jos, grupul de coverage nu va putea esantiona niciodata date deoarece pana acum el a fost doar declarat, nu si creat
  function new(string name, uvm_component parent);
    super.new(name, parent);
    $cast(p_monitor, parent);
    buton_cg = new();
  endfunction
  
  //o alta modalitate de a incheia declaratia unei clase este sa se scrie "endclass: numele_clasei"; acest lucru este util mai ales cand se declara mai multe clase in acelasi fisier; totusi, se recomanda ca fiecare fisier sa nu contina mai mult de o declaratie a unei clase
endclass: coverage_monitor_apb


`endif