require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db 
  @db = SQLite3::Database.new 'heytheresinatra.db'
  @db.results_as_hash = true
end

def init_table 
  @db.execute 'CREATE TABLE IF NOT EXISTS "Posts" (
    "id"	INTEGER PRIMARY KEY AUTOINCREMENT,
    "created_date"	DATE,
    "title" TEXT,
    "content"	TEXT
  );'
  
  @db.execute 'CREATE TABLE IF NOT EXISTS "Comments" (
    "id"	INTEGER PRIMARY KEY AUTOINCREMENT,
    "created_date"	DATE,
    "content"	TEXT,
    "post_id" INTEGER
  );'
end

before do 
  init_db
end

configure do
  init_db
  init_table
end

helpers do
  def username
    session[:identity] ? session[:identity] : 'Hello stranger'
  end
end

get '/' do
  @results = @db.execute 'select * from Posts order by id desc'

  erb :index
end

get '/new' do
  erb :new
end

post '/new' do
  title = params[:title].strip
  content = params[:content].strip

  if content.length <= 0 || title.length <= 0
    @error = "Type post text"

    return erb :new
  end

  @db.execute 'insert into Posts (title, content, created_date) values(?, ?,datetime())', [title, content]

  redirect to '/'
end

get '/details/:post_id' do
  post_id = params[:post_id]

  results = @db.execute 'select * from Posts where id=?', [post_id]
  @comments = @db.execute 'select * from Comments where post_id=? order by id', [post_id]

  @row = results[0]

  erb :details
end

post '/details/:post_id' do 
  post_id = params[:post_id]
  content = params[:content]

  @db.execute 'insert into Comments 
    (
      content,
      created_date,
      post_id
    ) values 
    (
      ?,
      datetime(),
      ?
    )', [content, post_id]

  redirect '/details/' + post_id
end