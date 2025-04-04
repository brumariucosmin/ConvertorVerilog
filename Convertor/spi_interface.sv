
interface spi_interface_dut;
logic clk;
logic reset_n;
  logic sclk;
  logic mosi; // Data line
  logic miso; // SPI data out, spi_done se asertează când a terminat de citit (8)
  logic cs;   // Chip select

  import uvm_pkg::*;
  
  
  // Asigură că SCLK nu se mișcă atunci când CS este inactiv
  property sck_unmoved_on_idle_ss_line;
    @(posedge clk) disable iff (reset_n ==0)
	$changed(sclk) |-> !cs;
  endproperty
  assert property (sck_unmoved_on_idle_ss_line);

// Asigură că MISO preia date doar după ce MOSI a terminat transmisia
property miso_changes_after_mosi;
  @(posedge sclk) $changed(miso) |-> !cs;
endproperty
assert property (miso_changes_after_mosi);

// Asigură că MISO preia date doar după ce MOSI a terminat transmisia
property miso_changes_aftosi;
  @(posedge sclk) $changed(mosi) |-> !cs;
endproperty
assert property (miso_changes_aftosi);
  
  // Asigură că SCLK începe să comute doar după ce CS devine inactiv
  property sclk_changes_only_when_cs_inactive;
  @(posedge clk) !$isunknown(cs);
endproperty
assert property (sclk_changes_only_when_cs_inactive);


endinterface

`endif


