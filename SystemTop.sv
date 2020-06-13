module system(

  output logic[4:0] memCtl,
  output logic[15:0] memAddr,
  inout logic[15:0] memData,

  output logic lightLED1$_enable,
  output logic lightLED2$_enable,
  output logic lightLED3$_enable,

  input CLK,
);

  logic[15:0] memRead$_return;
  logic memWrite$_enable;
  logic[36:0] memWrite$_argument;
  logic memRead$_enable;
  logic[20:0] memRead$_argument;

  assign RESET   = 0;
  assign memCtl  = memWrite$_argument[4:0] | memRead$_argument[4:0];
  assign memAddr = memWrite$_argument[20:5] | memRead$_argument[20:5];
  assign memData = memWrite$_argument[36:21];
  assign memRead$_return = memData;

/*
  always @(posedge CLK) begin
    lightLED1$_enable <= memCtl [2]; //memWrite$_argument[2];
    lightLED2$_enable <= memData [0]; // memWrite$_argument[21];
    lightLED3$_enable <= memData [1]; // memWrite$_argument[22];
  end
*/
  _design _designInst(.CLK(CLK), .RESET(RESET), .memRead$_return(memRead$_return), .lightLED3$_enable(lightLED3$_enable), .memWrite$_enable(memWrite$_enable), .memWrite$_argument(memWrite$_argument), .lightLED1$_enable(lightLED1$_enable), .memRead$_enable(memRead$_enable), .memRead$_argument(memRead$_argument), .lightLED2$_enable(lightLED2$_enable));
endmodule


