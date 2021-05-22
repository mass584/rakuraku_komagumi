# アプリケーション開発者へ
## 開発環境の初期設定
1. Dockerイメージのビルド

```shell
cd $PROJECT_ROOT/optimization
docker build . -t rakuraku_komagumi_optimization
```

## 開発コマンド
* Dockerコンテナ群の立ち上げ

```shell
cd $PROJECT_ROOT
docker-compose up optimization
```

* Dockerコンテナへのログイン 

```shell
cd $PROJECT_ROOT/optimization
docker exec -it rakuraku_komagumi_optimization_1 /bin/bash --login
```

* Linter/Formatterの実行

```shell
pycodestyle . --ignore="E501,W503,W504" # チェック
autopep8 --in-place --aggressive --recursive . # 自動修正
```

* UnitTestの実行

```shell
python -m unittest discover
```

* LineProfilerの実行

```shell
python -m unittest discover -p "profiler*.py"
```
