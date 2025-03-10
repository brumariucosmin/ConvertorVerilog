module convertor
  //Parametrii
  localparam CLK_PERIOD = 20;
  
  //APB
  reg PCLK;
  reg PRESETn;
  reg PWDATA;
  reg PREADY;
  wire [7:0] PRDATA;
  wire PWRITE;
  wire PSELx;
  wire PENABLE;
  wire [1:0] PADDR;
  
  //SPI
  reg MISO;
  wire SCLK;
  wire MOSI;
  wire CS;
  wire SPI_DONE;
 
  //instantierea convertorului
  convertor dut (
    .clk(clk),
    .reset(reset),
    .psel(psel),
    .penable(penable),
    .pwrite(pwrite),
    .paddr(paddr),
    .pwdata(pwdata),
    .prdata(prdata),
    .pready(pready),
    .sck(sck),
    .mosi(mosi),
    .cs(cs)
  );
  
  // Clock generator
  	clk = 0
	always #(CLK_PERIOD / 2) clk = ~clk;
 
  