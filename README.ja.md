# RailsLauncher

Rails プロジェクトの立ち上げを一瞬で行うためのツールです。

Ruby の DSL でモデルとコントローラの枠組み定義し、 `rails_launcher` を実行すると Rails が必要とするファイルの一部が生成されます。
このツールには Rails プロジェクト自体を作る機能はないので、`rails new` は開発者がする必要があります。
また、 gem の管理も行わないので、必要となる gem はあらかじめ `Gemfile` に記載する必要があります。とくにプラグインを使う場合はこの点に気をつけてください。

## インストール方法

この gem は現段階では非公開なので、各自がビルドしてインストールする必要があります。

    $ bundle install
    $ bundle exec rake build
    $ gem install pkg/rails_launcher-x.x.x.gem   # バージョン番号は変わります

## 使い方

DSL で作成したいモデルや関係を定義します。
例が spec/sample_worlds にあります。
これを適当な名前の ruby script として保存します。

つぎに `rails new` してプロジェクトを作成します。このプロジェクトの名前は上のスクリプトに定義した `application` と同じにしてください。

    $ rails_launcher script.rb path/to/project

でプロジェクトディレクトリのなかにファイルが作成されます。
すでにファイルが存在する場合、基本動作は上書きです。

## DSL

現在使用可能な DSL の語彙は次のものがあります。

- `application`: アプリケーションの名前を決めます。`rails new` で指定したものと同じにする必要があります。指定することを推奨します
- `model`: モデルを定義します
- - カラム指定: migration ファイルと似た記法で作成するカラムを指定します
- - `controller`: モデルに対応するコントローラのオプションを指定します。現在 `:only`、`:except` で作成するアクションを指定できます
- - `no_controller`: モデルに対応するコントローラを作成しないようにします
- - `validates`: バリデーションを指定します。ActiveModel の `validates` とおなじオプションが使えます
- - `has_many`, `has_one`: 他のモデルとの関係性を指定します。`belongs_to` は反射的に自動で定義されるのでありません
- `controller`: モデルとひもづけられないコントローラを定義します
- `routes`: `root` や、RESTful でない URL を定義します
- `plugin`: プラグインを読み込みます。プラグインファイルのパスにつづいて Hash でオプションを渡せます

## Plugin

プラグインで動作を拡張することができます。
標準で FactoryGirl と Devise 用のプラグインが添付されています。

プラグインは `RailsLauncher::Plugin` module の下にクラスとして定義します。
DSL に記されたオプションの Hash を引数として `new` が呼ばれます。

`file_constructor` のなかで `new` が返したオブジェクト(クラスのインスタンス)の `process` メソッドが `DSL::World` とファイルの一覧(`FileEntity` のリスト)、 `FileConstructor::MigrationIdGenerator` を引数にして呼ばれます。
`process` メソッドはそれらの情報を利用してあたらしいファイルの一覧を作り、返してください。

プラグインと本体の結合部は未調整部分がおおいので、実現したいプラグインが実装しにくければ Issue を出してください。

## Contributing

なにか実現したいが現状うまく動作しない場合、どんな DSL でなにを実現したいのかを明確にして、要望を出してください。

パッチを送る場合はすべてのテストがすくなくとも MRI 1.9 で通ることを確認してください。新機能を追加した場合や、テストがカバーしていないバグを修正した場合はかならずそれを確認するテストを書いてください。

## License

MIT License とします。
