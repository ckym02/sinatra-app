require 'sinatra'
require 'sinatra/reloader'
require "yaml"

# メモ一覧
get '/memos' do
  File.open('memos.yml') do |file|
    file = Psych.load(file, permitted_classes: [Time])
    @memos = file[1]
  end
  erb :index
end

# メモ作成画面
get '/memos/new' do
  erb :new
end

# メモ詳細
get '/memos/:memo_id' do
  File.open('memos.yml') do |f|
    file = Psych.load(f, permitted_classes: [Time])
    @subject = file[1][params[:memo_id].to_i]['subject']
    @content = file[1][params[:memo_id].to_i]['content']
  end
  erb :show
end

# メモ内容編集
# ファイルの内容を変更する
get '/memos/:memo_id/edit' do
  @memo_id = params[:memo_id].to_i
  File.open('memos.yml') do |f|
    file = Psych.load(f, permitted_classes: [Time])
    @subject = file[1][@memo_id]['subject']
    @content = file[1][@memo_id]['content']
  end
  erb :edit
end

# メモ新規登録
# showページにリダイレクトする
post '/memos' do
  all_count = 0
  all_memos = ''
  File.open('memos.yml') do |file|
    all_memos = Psych.load(file)
    all_count = all_memos[1].keys.count
  end

  user_id = 1
  memo_id = all_count + 1
  date = Time.now
  File.open('memos.yml', 'w') do |file|
    all_memos[1][memo_id.to_i] = 
      {
        'subject' => params[:subject],
        'content' => params[:content],
        'created_at' => date
      }
    Psych.dump(all_memos, file)
  end
  redirect to('/memos')
end

# メモ内容編集の更新処理
patch '/memos/:memo_id' do
  "Hello World"
end
