# らくらくコマ組み
学習塾・個別指導塾向けの時間割作成アプリです。
煩雑なコマ組み業務の負担を減らします。
時間割の自動作成にも対応します。

# 実装機能
* ユーザー機能
  - 新規登録・ログイン・ログアウト
  - プラン選択(フリープラン,ベーシックプラン)
    - フリープラン: 登録できる講師と生徒の人数に制限
    - ベーシックプラン: 制限なし
* 名簿管理機能
  - 講師および生徒の追加・削除
* コース管理機能
  - コースの追加・削除
* コマ組み機能
  - 種別の選択
    - １週間: 月曜日〜日曜日の予定を作成
    - 期間指定: 開始日と終了日を指定して予定を作成
  - コマ組み方法
    - 手動モード: 編集画面で手動でコマ組みを行う
    - 全自動モード: 入力された情報から自動でコマ組みを行う

# 設計
* [データモデル](../application/doc/README.md)

# 技術スタック
* フロントエンド
  - Slim
  - Sass
  - jQuery
  - Bootstrap4
* バックエンド
  - Ruby 2.6.3
  - Ruby on Rails 6.0.3
  - Python 3.7.3
* サーバー
  - Nginx
* データベース
  - PostgreSQL 10.6
* インフラ
  - Docker
  - AWS(EC2,RDS,S3,Batch)
