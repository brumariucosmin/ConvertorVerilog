`include "uvm_macros.svh"
import uvm_pkg::*;

`ifndef __spi_coverage_collector
`define __spi_coverage_collector

//aceasta clasa este folosita pentru a se vedea cate combinatii de intrari au fost trimise DUT-ului; aceasta clasa este doar de model, si probabil va fi modificata, deoarece in general nu ne intereseaza sa obtinem in simulare toate combinatiile posibile de intrari ale unui DUT
class coverage_spi extends uvm_component;
  
  //componenta se adauga in baza de date
  `uvm_component_utils(coverage_spi)
  
  //se declara pointerul catre monitorul care da datele asupra carora se vor face masuratorile de coverage
  monitor_spi p_monitor;
  
  covergroup stari_spi_cg;
    option.per_instance 	= 1;
    coverpoint p_monitor.starea_preluata_a_spiului.data{
        bins min_data 		= {0};
        bins random_data   	= {[1:154]};
		bins random_data_1 	= {[155:254]};
      	bins max_data 		= {255};
    }
  endgroup
  
  //se creeaza grupul de coverage; ATENTIE! Fara functia de mai jos, grupul de coverage nu va putea esantiona niciodata date deoarece pana acum el a fost doar declarat, nu si creat
  function new(string name, uvm_component parent);
    super.new(name, parent);
    $cast(p_monitor, parent);//with the use of $cast, type check will occur during runtime
    stari_spi_cg = new();
  endfunction
  
endclass


`endif