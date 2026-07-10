# GitHub Codespaces 導入検証 runbook

このリポジトリに `.devcontainer/` を追加し、チェック項目表の各項目を実際に手を動かして検証できるようにしました。
起動は GitHub 上で「Code」→「Codespaces」→「Create codespace on feature/add_test」、
または `gh codespace create -r <owner>/<repo> -b feature/add_test` から。

凡例:
- **[環境]** この devcontainer / スクリプトで検証できる（下記コマンドを実行するだけ）
- **[GitHub設定]** リポジトリ・組織の Web UI（または gh api）側の設定が必要。ファイルでは用意できない
- **[人手]** 体感・目視での判断が必要。ツールは計測を補助するのみ

## 優先実施項目

| # | 項目 | 検証手順 | 備考 |
| --- | --- | --- | --- |
| A-1 | 社内NWからの接続要件 | `bash .devcontainer/scripts/check-corporate-network.sh` を社内NW上の端末（プロキシ配下）から実行し、BLOCKED行を記録。結果は `.devcontainer/logs/network/` に保存される | **[人手]+[環境]**。ドメインリストはスクリプト冒頭のコメント通り「よくある要件の初期セット」であり、GitHub公式の最新ドキュメントと必ず突き合わせること。Codespace作成〜ポート転送まで一巡した際に実際にブロックされた通信もあわせてメモする |
| A-2 | 実ワークロード性能比較 | `bash .devcontainer/scripts/record-env.sh` を 手元/2core/4core の各環境で実行。`lscpu`/`free -h`/`df -h` と `docker compose build --no-cache` の所要時間を `.devcontainer/logs/env/<timestamp>.txt` に記録 | このリポジトリ自体には元々ビルド/テストの仕組みがないため、`docker compose build` を代替の「クリーンビルド」計測対象にしている。実プロジェクトで検証する場合はスクリプト内の該当コマンドを実プロジェクトの `make build` 等に差し替える |
| A-3 | 日常操作の体感レイテンシ | 30分ほど実際にコーディングし体感を記録。負荷確認用に：巨大ファイル表示は `yes "0123456789" \| head -c 50000000 > /tmp/big.txt` で作成後エディタで開閉、大量出力は `yes` をターミナルで数秒流して確認 | **[人手]**。数値化しにくいため所感ベースでメモを残す運用を推奨 |
| A-4 | 拡張機能・デバッグ互換性 | `.devcontainer/devcontainer.json` の `customizations.vscode.extensions` に ESLint / Prettier / Docker / GitLens / Live Server を仮登録済み（ブラウザ版・Desktop版それぞれで自動インストールされるか確認）。デバッグは `.vscode/launch.json` の **"A-4: Launch site in Chrome"** を実行し、`js/index.js` にブレークポイントを置いてステップ実行できるか確認 | 拡張機能リストは実プロジェクトの必須拡張に合わせて `devcontainer.json` と `.vscode/extensions.json` を編集して差し替える。ブラウザ版 (github.dev 表示のCodespace) と Desktop版 VS Code 接続の両方で同じ手順を試すのがポイント |
| A-5 | Webアプリ開発フロー一式 | ①`docker compose up -d --build` → ポート8080が自動転送されるか確認 → 転送URLでページ表示。②HMR/WebSocket確認用に `npx live-server --port=5500 --host=0.0.0.0` を起動（Node featureを同梱済み）→ ポート5500経由でファイル保存時の自動リロードを確認 | DevToolsのNetworkタブで応答時間計測、切断回数は目視でメモ。**[人手]**判断込み |
| A-6 | docker-in-docker | Codespace内シェルで `docker compose up -d --build`（リポジトリ直下の `Dockerfile`/`docker-compose.yml`）を実行し、ビルド時間と起動可否を確認 | devcontainer.json に `docker-in-docker` feature を追加済み。`onCreateCommand` (`on-create.sh`) で `docker version` 疎通確認済み |

## 運用設計

