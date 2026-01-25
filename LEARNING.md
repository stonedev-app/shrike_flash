# Verilog学習プラン

## 目標

**最終ゴール**: 2bit または 4bit の小さなCPUをVerilogで設計する

**現在地**: LED点滅サンプル (`blink_ledd/ffpga/src/main.v`) を理解した段階

---

## 学習ロードマップ

### Phase 1: 基礎固め（組み合わせ回路）

| # | テーマ | 状態 |
|---|--------|------|
| 1.1 | wire と reg の違いを理解する | [x] |
| 1.2 | assign文（組み合わせ回路）を使いこなす | [ ] |
| 1.3 | マルチプレクサ (MUX) を作る | [ ] |
| 1.4 | 簡単な加算器を作る | [ ] |

#### 1.1 wire と reg の違い

```verilog
// wire: 配線。常に何かに接続されている必要がある
wire a;
assign a = b & c;  // 組み合わせ回路

// reg: レジスタ。always文の中で値を保持できる
reg x;
always @(posedge clk) begin
  x <= something;  // 順序回路（クロック同期）
end
```

**ポイント**:
- `wire` は「今この瞬間の値」
- `reg` は「クロックで更新されるまで保持する値」

#### 1.2 assign文

```verilog
// 組み合わせ回路の基本
assign out = in1 & in2;      // AND
assign out = in1 | in2;      // OR
assign out = in1 ^ in2;      // XOR
assign out = ~in1;           // NOT
assign out = sel ? a : b;    // MUX（三項演算子）
```

#### 1.3 練習: 2入力マルチプレクサ

```verilog
// sel=0 なら in0、sel=1 なら in1 を出力
module mux2(
  input in0,
  input in1,
  input sel,
  output out
);
  assign out = sel ? in1 : in0;
endmodule
```

**課題**: 4入力MUX (sel が2bit) を作ってみる

#### 1.4 練習: 4bit加算器

```verilog
module adder4(
  input [3:0] a,
  input [3:0] b,
  output [4:0] sum  // 桁上がり含めて5bit
);
  assign sum = a + b;
endmodule
```

---

### Phase 2: 順序回路とステートマシン

| # | テーマ | 状態 |
|---|--------|------|
| 2.1 | always文とクロック同期を理解する | [ ] |
| 2.2 | カウンタのバリエーションを作る | [ ] |
| 2.3 | 有限ステートマシン (FSM) を作る | [ ] |
| 2.4 | FSMでLED点灯パターンを制御する | [ ] |

#### 2.1 always文の基本

```verilog
// ブロッキング代入 (=) と ノンブロッキング代入 (<=)
always @(posedge clk) begin
  // 順序回路では <= を使う（同時に更新される）
  a <= b;
  b <= a;  // aとbが同時に入れ替わる
end

always @(*) begin
  // 組み合わせ回路では = を使う
  out = in1 & in2;
end
```

#### 2.2 カウンタのバリエーション

```verilog
// アップカウンタ
counter <= counter + 1;

// ダウンカウンタ
counter <= counter - 1;

// イネーブル付きカウンタ
if (enable)
  counter <= counter + 1;

// リセット付きカウンタ
if (reset)
  counter <= 0;
else
  counter <= counter + 1;
```

#### 2.3 有限ステートマシン (FSM)

```verilog
// 状態の定義
localparam STATE_IDLE = 2'b00;
localparam STATE_RUN  = 2'b01;
localparam STATE_DONE = 2'b10;

reg [1:0] state;

always @(posedge clk) begin
  case (state)
    STATE_IDLE: begin
      if (start)
        state <= STATE_RUN;
    end
    STATE_RUN: begin
      // 何か処理
      if (finished)
        state <= STATE_DONE;
    end
    STATE_DONE: begin
      state <= STATE_IDLE;
    end
  endcase
end
```

**課題**: LED点灯パターンをFSMで制御
- STATE_OFF → STATE_BLINK_SLOW → STATE_BLINK_FAST → STATE_ON → 繰り返し

---

### Phase 3: メモリとレジスタファイル

| # | テーマ | 状態 |
|---|--------|------|
| 3.1 | 配列（メモリ）の宣言と使い方 | [ ] |
| 3.2 | 簡単なレジスタファイルを作る | [ ] |
| 3.3 | 読み書き可能なメモリを作る | [ ] |

