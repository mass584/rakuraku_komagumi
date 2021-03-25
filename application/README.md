# 開発環境の起動
サーバーアプリケーションはDocker上で起動します。

* `docker-compose up` で起動中のコンテナにログインするとき
```
docker exec -it rakuraku_komagumi_application_1 /bin/bash --login
```

* 新たにコンテナを立ち上げるとき
```
docker run -it --rm -p 8000:8000 -v `pwd`:/root/project rakuraku_komagumi_application:latest /bin/bash --login
```