| # | 項目 | 検証手順 | 備考 |
| --- | --- | --- | --- |
| B-1 | 新規作成時間とprebuild効果 | prebuildなしで作成→作成時間を記録。その後 **GitHub リポジトリの Settings → Codespaces → Set up prebuild** で対象ブランチのprebuildを設定し、再度作成して「⚡Prebuild ready」表示と時間短縮を比較。featuresを段階的に追加する場合は `devcontainer.json` の `features` に追記して再計測 | **[GitHub設定]が前提**。prebuild自体はリポジトリ設定からのみ有効化可能で、ファイルからは設定不可。作成時間は各段階で `.devcontainer/logs/lifecycle.log` の `onCreateCommand`/`postCreateCommand` のタイムスタンプ差分から算出できる |
| B-2 | データ永続性の境界 | 操作前後で `bash .devcontainer/scripts/mark-persistence.sh "<タグ>"` → 操作（停止/再開・Rebuild・Full Rebuild）→ `bash .devcontainer/scripts/check-persistence.sh` で workspace / HOME / コンテナ他領域 / dockerボリュームの4箇所の残存を確認 | 停止→再開を3回、Rebuild/Full Rebuildの所要時間は `postStartCommand` のログタイムスタンプから算出 |
| B-3 | 自動停止・自動削除の実挙動 | タイムアウトを **GitHub.com → Settings → Codespaces**（個人）または組織ポリシーで最短（5分）に設定 → ①タブを閉じて放置 ②`bash .devcontainer/scripts/record-env.sh` 等の長時間処理を実行中に放置、の2パターンで停止有無を確認。削除前の通知有無、停止中Codespaceから "Export changes to a branch" で未pushの変更を退避できるか確認 | **[GitHub設定]が前提**（タイムアウト値・保持期間はUI/組織ポリシー側）。挙動確認自体は**[人手]**の観察 |
| B-4 | devcontainer失敗時のリカバリー | 各lifecycleスクリプトは `.devcontainer/logs/lifecycle.log` に `start`/`ok`/`FAILED(exit=...)` を記録済み。意図的に壊す場合は例えば `devcontainer.json` の `postCreateCommand` を一時的に `"exit 1"` に書き換えてRebuild→挙動確認→`git checkout -- .devcontainer/devcontainer.json` で元に戻す。JSON破損は末尾にカンマを1つ追加するなどで再現 | 壊す/戻す作業はブランチを切るかスタッシュしてから行うと安全。リカバリーモードでの修正→Rebuildの流れも合わせて確認 |
| B-5 | 転送URLの可視性・セキュリティ | `devcontainer.json` の `portsAttributes` でポート8080/5500ともデフォルト `"visibility": "private"` に設定済み。VS CodeのPORTSパネルから一時的にPublicへ変更 → シークレットウィンドウ（未ログイン状態）でアクセスできてしまうか確認 → 再起動後もPrivateに戻っているか確認 | Private/Public切り替え自体はセッション中にPORTSパネルか `gh codespace ports visibility` から行う運用（ファイルでは初期値のみ制御） |
| B-6 | ローカルDev Containersへの代替経路 | 同じ `.devcontainer/devcontainer.json` をローカルVS Code + Dev Containers拡張で開き、A-2と同じ計測（`record-env.sh`）を実行して比較 | Codespaces固有の設定を使わない構成（`image`+`features`のみ）にしてあるため、ローカルでも同一構成で開けるはず。github status確認〜切替手順はこの表を手順書として使えばOK |

## 前提として直しておいたこと

以前 `.devcontiner/`（`devcontainer` のタイポ）というフォルダで似た構成が追加・削除された履歴がありましたが、このタイポだとCodespaces/VS Codeが devcontainer として認識しないため機能していませんでした。加えて存在しない `frontend`/`backend` ディレクトリを参照する汎用テンプレートだったため、このリポジトリの実体（静的サイト + ルート直下の `Dockerfile`/`docker-compose.yml`）に合わせて `.devcontainer/`（正しいスペル）で作り直しています。
