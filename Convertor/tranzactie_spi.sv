class spi_transaction;
  
  // Semnale pentru interfața SPI
  rand bit [7:0] data;
  
  
     // Funcție de afișare a tranzacției generate
  function void post_randomize();
    $display("--------- [SPI Trans] post_randomize ------");
    $display("\t data      = %b", data);
    $display("--------------------------------------------");
  endfunction
  
  // Operator pentru copierea obiectului (deep copy)
  function spi_transaction do_copy();
    spi_transaction trans;
    trans 		= new();
    trans.data  = this.data;
  
    return trans;
  
  endfunction

endclass