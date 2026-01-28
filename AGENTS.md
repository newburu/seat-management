# AGENTS.md

## 1. プロジェクト概要
**プロジェクト名**: Seating AI (仮)
**目的**: イベント主催者が参加者情報を登録し、AIを使って最適な席次（グルーピング）を提案・作成できるWebサービス。
**コア機能**:
- 参加者の属性（趣味、部署、年齢など）は主催者が自由に項目・値の追加が可能。
- DBへはJSON形式で保管する。
- イベント情報を登録し、参加者を紐付ける。
- イベントから座席表を作成する。
- グルーピングはAIが属性を分析し、「共通点重視」「分散重視」などの条件に従ってグルーピングを行う。
- イベントの座席表を表示する。
- イベントの座席表（参加者の入れ替え）をドラッグ＆ドロップで可能とする。
- ゲストユーザーはログインなしで使えるものとする。

## 2. 技術スタック (Strict Constraints)
以下の技術選定を厳守すること。

- **Backend Framework**: Ruby on Rails の安定版最新
- **Frontend**: Rails Server-Side Rendering (ERB) + **Hotwire (Turbo + Stimulus)**
※ React, Next.js, Vue.js は**使用しない**。
- **Database**: **MariaDB** (Gem: `mysql2`)
- **Infrastructure**: **No Docker**. ローカル環境（Mac/Linux）での直接実行を前提とし、現在のディレクトリをルートとして開発を進める。
- **Testing**: Minitest (Rails標準)
- **CSS**: Tailwind CSS

## 3. ディレクトリ・アーキテクチャ構成
Railsの標準構成（Convention over Configuration）に従う。

```text
app/
├── models/
│   ├── user.rb           # 認証ユーザー
│   ├── event.rb          # 席次表プロジェクト
│   ├── participant.rb    # 参加者 (属性はJSONカラム)
│   └── grouping.rb       # グループ分けの結果
├── services/
│   └── ai/
│       └── grouping_service.rb  # AIへの問い合わせロジック（フォールバック機能付き）
├── javascript/
│   └── controllers/      # Stimulus Controllers
│       ├── drag_controller.js   # 席移動のUI制御
│       └── drop_controller.js
└── views/                # Hotwire対応のERBテンプレート
```

## 4. 開発・実装ルール

### A. 認証 (Authentication)
- **Gem**: `devise`, `omniauth`, `omniauth-google-oauth2`, `omniauth-twitter2`
- **SSO**: Google および X (Twitter) のみ。
- **Email/Password**: 無効化（Deviseのdatabase_authenticatableは使用しない、またはdummy対応）。
- **Guest Access**:
  - `User` モデルは `email` を NULL許容 とする。
  - LPの「CSVアップロード」アクションで、裏側で `provider: 'guest'` の一時ユーザーを作成し、自動ログインさせる。

### B. データベース設計方針
- **Participants**:
  - `name`: string
  - `properties`: **json** (自由な属性情報を格納)
  - `event_id`: references

### C. AI統合 (Google Gemini Strategy)
無料枠を最大限活用するため、以下の戦略で実装する。
- **Provider**: Google Gemini API
- **Gem**: `gemini-ai` (または適切なRubyクライアント)
- **Model Rotation (Fallback Logic)**:
  1. `gemini-1.5-flash` (First attempt)
  2. `gemini-1.5-pro` (If Flash fails or hits rate limit)
  3. `gemini-1.0-pro` (Final fallback)
- 実装は `app/services/ai/grouping_service.rb` に集約し、コントローラーからはモデルの違いを意識させないこと。

## 5. 開発ロードマップ (Step-by-step Instructions)

エージェントは以下の順序で実装を進めること。

### Phase 1: 基盤構築
1. `rails new` (mysql指定, skip-docker)
2. DB設定 (`database.yml`) と接続確認。
3. `User` モデル作成 (Devise + OmniAuth設定)。`email`のnullable化。
4. `Event`, `Participant` モデル作成。`Participant` の `properties` カラム(JSON)の実装。

### Phase 2: ゲスト機能とCSVインポート
1. Topページ作成。
2. `GuestsController` 作成。
   - `create`: ゲストユーザー作成 -> ログイン -> CSV解析 -> データ保存 -> イベント画面へリダイレクト。
3. CSVインポート機能の実装（ヘッダー行を属性キーとしてJSONにマッピング）。

### Phase 3: AIグルーピングロジック
1. `Ai::GroupingService` クラスの実装。
2. Gemini APIの呼び出しと、モデルフォールバック処理の実装。
3. プロンプトエンジニアリング: 参加者JSONリストを渡し、指定された条件（グループ数、方針）でグループ分けされたJSONを受け取る。

### Phase 4: UI/UX (Hotwire)
1. グルーピング結果の表示画面。
2. Stimulus と `sortablejs` 等を使用したドラッグ＆ドロップでの席移動機能。
3. Turbo Streams を使用した、AI処理中のローディング表示と結果の非同期置換。

---

## 6. エージェントへの特記事項
- **Gemini API Key**: 環境変数 `GOOGLE_API_KEY` から読み込むこと。コードにハードコードしない。
- **Mocking**: 開発中、外部API（Google/X Auth, Gemini API）が利用できない場合は、開発用モック（ダミーレスポンス）を作成して進行すること。
- **Error Handling**: AIの応答は不安定な場合があるため、JSONパースエラー等の例外処理を必ず入れること。