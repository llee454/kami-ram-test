module system(
  output SRAM_A0, SRAM_A1, SRAM_A2, SRAM_A3, SRAM_A4, SRAM_A5, SRAM_A6, SRAM_A7,
  output SRAM_A8, SRAM_A9, SRAM_A10, SRAM_A11, SRAM_A12, SRAM_A13, SRAM_A14, SRAM_A15,
  inout SRAM_D0, SRAM_D1, SRAM_D2, SRAM_D3, SRAM_D4, SRAM_D5, SRAM_D6, SRAM_D7,
  inout SRAM_D8, SRAM_D9, SRAM_D10, SRAM_D11, SRAM_D12, SRAM_D13, SRAM_D14, SRAM_D15,
  output SRAM_CE, SRAM_WE, SRAM_OE, SRAM_LB, SRAM_UB,

  output logic lightLED1$_enable,
  output logic lightLED2$_enable,
  output logic lightLED3$_enable,

  input CLK
);

  logic[15:0] memRead$_return;
  logic memWrite$_enable;
  logic[36:0] memWrite$_argument;
  logic memRead$_enable;
  logic[20:0] memRead$_argument;

  assign RESET   = 0;
  
  // SRAM Interface
  /*
    See the Silicon Blue ICE Technology Library pg 88. This element can be used to
    drive a tristate input output device. Here we use it to drive the inout
    pins of the SRAM.
  */
  SB_IO #(
      .PIN_TYPE(6'b 1010_01), // PIN INPUT Unlatched or registered AND PIN_OUTPUT_TRISTATE
      .PULLUP(1'b 0)
  ) sram_io [15:0] (
      .PACKAGE_PIN({SRAM_D15, SRAM_D14, SRAM_D13, SRAM_D12, SRAM_D11, SRAM_D10, SRAM_D9, SRAM_D8,
                    SRAM_D7, SRAM_D6, SRAM_D5, SRAM_D4, SRAM_D3, SRAM_D2, SRAM_D1, SRAM_D0}),
      .OUTPUT_ENABLE(memWrite$_enable),
      .D_OUT_0(memWrite$_argument[36:21]), // D_OUT_0 = leading clock edge, 1 = trailing
      .D_IN_0(memRead$_return)
  );
  assign {SRAM_A18, SRAM_A17, SRAM_A16, SRAM_A15, SRAM_A14, SRAM_A13, SRAM_A12, SRAM_A11, SRAM_A10, SRAM_A9, SRAM_A8,
          SRAM_A7, SRAM_A6, SRAM_A5, SRAM_A4, SRAM_A3, SRAM_A2, SRAM_A1, SRAM_A0} = memWrite$_argument[20:5] | memRead$_argument [20:5];
  assign SRAM_CE = 0;
  assign SRAM_WE = (memWrite$_enable) ? 0 : 1;
  assign SRAM_OE = (memRead$_enable) ? 0 : 1;
  assign SRAM_LB = 0;
  assign SRAM_UB = 0;

  _design _designInst(.CLK(CLK), .RESET(RESET), .memRead$_return(memRead$_return), .memWrite$_enable(memWrite$_enable), .memWrite$_argument(memWrite$_argument), .lightLED1$_enable(lightLED1$_enable), .memRead$_enable(memRead$_enable), .memRead$_argument(memRead$_argument), .lightLED2$_enable(lightLED2$_enable), .lightLED3$_enable(lightLED3$_enable));
endmodule


