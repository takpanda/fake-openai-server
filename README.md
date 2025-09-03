# fake-openai-server

OpenAI API互換のText EmbeddingsとRerankサーバーをローカルで提供します。

[Dify](https://dify.ai/)で日本語の処理をおこないたい際に、
OpenAI-API-compatibleモデルプロバイダーでこれを指定します。

モデルとしては、次のものを利用しています。

- Text Embeddings: [cl-nagoya/ruri-large](https://huggingface.co/cl-nagoya/ruri-large)
- Rerank: [cl-nagoya/ruri-v3-reranker-310m](https://huggingface.co/cl-nagoya/ruri-v3-reranker-310m)

## 必要なもの

- [sentence-transformers](https://sbert.net/)が利用できる環境
  - Text Embeddings: GPU VRAM2GB程度
  - Rerank: GPU VRAM1.5GB程度


## Docker Composeで実行する場合（推奨）

buildしてupするだけです。新しい統合イメージが両方のサービスを提供します。

```sh
$ docker compose build
$ docker compose up -d
```

これにより以下のサービスが起動します：
- Embeddings API: http://localhost:8081
- Rerank API: http://localhost:8082

モデルのキャッシュはホストの`volumes`ディレクトリに保持されます。

### 単一サービスのみ起動する場合

特定のサービスのみを起動したい場合：

```sh
# Embeddingsサービスのみ
$ docker compose up embeddings-server

# Rerankサービスのみ  
$ docker compose up reranker-server
```

### 統合Dockerイメージの直接利用

統合イメージを直接使用することも可能です：

```sh
# Embeddingsサーバーとして起動
$ docker run -p 8081:8081 -e SERVICE_TYPE=embeddings fake-openai-server/unified-server:latest

# Rerankサーバーとして起動
$ docker run -p 8082:8082 -e SERVICE_TYPE=reranker fake-openai-server/unified-server:latest
```


## Dockerなしで実行したい場合
### パッケージのインストール

```sh
$ sudo apt install \
       build-essential \
       cmake pkg-config \
       libprotobuf-dev \
       libsentencepiece-dev
```


### Pythonライブラリのインストール
ライブラリの管理は[uv](https://github.com/astral-sh/uv)を用います。

```sh
$ uv sync
```


## つかいかた(Text Embeddings)

### Embeddingsサーバーの起動

```sh
$ uv run uvicorn embeddings-api-server:app --host 0.0.0.0 --port 8081
```

Docker Composeの場合は不要です。

### Embeddingsサーバーの動作テスト

```sh
$ curl -v http://127.0.0.1:8081/v1/embeddings \
  -H 'Content-Type: application/json' \
  --data-raw '{
    "model": "cl-nagoya/ruri-large",
    "input": ["文章: テストテキストです。"]
  }'
```

期待されるレスポンス:

```json
{
  "object": "list",
  "data": [
    {
      "object": "embedding",
      "index": 0,
      "embedding": [0.1, 0.2, 0.3, ...]
    }
  ],
  "model": "cl-nagoya/ruri-large",
  "usage": {
    "prompt_tokens": 3,
    "total_tokens": 3
  }
}
```

### Difyでの設定（Embeddings）

1. **設定** > **モデルプロバイダー** > **OpenAI-API-Compatible**を選択
2. モデル名: `cl-nagoya/ruri-large`
3. APIベースURL: `http://localhost:8081/v1`
4. APIキー: `fake` (任意の文字列)

## つかいかた(Rerank)

### Rerankサーバーの起動

```sh
$ uv run uvicorn rerank-api-server:app --host 0.0.0.0 --port 8082
```

Docker Composeの場合は不要です。


### Rerankサーバーの動作テスト

```sh
$ curl -v http://127.0.0.1:8082/v1/rerank -H 'Content-Type: application/json' --data-raw '
{
    "model": "cl-nagoya/ruri-v3-reranker-310m",
    "query": "山形県の蔵王温泉にある「泉質」はなに？",
    "documents": [
        "蔵王温泉はどのような特徴を 持つ温泉ですか？",
        "山形市の蔵王温泉はどのような温泉ですか？",
        "蔵王温泉の特徴は何ですか？"
    ]
}'
```

```json
{
  "results": [
    {
      "document": {
        "text": "蔵王温泉はどのような特徴を 持つ温泉ですか？"
      },
      "relevance_score": 0.029905224218964577,
      "index": 0
    },
    {
      "document": {
        "text": "山形市の蔵王温泉はどのような温泉ですか？"
      },
      "relevance_score": 0.013406982645392418,
      "index": 1
    },
    {
      "document": {
        "text": "蔵王温泉の特徴は何ですか？"
      },
      "relevance_score": 0.012443745508790016,
      "index": 2
    }
  ],
  "model": "cl-nagoya/ruri-v3-reranker-310m",
  "usage": {
    "total_tokens": 0
  }
}
```


### Difyでの設定（Rerank）

- Model Type: Rerank
- Model Name: cl-nagoya/ruri-v3-reranker-310m
- API Key: なし
- API endpoint URL: http://サーバーのホスト名・IPアドレス:8082/v1
- Model context size: 512

## 移行ガイド（統合イメージへの移行）

### 新しい統合アプローチ（推奨）

v2.0以降、base-serverとreranker-serverは単一の統合イメージに統合されました。この変更により：

- **簡単な deployment**: 単一のイメージで両方のサービスを提供
- **リソース効率**: 共通の基盤を共有することで効率的
- **設定の簡素化**: 環境変数で簡単にサービスを切り替え可能

### 既存セットアップからの移行

1. **新しい compose.yaml を使用**:
   ```sh
   docker compose down
   docker compose build
   docker compose up -d
   ```

2. **レガシー setup を使用している場合**:
   - `compose-legacy.yaml` が古い設定のバックアップとして提供されています
   - 移行後は新しい統合アプローチの使用を推奨します

### 破壊的変更

- `fake-openai-server/base-server` イメージは非推奨です
- `fake-openai-server/reranker-server` イメージは非推奨です  
- 新しい `fake-openai-server/unified-server` イメージを使用してください

### 統合イメージの利点

- ✅ 単一イメージで両方のサービス（embeddings + rerank）
- ✅ 環境変数による柔軟なサービス選択
- ✅ 簡単なスケーリングとデプロイ
- ✅ 共通依存関係の効率的な管理
- ✅ 統一されたログとモニタリング

