# アプリケーション開発者へ
## 開発環境の初期設定
1. `config/master.key`の設定

```shell
cd $PROJECT_ROOT/application
echo $MASTER_KEY > config/master.key
```

2. Dockerイメージのビルド

```shell
cd $PROJECT_ROOT/application
docker build . -t rakuraku_komagumi_application
```

3. Gem/npmパッケージのインストール

```shell
cd $PROJECT_ROOT/application
docker run --rm -v `pwd`:/root/project rakuraku_komagumi_application /bin/bash --login -c "bundle install && yarn install"
```

## 開発コマンド
* Dockerコンテナ群の立ち上げ

```shell
cd $PROJECT_ROOT
docker-compose up application # アプリケーションのみ起動
docker-compose up application webpacker # アプリケーション+webpacker起動
```

* Dockerコンテナへのログイン 
```shell
cd $PROJECT_ROOT/application
docker exec -it rakuraku_komagumi_application_1 /bin/bash --login
```

* 開発用データベースの作成+マイグレーション

```shell
bundle exec rails db:create
bundle exec rails db:migrate
```

* Linter/Formatterの実行

```shell
bundle exec rubocop # 自動修正なし
bundle exec rubocop --auto-correct # 自動修正あり
```

* UnitTest/IntegrationTestの実行

```shell
bin/rspec
```

## 利用Gem/npmパッケージの一覧
* Linter/Formatter
  - [rubocop](https://github.com/rubocop-hq/rubocop)

* UnitTest/IntegrationTest
  - [rspec-rails](https://github.com/rspec/rspec-rails)
  - [capybara](https://github.com/teamcapybara/capybara)
  - [factory_bot_rails](https://github.com/thoughtbot/factory_bot_rails)
  - [simplecov](https://github.com/simplecov-ruby/simplecov)

* Authentication/Authorization
  - [devise](https://github.com/heartcombo/devise)

* JSON Selializer
  - [active_model_serializers](https://github.com/rails-api/active_model_serializers) 

* Async Job
  - [delayed_job](https://github.com/collectiveidea/delayed_job)
  - [delayed_job_active_record](https://github.com/collectiveidea/delayed_job_active_record)

* Frontend
  - [slim-rails](https://github.com/slim-template/slim-rails)
  - [turbolinks](https://github.com/turbolinks/turbolinks)
  - [webpacker](https://github.com/rails/webpacker)
    - [bootstrap](https://www.npmjs.com/package/bootstrap)
    - [vuejs](https://www.npmjs.com/package/vue)
