require 'sinatra'
require 'sinatra/reloader'
require "yaml"

# set :show_exceptions, false

class NotFoundError < StandardError; end

not_found do
  'This is nowhere to be found.'
end

error NotFoundError do
  status 404
  'This is nowhere to be found.'
end

# メモ一覧
get '/memos/?' do
  @title = 'メモ一覧'
  File.open('memos.yml') do |file|
    file = Psych.load(file, permitted_classes: [Time])
    @memos = file[1].select {|_, value| value['deleted_at'] == nil}
  end
  erb :index
end

# メモ登録画面
get '/memos/new/?' do
  @title = 'メモ登録'
  erb :new
end

# メモ登録処理
post '/memos' do
  all_count = 0
  all_memos = ''
  File.open('memos.yml') do |file|
    all_memos = Psych.load(file, permitted_classes: [Time])
    all_count = all_memos[1].keys.last
  end

  user_id = 1
  memo_id = all_count + 1
  date = Time.now
  File.open('memos.yml', 'w') do |file|
    all_memos[1][memo_id.to_i] = 
      {
        'subject' => params[:subject],
        'content' => params[:content],
        'created_at' => date,
        'updated_at' => nil,
        'deleted_at' => nil,
      }
    Psych.dump(all_memos, file)
  end
  redirect to '/memos'
end

# メモ詳細画面
get %r{/memos/([1-9]+)/?} do
  @title = 'メモ詳細'
  @memo_id = params[:captures][0].to_i

  File.open('memos.yml') do |file|
    file = Psych.load(file, permitted_classes: [Time])
    raise NotFoundError if file[1][@memo_id].nil?
    @subject = file[1][@memo_id]['subject']
    @content = file[1][@memo_id]['content']
  end
  erb :show
end

# メモ編集画面
get %r{/memos/([1-9]+)/edit/?} do
  @title = 'メモ編集'
  @memo_id = params[:captures][0].to_i
  File.open('memos.yml') do |file|
    file = Psych.load(file, permitted_classes: [Time])
    raise NotFoundError if file[1][@memo_id].nil?
    @subject = file[1][@memo_id]['subject']
    @content = file[1][@memo_id]['content']
  end
  erb :edit
end

# メモ編集更新処理
patch '/memos/:memo_id' do
  all_memos = ''
  File.open('memos.yml') do |file|
    all_memos = Psych.load(file, permitted_classes: [Time])
  end

  raise NotFoundError if all_memos[1][params[:memo_id].to_i].nil?

  user_id = 1
  date = Time.now
  File.open('memos.yml', 'w') do |file|
    all_memos[1][params[:memo_id].to_i]['subject'] = params[:subject]
    all_memos[1][params[:memo_id].to_i]['content'] = params[:content]
    all_memos[1][params[:memo_id].to_i]['updated_at'] = date
    Psych.dump(all_memos, file)
  end
  redirect to "/memos/#{params[:memo_id]}"
end

# メモ削除処理
delete '/memos/:memo_id' do
  all_memos = ''
  File.open('memos.yml') do |file|
    all_memos = Psych.load(file, permitted_classes: [Time])
  end

  raise NotFoundError if all_memos[1][params[:memo_id].to_i].nil?

  user_id = 1
  date = Time.now
  File.open('memos.yml', 'w') do |file|
    all_memos[1][params[:memo_id].to_i]['deleted_at'] = date
    Psych.dump(all_memos, file)
  end
  redirect to('/memos')
end
