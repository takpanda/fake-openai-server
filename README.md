# fake-open-ai-server

OpenAI API互換のRerankサーバーをローカルで提供します。

[Dify](https://dify.ai/)で日本語の処理をおこないたい際に、
OpenAI-API-compatibleモデルプロバイダーでこれを指定します。

モデルとしては、次のものを利用しています。

- Rerank: [cl-nagoya/ruri-v3-reranker-310m](https://huggingface.co/cl-nagoya/ruri-v3-reranker-310m)

## 必要なもの

- [sentence-transformers](https://sbert.net/)が利用できる環境
  - Rerank: GPU VRAM1.5GB程度


## Docker Composeで実行する場合

buildしてupするだけです。

```sh
$ docker compose build
$ docker compose up -d
```
モデルのキャッシュはホストの`volumes`ディレクトリに保持されます。


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


### Difyでの設定

- Model Type: Rerank
- Model Name: cl-nagoya/ruri-v3-reranker-310m
- API Key: なし
- API endpoint URL: http://サーバーのホスト名・IPアドレス:8082/v1
- Model context size: 512

