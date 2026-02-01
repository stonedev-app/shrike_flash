// ------------------------------------------------------------
// mux2.v
// 2入力マルチプレクサ（assign文の練習）
// sel=0 なら in0、sel=1 なら in1 を出力
// ------------------------------------------------------------

module mux2(
  input in0,
  input in1,
  input sel,
  output out
);
  assign out = sel ? in1 : in0;
endmodule
