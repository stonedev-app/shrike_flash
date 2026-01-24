# CLAUDE.md

このファイルは、このリポジトリで作業する際にClaude Code (claude.ai/code) にガイダンスを提供します。

## プロジェクト概要

このプロジェクトは **Shrike Dev Board** 向けのArduinoプロジェクトで、RP2040/RP2350マイコンを使用してSPI経由でShrike FPGAにFPGAビットストリームをプログラミングします。このプロジェクトは、LittleFSストレージからFPGA構成をフラッシュするためにShrikeFlashライブラリを使用しています。

## ハードウェア

- **ボード**: Shrike Dev Board (RP2040/RP2350ベース)
- **ターゲット**: Shrike FPGA (FFPGAチップ)
- **インターフェース**: MCUとFPGA間のSPI通信

## プロジェクト構造

```
shrike_flash/
├── shrike_flash.ino        # メインのArduinoスケッチ
├── data/                   # FPGAビットストリームファイル (.bin)
│   └── led_blink.bin      # コンパイル済みFPGAビットストリーム
└── blink_ledd/            # FPGAソースプロジェクト
    ├── blink_ledd.ffpga   # GreenPAK Designerプロジェクトファイル (XML)
    └── ffpga/
        ├── src/
        │   └── main.v     # Verilog HDLソースコード
        └── build/         # FPGA合成/配置配線の出力
            └── FPGA_bitstream.bin  # 生成されたビットストリーム
```

## 開発ワークフロー

### 1. FPGA開発 (Verilog → ビットストリーム)

FPGA設計はVerilogで記述し、**GreenPAK Designer**を使用してコンパイルします：

1. Verilogソースを編集: `blink_ledd/ffpga/src/main.v`
2. GreenPAK Designer (GUIツール) で `blink_ledd/blink_ledd.ffpga` を開く
3. プロジェクトをビルドしてビットストリームを生成: `blink_ledd/ffpga/build/FPGA_bitstream.bin`
4. ビットストリームを適切な名前で `data/` フォルダにコピー (例: `led_blink.bin`)

**注意**: FPGA合成はGreenPAK Designer GUIで行われ、コマンドラインツールではありません。

### 2. Arduino開発 (MCUコード)

メインスケッチ (`shrike_flash.ino`) はShrikeFlashライブラリを使用してFPGAをプログラムします：

```cpp
#include "Shrike.h"

ShrikeFlash shrike;

void setup() {
  Serial.begin(115200);
  while (!Serial && millis() < 3000);

  shrike.begin();
  shrike.flash("/led_blink.bin");
}

void loop() {
  // 空 - FPGAはプログラミング後に独立して動作
}
```

### 3. アップロードプロセス

**ステップ1: ビットストリームファイルをLittleFSにアップロード**
- `.bin` ファイルを `data/` フォルダに配置
- Arduino IDEを使用: **ツール → Pico LittleFS Data Upload**
- これにより、`data/` 内のすべてのファイルがRP2040のLittleFSファイルシステムにアップロードされます

**ステップ2: Arduinoスケッチをアップロード**
- 通常通り `shrike_flash.ino` をコンパイルしてアップロード
- スケッチは起動時に指定されたビットストリームでFPGAをフラッシュします

## ビルド/アップロードコマンド

CLIビルドシステムは設定されていません。以下の設定で **Arduino IDE** または **Arduino CLI** を使用してください：

### Arduino IDE
- **ボード**: RP2040/RP2350ボードを選択 (Arduino-Pico または Mbed OS RP2040)
- **フラッシュサイズ**: FSサポート付きオプションを選択 (例: "2MB Sketch + 2MB FS")
- **アップロード**: 標準的なArduinoアップロードプロセス

### Arduino CLI (設定されている場合)
```bash
# スケッチをコンパイル
arduino-cli compile --fqbn rp2040:rp2040:generic shrike_flash

# スケッチをアップロード
arduino-cli upload -p /dev/ttyACM0 --fqbn rp2040:rp2040:generic shrike_flash

# LittleFSデータをアップロード (追加のプラグイン/ツールが必要)
# 注意: LittleFSアップロードは通常IDEプラグインが必要
```

## ShrikeFlashライブラリ

このプロジェクトは **Shrike** ライブラリ (v1.0.0) に依存しており、`~/Documents/Arduino/libraries/Shrike/` にインストールされている必要があります。

### 主要なライブラリ関数

- `shrike.begin(spi_speed)` - SPIとFPGAピンを初期化 (デフォルト 1.6 MHz)
- `shrike.flash(filename, word_size)` - LittleFSからビットストリームをフラッシュ
- `shrike.reset()` - FPGAの電源を再投入
- `shrike.listFiles()` - LittleFS内のすべてのファイルをリスト
- `shrike.fileExists(filename)` - ビットストリームファイルの存在を確認
- `shrike.printStats()` - フラッシュのタイミング/転送レートを表示

### デフォルトピン設定
| 機能 | RP2040ピン | 説明 |
|----------|------------|-------------|
| EN       | GPIO 13    | FPGA有効化 |
| PWR      | GPIO 12    | FPGA電源  |
| SS       | GPIO 1     | SPIチップセレクト |
| SCK      | GPIO 2     | SPIクロック   |
| MOSI     | GPIO 3     | SPIデータ出力 |
| MISO     | GPIO 0     | SPIデータ入力 |

## FPGAアーキテクチャ

サンプルの `main.v` はシンプルなLED点滅を実装しています：
- 50MHz入力クロック
- 32ビットカウンタが各クロックサイクルでインクリメント
- LEDは25,000,000サイクルごとにトグル (50MHzで0.5秒)
- FPGAピンマッピングにVerilog属性を使用: `(* iopad_external_pin *)`

## ファイルフォーマット

- **`.ino`** - Arduinoスケッチのソースコード
- **`.bin`** - FPGAビットストリーム (SPIフラッシュ用バイナリ形式)
- **`.ffpga`** - GreenPAK Designerプロジェクトファイル (XMLベース)
- **`.v`** - Verilog HDLソースコード
- **`.edif`** - EDIFネットリスト (合成出力)

## トラブルシューティング

### LittleFSマウント失敗
- フラッシュサイズ設定にFSパーティションが含まれていることを確認
- **ツール → Pico LittleFS Data Upload** 経由でファイルをアップロード

### ファイルが見つからない
- ビットストリームファイルが `data/` フォルダにあることを確認
- `shrike.flash()` 呼び出しでファイル名が正確に一致することを確認 (大文字小文字を区別)
- `shrike.listFiles()` を使用してアップロードされたファイルを確認

### FPGAがプログラミングされない
- シリアル出力のエラーメッセージを確認
- 配線がデフォルトのピン設定と一致することを確認
- より低いSPI速度を試す: `shrike.begin(800000);`
- ビットストリームファイルが有効で破損していないことを確認

### 新しいFPGA設計のビルド
- FPGA合成にはGreenPAK Designer (Windows/GUIツール) が必要
- ビルド後、`build/FPGA_bitstream.bin` を `data/` フォルダにコピー
- `shrike.flash()` 呼び出しで使用されるファイル名と一致するように名前を変更
