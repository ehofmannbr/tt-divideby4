/*
 * Copyright (c) 2026 Edgar Hofmann
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_ehofmannbr_tt-divideby4 (
    input  wire [7:0] ui_in,    // Dedicated inputs not used
    output wire [7:0] uo_out,   // Dedicated outputs r_out[3..0], g_out[3..0]
    input  wire [7:0] uio_in,   // IOs: Input path not used
    output wire [7:0] uio_out,  // IOs: Output path b_out[3..0], hs, vs, hs, _vs
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output) Configure ALL as outputs
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // All output pins must be assigned. If not used, assign to 0.
  // assign uo_out  = ui_in + uio_in;  // Example: ou_out is the sum of ui_in and uio_in
  // assign uio_out = 0;
  // assign uio_oe  = 0;

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, ui_in, uio_in, 1'b0};

//Original module declaration - vgapmod_04
//module vgapmod_04(
//    input wire clk_50,       // 50 Mhz Clk
//    input wire rst_n,        // Asynchronous Low reset
//    output wire hs,          // Horizontal signal
//    output wire vs,          // Vertical signal
//    output wire[3:0] r_out,  // Red signal
//    output wire[3:0] g_out,  // Green signal
//    output wire[3:0] b_out   // Blue signal
//);

reg clk_25;                 // Divide 50Mhz por 2
reg[9:0] h_cnt;             // Conta de zero a 799
reg[9:0] v_cnt;             // Conta de zero a 520
reg _hs;                    // Registro hs
reg _vs;                    // Registro vs
reg[11:0] _cor;             // Saida do mux de cor
reg[11:0] cor1;             // Registro de cor
reg[11:0] cor2;             // Registro de cor
reg[11:0] cor3;             // Registro de cor
reg[11:0] cor4;             // Registro de cor
reg[11:0] cor5;             // Registro de cor
reg[11:0] cor6;             // Registro de cor
reg[11:0] cor7;             // Registro de cor
reg[11:0] cor8;             // Registro de cor
reg[11:0] cor9;             // Registro de cor
reg[11:0] cort;             // Registro de cor
reg[25:0] t_cnt;            // Enables period > 1s



// Horizontal sequence
// 0..95 hs active, 96..143 Back Porch, 144..783 _on, 784..799 Front Porch
always @(*) begin  // Horizontal pulse 
   if ((h_cnt>=0)&&(h_cnt<96)) 
      begin
      _hs = 1'b0;
      end
   else
      begin
      _hs = 1'b1;
      end   
end

// Vertical sequence
// 0..1 vs active, 2..30 Back Porch, 31..510 _on, 511..520 Front Porch
always @(*) begin // Vertical Pulse 
   if ((v_cnt>=0)&&(v_cnt<2)) 
      begin
      _vs = 1'b0;
      end
   else
      begin
      _vs = 1'b1;
      end   
end

// Mosaicos
always @(*) begin
   if ((h_cnt>=144)&&(h_cnt<358)&&(v_cnt>=31)&&(v_cnt<191)) 
      begin
      _cor = cor1;
      end
	else
   if ((h_cnt>=358)&&(h_cnt<572)&&(v_cnt>=31)&&(v_cnt<191)) 
      begin
      _cor = cor2;
		end
	else
   if ((h_cnt>=572)&&(h_cnt<783)&&(v_cnt>=31)&&(v_cnt<191)) 
      begin
      _cor = cor3;
		end
	else
   if ((h_cnt>=144)&&(h_cnt<358)&&(v_cnt>=191)&&(v_cnt<351)) 
      begin
      _cor = cor4;
      end
	else
   if ((h_cnt>=358)&&(h_cnt<572)&&(v_cnt>=191)&&(v_cnt<351)) 
      begin
      _cor = cor5;
		end
	else
   if ((h_cnt>=572)&&(h_cnt<783)&&(v_cnt>=191)&&(v_cnt<351)) 
      begin
      _cor = cor6;
		end
	else
   if ((h_cnt>=144)&&(h_cnt<358)&&(v_cnt>=351)&&(v_cnt<510)) 
      begin
      _cor = cor7;
      end
	else
   if ((h_cnt>=358)&&(h_cnt<572)&&(v_cnt>=351)&&(v_cnt<510)) 
      begin
      _cor = cor8;
		end
	else
   if ((h_cnt>=572)&&(h_cnt<783)&&(v_cnt>=351)&&(v_cnt<510)) 
      begin
      _cor = cor9;
		end
	else
	   begin
		_cor = 12'b0;
		end
end		
		
task raster;
begin
   if (h_cnt==800)
      begin
      h_cnt = 10'b0;
      if (v_cnt==521)
         begin
         v_cnt = 10'b0;
         end
      else
         begin
         v_cnt = v_cnt + 10'b1;
         end
      end
   else
      begin
      h_cnt = h_cnt + 10'b1;
      end
end
endtask

always @(posedge clk) begin
   if (!rst_n)
      begin
      clk_25 = 1'b0;
      h_cnt  = 10'b0;
      v_cnt  = 10'b0;
		t_cnt  = 0;
		cor1   = 12'b000000000000;
		cor2   = 12'b111100000000;
		cor3   = 12'b000011110000;
		cor4   = 12'b000000001111;
		cor5   = 12'b111111110000;
		cor6   = 12'b111100001111;
		cor7   = 12'b000011111111;
		cor8   = 12'b011101110111;
		cor9   = 12'b111111111111;
      end
   else
      begin
      clk_25 = ~clk_25;
      if (clk_25)
        begin
        raster();
		  if (t_cnt==24999999) // 1 em 1 segundo
		     begin
			  t_cnt = 0;
			  cort = cor9;
			  cor9 = cor8;
			  cor8 = cor7;
			  cor7 = cor6;
			  cor6 = cor5;
			  cor5 = cor4;
			  cor4 = cor3;
			  cor3 = cor2;
			  cor2 = cor1;
			  cor1 = cort;
			  end
		  else
		     begin
			  t_cnt = t_cnt + 1'b1;
			  end  
        end
      end
end

assign uo_out[7:4] = _cor[11:8];
assign uo_out[3:0] = _cor[7:4];
assign uio_out[7:4] = _cor[3:0];
assign uio_out[3] = _hs;
assign uio_out[2] = _vs;
assign uio_out[1] = 1'b0;
assign uio_out[0] = 1'b0;
assign uio_oe = 8'b11111111; // uio_out active as outputs

endmodule