#### 3.1 メモリの宣言

```verilog
// 8個の8bitレジスタ（8バイトのメモリ）
reg [7:0] memory [0:7];

// 読み出し
assign data_out = memory[address];

// 書き込み（クロック同期）
always @(posedge clk) begin
  if (write_enable)
    memory[address] <= data_in;
end
```

#### 3.2 レジスタファイル

```verilog
// 4つの4bitレジスタ（2bitアドレスで選択）
module regfile(
  input clk,
  input [1:0] read_addr,
  input [1:0] write_addr,
  input [3:0] write_data,
  input write_enable,
  output [3:0] read_data
);
  reg [3:0] regs [0:3];

  assign read_data = regs[read_addr];

  always @(posedge clk) begin
    if (write_enable)
      regs[write_addr] <= write_data;
  end
endmodule
```

---

### Phase 4: ALU（演算装置）

| # | テーマ | 状態 |
|---|--------|------|
| 4.1 | 基本演算を選択できるALUを作る | [ ] |
| 4.2 | フラグ（ゼロ、キャリー）を追加する | [ ] |

#### 4.1 シンプルなALU

```verilog
module alu(
  input [3:0] a,
  input [3:0] b,
  input [1:0] op,      // 演算選択
  output reg [3:0] result
);
  localparam OP_ADD = 2'b00;
  localparam OP_SUB = 2'b01;
  localparam OP_AND = 2'b10;
  localparam OP_OR  = 2'b11;

  always @(*) begin
    case (op)
      OP_ADD: result = a + b;
      OP_SUB: result = a - b;
      OP_AND: result = a & b;
      OP_OR:  result = a | b;
    endcase
  end
endmodule
```

---

### Phase 5: 最小CPU設計

| # | テーマ | 状態 |
|---|--------|------|
| 5.1 | CPU の基本アーキテクチャを理解する | [ ] |
| 5.2 | 命令セットを設計する | [ ] |
| 5.3 | フェッチ・デコード・実行サイクルを実装 | [ ] |
| 5.4 | 動作テスト | [ ] |

#### 5.1 CPUの基本構成要素

```
┌─────────────────────────────────────────┐
│                  CPU                     │
│  ┌──────────┐    ┌──────────┐           │
│  │ Program  │    │ Register │           │
│  │ Counter  │    │   File   │           │
│  └──────────┘    └──────────┘           │
│       │               │                  │
│       ▼               ▼                  │
│  ┌──────────┐    ┌──────────┐           │
│  │Instruction│   │   ALU    │           │
│  │  Memory   │   │          │           │
│  └──────────┘    └──────────┘           │
│       │               │                  │
│       ▼               ▼                  │
│  ┌──────────────────────────┐           │
│  │      Control Unit        │           │
│  └──────────────────────────┘           │
└─────────────────────────────────────────┘
```

#### 5.2 2bit CPU 命令セット案

| 命令 (2bit) | 動作 |
|-------------|------|
| 00 | NOP (何もしない) |
| 01 | INC (アキュムレータ +1) |
| 10 | DEC (アキュムレータ -1) |
| 11 | OUT (アキュムレータをLEDに出力) |

#### 5.3 4bit CPU 命令セット案

| 命令 (4bit) | 形式 | 動作 |
|-------------|------|------|
| 0000 | NOP | 何もしない |
| 0001 | INC | A = A + 1 |
| 0010 | DEC | A = A - 1 |
| 0011 | OUT | LED = A |
| 01xx | ADD x | A = A + x (即値) |
| 10xx | LOAD x | A = x (即値) |
| 11xx | JMP x | PC = x (ジャンプ) |

---

## 進捗メモ

### 2025-01-25
- 学習プラン作成
- 現状: LED点滅サンプル (`main.v`) を理解済み

---

## 参考リソース

- [HDLBits](https://hdlbits.01xz.net/wiki/Main_Page) - Verilog練習問題サイト
- main.v のコメント付きコード: `blink_ledd/ffpga/src/main.v`

---

## 次のステップ

**Phase 1.1** から順番に進める。各フェーズ完了時に進捗メモを更新する。
