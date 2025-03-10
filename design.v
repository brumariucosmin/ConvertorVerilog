parameter ADDR_WIDTH = 2;
parameter DATA_WIDTH = 8;

module convertor_top (
  input logic clk,
  input logic reset,
  input logic [ADDR_WIDTH-1:0] paddr,
  input logic pwrite,
  input logic psel,
  input logic penable,
  input logic [DATA_WIDTH-1:0] pwdata,
  output logic [DATA_WIDTH-1:0] prdata,
  output logic pready,
  output logic mod_ready,
);
  
  reg [7:0] operand1;
  wire [7:0] result;
  wire [7:0] ctrl;
  wire [7:0] status;