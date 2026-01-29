# Simulation

## 前提条件

- Icarus Verilog (`iverilog`, `vvp`)

## シミュレーション実行

```bash
# simディレクトリに移動
cd blink_ledd/ffpga/sim

# コンパイルして実行
iverilog -o tb_main.vvp ../src/main.v tb_main.v && vvp tb_main.vvp
```

## 出力ファイル

| ファイル | 説明 |
|----------|------|
| `tb_main.vvp` | コンパイル済みシミュレーションファイル |
| `tb_main.vcd` | 波形ファイル（GTKWaveやVSCode fliplotで表示） |

## 波形の確認

`tb_main.vcd` をVSCodeのfliplot拡張機能で開くか、GTKWaveを使用：

```bash
gtkwave tb_main.vcd
```
