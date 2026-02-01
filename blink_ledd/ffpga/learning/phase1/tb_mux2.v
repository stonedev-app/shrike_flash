// ------------------------------------------------------------
// tb_mux2.v
// 2入力マルチプレクサのテストベンチ
// すべての入力パターンを網羅的にテスト
// ------------------------------------------------------------
`timescale 1ns / 1ps

module tb_mux2;

  // ----------------------------------------------------------
  // テストベンチ用信号
  // ----------------------------------------------------------
  reg in0, in1, sel;
  wire out;

  // ----------------------------------------------------------
  // テスト対象モジュールのインスタンス化
  // ----------------------------------------------------------
  mux2 uut (
    .in0(in0),
    .in1(in1),
    .sel(sel),
    .out(out)
  );

  // ----------------------------------------------------------
  // テスト実行
  // ----------------------------------------------------------
  initial begin
    $dumpfile("tb_mux2.vcd");
    $dumpvars(0, tb_mux2);

    $display("=== MUX2 Test Start ===");
    $display("sel | in0 in1 | out | expected");
    $display("----+--------+-----+---------");

    // sel=0: in0 が出力されるはず
    sel = 0; in0 = 0; in1 = 0; #10;
    $display("  %b |  %b   %b  |  %b  |    0", sel, in0, in1, out);

    sel = 0; in0 = 0; in1 = 1; #10;
    $display("  %b |  %b   %b  |  %b  |    0", sel, in0, in1, out);

    sel = 0; in0 = 1; in1 = 0; #10;
    $display("  %b |  %b   %b  |  %b  |    1", sel, in0, in1, out);

    sel = 0; in0 = 1; in1 = 1; #10;
    $display("  %b |  %b   %b  |  %b  |    1", sel, in0, in1, out);

    // sel=1: in1 が出力されるはず
    sel = 1; in0 = 0; in1 = 0; #10;
    $display("  %b |  %b   %b  |  %b  |    0", sel, in0, in1, out);

    sel = 1; in0 = 0; in1 = 1; #10;
    $display("  %b |  %b   %b  |  %b  |    1", sel, in0, in1, out);

    sel = 1; in0 = 1; in1 = 0; #10;
    $display("  %b |  %b   %b  |  %b  |    0", sel, in0, in1, out);

    sel = 1; in0 = 1; in1 = 1; #10;
    $display("  %b |  %b   %b  |  %b  |    1", sel, in0, in1, out);

    $display("=== MUX2 Test End ===");
    $finish;
  end

endmodule
