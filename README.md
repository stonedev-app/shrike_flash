# Shrike Flash - FPGA LED点滅プロジェクト

Shrike Lite開発ボードでFPGAプログラミングを始めるためのスタートアッププロジェクトです。RP2040マイコンを使用してSPI経由でFPGAにビットストリームをフラッシュし、LED点滅を実装します。

## 📋 目次

- [概要](#概要)
- [Shrike Liteについて](#shrike-liteについて)
- [参照したリソース](#参照したリソース)
- [開発環境のセットアップ](#開発環境のセットアップ)
- [プロジェクト構成](#プロジェクト構成)
- [使い方](#使い方)
- [LED点滅の仕組み](#led点滅の仕組み)
- [トラブルシューティング](#トラブルシューティング)
- [ライセンス](#ライセンス)

## 概要

このプロジェクトは、Shrike Liteボードを使ったFPGA開発の入門として、以下の公式ドキュメントとコミュニティガイドを参考に実装しました：

- [Shrike公式ドキュメント](https://vicharak-in.github.io/shrike/)
- [Qiita: Shrike Lite 使ってみた](https://qiita.com/Lathe/items/241640a492adc2b5fc6e)

LED点滅という最もシンプルなFPGA設計を通じて、Verilogによるハードウェア記述、ビットストリーム生成、そしてRP2040からのFPGAプログラミングの一連の流れを学習できます。

## Shrike Liteについて

**Shrike Lite** は、学習者やメーカー、ホビイストを対象とした低コストのFPGA開発ボードです。

### 主な特徴

- **FPGA**: Renesas ForgeFPGA SLG47910V
- **マイコン**: Raspberry Pi RP2040
- **プログラミング方式**: RP2040がSPI経由でFPGAをコンフィギュレーション
- **ターゲット**: FPGA初学者、組み込みエンジニア、電子工作愛好家

Shrikeファミリーには、RP2350を搭載した上位モデルも存在します。

## 参照したリソース

このプロジェクトは以下のリソースを参考に実装しました：

1. **[Shrike公式ドキュメント](https://vicharak-in.github.io/shrike/)**
   - ハードウェア仕様とピン配置
   - セットアップガイド
   - ビットストリーム生成手順
   - Verilogコーディング規約

2. **[Qiita記事: Shrike Lite 使ってみた by @Lathe](https://qiita.com/Lathe/items/241640a492adc2b5fc6e)**
   - Arduino IDEでの開発環境構築
   - LittleFSプラグインの導入方法
   - LED点滅サンプルの実装手順
   - トラブルシューティング

## 開発環境のセットアップ

### 1. Arduino IDE (RP2040開発用)

#### ボードマネージャの設定

1. Arduino IDEを起動
2. **ファイル → 環境設定** を開く
3. 「追加のボードマネージャのURL」に以下を追加：
   ```
   https://github.com/earlephilhower/arduino-pico/releases/download/global/package_rp2040_index.json
   ```
4. **ツール → ボード → ボードマネージャ** から「Raspberry Pi Pico/RP2040」をインストール

#### LittleFSプラグインのインストール

LittleFSファイルシステムにビットストリームをアップロードするためのプラグインが必要です：

1. [arduino-littlefs-upload](https://github.com/earlephilhower/arduino-littlefs-upload/releases)からVSIXファイルをダウンロード
2. 以下のディレクトリに配置：
   - **Windows**: `C:\Users\<ユーザー名>\.arduinoIDE\Plugins\`
   - **Mac**: `~/.arduinoIDE/Plugins/`
3. Arduino IDEを再起動

#### Shrikeライブラリのインストール

1. **スケッチ → ライブラリをインクルード → ライブラリを管理** を開く
2. 検索ボックスに「Shrike」と入力
3. **Shrike** ライブラリをインストール

### 2. Go Configure Software Hub (FPGA開発用)

FPGA設計のコンパイルには、Renesasの **Go Configure Software Hub** (旧称: GreenPAK Designer) が必要です。

1. [Renesas公式サイト](https://www.renesas.com/software-tool/go-configure-software-hub)にアクセス
2. アカウント登録（無料）
3. ソフトウェアをダウンロードしてインストール

> **注意**: FPGA合成はGUIツールで行います。コマンドラインでのビルドには対応していません。

## プロジェクト構成

```
shrike_flash/
├── README.md                   # このファイル
├── CLAUDE.md                   # AI開発支援用ドキュメント
├── shrike_flash.ino           # メインのArduinoスケッチ
├── data/                      # ビットストリームファイル格納フォルダ (git管理外)
│   └── led_blink.bin         # LED点滅用FPGAビットストリーム (要ビルド)
└── blink_ledd/               # FPGA設計プロジェクト
    ├── blink_ledd.ffpga      # Go Configure プロジェクトファイル
    └── ffpga/
        ├── src/
        │   └── main.v        # Verilog HDLソースコード
        └── build/            # FPGA合成出力 (git管理外)
            └── FPGA_bitstream.bin  # 生成されたビットストリーム
```

## 使い方

### クイックスタート

GitHubからクローン後、まずFPGAビットストリームをビルドする必要があります。

> **注意**: `data/` と `build/` フォルダはgit管理外のため、GitHubリポジトリには含まれていません。

#### ステップ0: ビットストリームのビルド

1. **Go Configure Software Hub** を起動
2. **File → Open Project** から `blink_ledd/blink_ledd.ffpga` を開く
3. **Build** ボタンをクリックしてビットストリームを生成
4. ビルド成功後、以下のファイルが生成されます：
   ```
   blink_ledd/ffpga/build/FPGA_bitstream.bin
   ```
5. `data/` フォルダを作成し、ビットストリームをコピー：
   ```bash
   mkdir -p data
   cp blink_ledd/ffpga/build/FPGA_bitstream.bin data/led_blink.bin
   ```

#### ステップ1: ビットストリームのアップロード

1. Shrike LiteをUSBケーブルでPCに接続
2. **Bootボタンを押しながら接続**（RP2040がストレージモードで起動）
3. Arduino IDEで本プロジェクトを開く
4. **Ctrl+Shift+P**（Macは**Cmd+Shift+P**）でコマンドパレットを開く
5. 「**Upload LittleFS to Pico/ESP8266/ESP32**」を選択
6. `data/` フォルダ内のファイルがRP2040のフラッシュメモリにアップロードされます

#### ステップ2: Arduinoスケッチのアップロード

1. **ツール → ボード** から RP2040ボードを選択
2. **ツール → Flash Size** で「**2MB (Sketch: 1MB, FS: 1MB)**」など、FS付きオプションを選択
3. **ツール → シリアルポート** でShrike Liteのポートを選択
4. **アップロード**ボタンをクリック

#### ステップ3: 動作確認

1. アップロード完了後、ボードが自動的にリセットされます
2. **シリアルモニタ**（115200 bps）を開くと、フラッシュの進行状況が表示されます
3. FPGAプログラミング成功後、**ボード上のLEDが0.5秒周期で点滅**します

### 独自のFPGA設計を試す

#### ステップ1: Verilogコードの編集

`blink_ledd/ffpga/src/main.v` を開き、点滅速度などを変更できます：

```verilog
// 点滅周期を変更（例: 0.25秒にする）
if (counter == 12_500_000) begin  // 元は 25_000_000
  LED_status <= !LED_status;
  counter <= 32'b0;
end
```

#### ステップ2: ビットストリームの生成

1. Go Configure Software Hubを起動
2. `blink_ledd/blink_ledd.ffpga` を開く
3. **Build** ボタンをクリック
4. 生成されたビットストリーム：
   ```
   blink_ledd/ffpga/build/FPGA_bitstream.bin
   ```

#### ステップ3: ビットストリームのコピー

```bash
# 生成されたビットストリームをdataフォルダにコピー
cp blink_ledd/ffpga/build/FPGA_bitstream.bin data/led_blink.bin
```

#### ステップ4: 再アップロード

「クイックスタート」の手順を繰り返してビットストリームとスケッチを再度アップロードします。

## LED点滅の仕組み

### Verilogによるハードウェア記述 (`main.v`)

このプロジェクトのFPGA設計は以下のロジックで動作します：

```verilog
(* top *) module blink(
  (* iopad_external_pin, clkbuf_inhibit *) input clk,   // 50MHz
  (* iopad_external_pin *) output LED,
  (* iopad_external_pin *) output LED_en,
  (* iopad_external_pin *) output clk_en
);

  reg [31:0] counter;      // 32ビットカウンタ
  reg LED_status;          // LED状態レジスタ

  assign LED_en = 1'b1;    // LED常時有効
  assign clk_en = 1'b1;    // クロック常時有効

  always @ (posedge clk) begin
    counter <= counter + 1'b1;

    if (counter == 25_000_000) begin  // 0.5秒 (50MHz / 25M = 2Hz)
      LED_status <= !LED_status;
      counter <= 32'b0;
    end
  end

  assign LED = LED_status;

endmodule
```

### 動作原理

1. **50MHzクロック入力**: FPGAに外部から50MHzのクロックが供給されます
2. **カウンタのインクリメント**: 各クロックサイクル（20ns）ごとにカウンタが+1
3. **2,500万カウント**: 25,000,000クロック = 0.5秒後にLEDの状態を反転
4. **周期的な点滅**: 0.5秒ON → 0.5秒OFF を繰り返し

### RP2040によるFPGAプログラミング

`shrike_flash.ino` は起動時に以下の処理を実行します：

```cpp
#include "Shrike.h"

ShrikeFlash shrike;

void setup() {
  Serial.begin(115200);
  while (!Serial && millis() < 3000);

  // ShrikeFlashライブラリの初期化（SPI設定、ピン設定）
  shrike.begin();

  // LittleFSからビットストリームを読み込み、SPIでFPGAに転送
  shrike.flash("/led_blink.bin");
}

void loop() {
  // FPGAはプログラミング後、独立して動作するため処理なし
}
```

## トラブルシューティング

### LittleFSマウント失敗

**エラー**: `LittleFS Mount Failed`

**解決方法**:
- **ツール → Flash Size** で FS（ファイルシステム）領域を含むオプションを選択
- 例: 「2MB (Sketch: 1MB, FS: 1MB)」
- LittleFSデータアップロードツールでファイルを再アップロード

### ビットストリームファイルが見つからない

**エラー**: `File not found: /led_blink.bin`

**解決方法**:
- `data/` フォルダにビットストリームファイルが存在するか確認
- ファイル名が `shrike.flash()` の引数と完全一致するか確認（大文字小文字を区別）
- シリアルモニタで `shrike.listFiles()` を実行してアップロード済みファイルを確認

### FPGAがプログラミングされない

**症状**: LEDが点滅しない、シリアル出力でエラー

**解決方法**:
1. **シリアルモニタの確認**: エラーメッセージを確認
2. **配線チェック**: ボードのSPIピンが正しく接続されているか
3. **SPI速度を下げる**:
   ```cpp
   shrike.begin(800000);  // 1.6MHz → 800kHz
   ```
4. **ビットストリームの再生成**: Go Configureで正常にビルドできているか確認

### Go Configureでビルドエラー

**解決方法**:
- Verilogの文法エラーを確認
- ピンマッピングが正しく設定されているか確認
- エラーログを確認して該当箇所を修正

## ライセンス

MIT License

このプロジェクトは学習目的で作成されました。Shrikeライブラリは[Vicharak](https://github.com/vicharak-in)によって提供されています。

## 謝辞

- [Vicharak](https://vicharak.in/) - Shrike開発ボードとライブラリの提供
- [@Lathe](https://qiita.com/Lathe) - Qiita記事での詳細な解説
- [Renesas](https://www.renesas.com/) - ForgeFPGAおよび開発ツールの提供

## 参考リンク

- [Shrike公式ドキュメント](https://vicharak-in.github.io/shrike/)
- [Shrike GitHubリポジトリ](https://github.com/vicharak-in/shrike_flash)
- [Qiita: Shrike Lite 使ってみた](https://qiita.com/Lathe/items/241640a492adc2b5fc6e)
- [Go Configure Software Hub](https://www.renesas.com/software-tool/go-configure-software-hub)
- [Arduino-Pico](https://github.com/earlephilhower/arduino-pico)

---

**Happy FPGA Programming! 🚀**
